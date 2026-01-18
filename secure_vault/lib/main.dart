import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'features/auth/screens/splash_screen.dart';
import 'features/auth/screens/pin_lock_screen.dart';
import 'services/vault_service.dart';
import 'services/file_service.dart';
import 'services/security_service.dart';
import 'services/biometric_service.dart';
import 'services/platform_security_service.dart';
import 'services/root_detection_service.dart';
import 'services/app_integrity_service.dart';
import 'services/clipboard_service.dart';
import 'services/app_lock_service.dart';
import 'services/locale_service.dart';
import 'services/theme_service.dart';
import 'core/storage/database_helper.dart';
import 'core/utils/logger.dart';
import 'l10n/app_localizations.dart';

/// Enum for security warning types
enum SecurityWarningType {
  rooted,
  developerMode,
  emulator,
  externalStorage,
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Note: sqflite works natively on Android/iOS without FFI setup
  runApp(const SecureVaultApp());
}

class SecureVaultApp extends StatefulWidget {
  const SecureVaultApp({super.key});

  @override
  State<SecureVaultApp> createState() => _SecureVaultAppState();
}

class _SecureVaultAppState extends State<SecureVaultApp>
    with WidgetsBindingObserver {
  static const String _tag = 'App';
  final SecurityService _securityService = SecurityService();
  final PlatformSecurityService _platformSecurityService =
      PlatformSecurityService();
  final RootDetectionService _rootDetectionService = RootDetectionService();
  final AppIntegrityService _appIntegrityService = AppIntegrityService();
  final ClipboardService _clipboardService = ClipboardService();
  final AppLockService _appLockService = AppLockService();
  final LocaleService _localeService = LocaleService();
  final ThemeService _themeService = ThemeService();

  // Global navigation key for showing PIN lock screen
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  // Security state
  bool _showSecurityWarning = false;
  List<SecurityWarningType> _securityWarnings = [];
  bool _isShowingPinLock = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeApp();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _securityService.dispose();
    _clipboardService.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    // Initialize locale service first
    await _localeService.initialize();

    // Initialize theme service
    await _themeService.initialize();

    // Initialize security service
    await _securityService.initialize();

    // Apply screenshot prevention based on settings
    final preventScreenshots =
        await _securityService.isScreenshotPreventionEnabled();
    await _platformSecurityService.applySecuritySettings(
      preventScreenshots: preventScreenshots,
    );

    // Perform security checks
    await _performSecurityChecks();

    // Cleanup expired trash files
    try {
      await DatabaseHelper.instance.cleanupExpiredTrash();
    } catch (e) {
      AppLogger.error('Trash cleanup error', tag: _tag, error: e);
    }
  }

  /// Perform comprehensive security checks
  Future<void> _performSecurityChecks() async {
    AppLogger.log('Starting security checks...', tag: _tag);
    final warnings = <SecurityWarningType>[];

    try {
      // Check for root/jailbreak
      final securityStatus = await _rootDetectionService.getSecurityStatus();
      if (securityStatus.isRooted) {
        warnings.add(SecurityWarningType.rooted);
      }
      if (securityStatus.isDeveloperModeEnabled) {
        warnings.add(SecurityWarningType.developerMode);
      }

      // Check app integrity
      final integrityResult = await _appIntegrityService.checkIntegrity();
      if (integrityResult.isEmulator) {
        warnings.add(SecurityWarningType.emulator);
      }
      if (integrityResult.isOnExternalStorage) {
        warnings.add(SecurityWarningType.externalStorage);
      }

      // Update state
      if (mounted) {
        setState(() {
          _securityWarnings = warnings;
          _showSecurityWarning = warnings.isNotEmpty;
        });
      }

      AppLogger.log(
        'Security checks complete: ${warnings.isEmpty ? "All clear" : "${warnings.length} warnings"}',
        tag: _tag,
      );
    } catch (e) {
      AppLogger.error('Security check failed', tag: _tag, error: e);
    }
  }

  /// Dismiss security warning
  void _dismissSecurityWarning() {
    setState(() {
      _showSecurityWarning = false;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        // App going to background
        AppLogger.log('Going to background', tag: _tag);
        _securityService.onAppPaused();
        break;
      case AppLifecycleState.resumed:
        // App coming to foreground
        AppLogger.log('Resuming from background', tag: _tag);
        _securityService.onAppResumed();
        // Check if we need to show PIN lock
        _checkAndShowPinLock();
        break;
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        // App closing or hidden
        break;
    }
  }

  /// Check if app should be locked and show PIN screen
  Future<void> _checkAndShowPinLock() async {
    if (_isShowingPinLock) return;

    try {
      final shouldLock = await _appLockService.shouldLock();
      if (shouldLock && _navigatorKey.currentState != null) {
        _isShowingPinLock = true;
        AppLogger.log('Showing PIN lock screen', tag: _tag);

        await _navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => PinLockScreen(
              mode: PinScreenMode.unlock,
              onSuccess: () {
                _isShowingPinLock = false;
                _navigatorKey.currentState?.pop();
              },
            ),
            fullscreenDialog: true,
          ),
        );
      }
    } catch (e) {
      AppLogger.error('Error checking PIN lock', tag: _tag, error: e);
      _isShowingPinLock = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<VaultService>(create: (_) => VaultService()),
        Provider<FileService>(create: (_) => FileService()),
        Provider<SecurityService>(create: (_) => _securityService),
        Provider<BiometricService>(create: (_) => BiometricService()),
        Provider<PlatformSecurityService>(
            create: (_) => _platformSecurityService),
        Provider<RootDetectionService>(create: (_) => _rootDetectionService),
        Provider<AppIntegrityService>(create: (_) => _appIntegrityService),
        Provider<ClipboardService>(create: (_) => _clipboardService),
        Provider<AppLockService>(create: (_) => _appLockService),
        ChangeNotifierProvider<LocaleService>.value(value: _localeService),
        ChangeNotifierProvider<ThemeService>.value(value: _themeService),
      ],
      child: Consumer2<LocaleService, ThemeService>(
        builder: (context, localeService, themeService, child) {
          return MaterialApp(
            title: 'Secure Vault',
            debugShowCheckedModeBanner: false,
            navigatorKey: _navigatorKey,

            // Localization
            locale: localeService.currentLocale,
            localizationsDelegates: const [
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: LocaleService.supportedLocales,

            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: Brightness.light,
              ),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
            ),
            themeMode: themeService.themeMode,
            home: _showSecurityWarning
                ? _buildSecurityWarningScreen()
                : const SplashScreen(),
          );
        },
      ),
    );
  }

  /// Get localized warning text for a security warning type
  String _getWarningText(SecurityWarningType type, S? l10n) {
    switch (type) {
      case SecurityWarningType.rooted:
        return l10n?.deviceRooted ?? 'Device is Rooted/Jailbroken';
      case SecurityWarningType.developerMode:
        return l10n?.developerModeEnabled ?? 'Developer Mode is enabled';
      case SecurityWarningType.emulator:
        return l10n?.emulator ?? 'Emulator';
      case SecurityWarningType.externalStorage:
        return l10n?.externalStorage ?? 'App installed on External Storage';
    }
  }

  /// Build security warning screen
  Widget _buildSecurityWarningScreen() {
    return Builder(
      builder: (context) {
        final l10n = S.of(context);
        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    size: 80,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n?.securityWarning ?? 'Security Warning',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n?.unsafeEnvironment ?? 'Potentially unsafe environment detected:',
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ..._securityWarnings.map((warningType) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline,
                                size: 20, color: Colors.red),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _getWarningText(warningType, l10n),
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      )),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.withValues(alpha: 0.5)),
                    ),
                    child: Text(
                      l10n?.appStillUsable ?? 'App can still be used, but data may be at risk.\nRecommended to use on non-rooted/jailbroken device',
                      style: const TextStyle(fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          // Exit app
                          _exitApp();
                        },
                        child: Text(l10n?.exitApp ?? 'Exit App'),
                      ),
                      FilledButton(
                        onPressed: _dismissSecurityWarning,
                        child: Text(l10n?.continueAnyway ?? 'Continue'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Exit the app
  void _exitApp() {
    // SystemNavigator.pop() for Android
    // For iOS, we can't programmatically close the app
    SystemNavigator.pop();
  }
}

