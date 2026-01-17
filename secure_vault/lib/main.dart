import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'features/auth/screens/splash_screen.dart';
import 'services/vault_service.dart';
import 'services/file_service.dart';
import 'services/security_service.dart';
import 'services/biometric_service.dart';
import 'services/platform_security_service.dart';
import 'services/root_detection_service.dart';
import 'services/app_integrity_service.dart';
import 'services/clipboard_service.dart';
import 'core/storage/database_helper.dart';
import 'core/utils/logger.dart';

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

  // Security state
  bool _showSecurityWarning = false;
  List<String> _securityWarnings = [];

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
    final warnings = <String>[];

    try {
      // Check for root/jailbreak
      final securityStatus = await _rootDetectionService.getSecurityStatus();
      if (securityStatus.isRooted) {
        warnings.add('อุปกรณ์ถูก Root/Jailbreak - ความปลอดภัยลดลง');
      }
      if (securityStatus.isDeveloperModeEnabled) {
        warnings.add('Developer Mode เปิดอยู่');
      }

      // Check app integrity
      final integrityResult = await _appIntegrityService.checkIntegrity();
      if (integrityResult.isEmulator) {
        warnings.add('กำลังรันบน Emulator');
      }
      if (integrityResult.isOnExternalStorage) {
        warnings.add('แอปติดตั้งบน External Storage');
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
        break;
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        // App closing or hidden
        break;
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
      ],
      child: MaterialApp(
        title: 'Secure Vault',
        debugShowCheckedModeBanner: false,
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
        themeMode: ThemeMode.system,
        home: _showSecurityWarning
            ? _buildSecurityWarningScreen()
            : const SplashScreen(),
      ),
    );
  }

  /// Build security warning screen
  Widget _buildSecurityWarningScreen() {
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
              const Text(
                'คำเตือนความปลอดภัย',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'ตรวจพบสภาพแวดล้อมที่อาจไม่ปลอดภัย:',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ..._securityWarnings.map((warning) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            size: 20, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            warning,
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
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withOpacity(0.5)),
                ),
                child: const Text(
                  'แอปยังสามารถใช้งานได้ แต่ข้อมูลอาจมีความเสี่ยง\n'
                  'แนะนำให้ใช้งานบนอุปกรณ์ที่ไม่ได้ Root/Jailbreak',
                  style: TextStyle(fontSize: 14),
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
                    child: const Text('ออกจากแอป'),
                  ),
                  FilledButton(
                    onPressed: _dismissSecurityWarning,
                    child: const Text('ดำเนินการต่อ'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Exit the app
  void _exitApp() {
    // SystemNavigator.pop() for Android
    // For iOS, we can't programmatically close the app
    SystemNavigator.pop();
  }
}

