import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/onboarding_service.dart';
import '../../../services/app_lock_service.dart';
import '../../../services/biometric_service.dart';
import '../../../services/locale_service.dart';
import '../../vault/screens/vault_list_screen.dart';

/// Onboarding page types
enum OnboardingPage {
  welcome,
  features,
  securityWarning,
  terms,
  setupPin,
  confirmPin,
  biometric,
  complete,
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final OnboardingService _onboardingService = OnboardingService();
  final AppLockService _appLockService = AppLockService();
  final BiometricService _biometricService = BiometricService();

  final PageController _pageController = PageController();
  int _currentPageIndex = 0;

  // Feature page
  int _featurePageIndex = 0;
  final int _featurePageCount = 4;

  // Security warning
  bool _acceptedRisk = false;

  // Terms
  bool _acceptedTerms = false;
  bool _acceptedPrivacy = false;

  // PIN setup
  String _pin = '';
  String _confirmPin = '';
  bool _isConfirmingPin = false;
  String? _pinError;

  // Biometric
  bool _biometricAvailable = false;
  String _biometricTypeName = '';

  @override
  void initState() {
    super.initState();
    _checkBiometric();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _checkBiometric() async {
    final isAvailable = await _biometricService.isBiometricAvailable();
    if (isAvailable) {
      final types = await _biometricService.getAvailableBiometrics();
      setState(() {
        _biometricAvailable = true;
        _biometricTypeName = _biometricService.getBiometricTypeName(types);
      });
    }
  }

  void _goToPage(OnboardingPage page) {
    _pageController.animateToPage(
      page.index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _nextPage() {
    if (_currentPageIndex < OnboardingPage.values.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPageIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    await _onboardingService.completeOnboarding();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const VaultListScreen()),
      );
    }
  }

  void _onPinDigitPressed(String digit) {
    HapticFeedback.lightImpact();

    if (_isConfirmingPin) {
      if (_confirmPin.length < 6) {
        setState(() {
          _confirmPin += digit;
          _pinError = null;
        });

        if (_confirmPin.length == 6) {
          _validatePins();
        }
      }
    } else {
      if (_pin.length < 6) {
        setState(() {
          _pin += digit;
          _pinError = null;
        });

        if (_pin.length == 6) {
          // Move to confirm PIN page
          Future.delayed(const Duration(milliseconds: 200), () {
            setState(() {
              _isConfirmingPin = true;
            });
            _goToPage(OnboardingPage.confirmPin);
          });
        }
      }
    }
  }

  void _onPinBackspace() {
    HapticFeedback.lightImpact();

    if (_isConfirmingPin) {
      if (_confirmPin.isNotEmpty) {
        setState(() {
          _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
          _pinError = null;
        });
      } else {
        // Go back to setup PIN page
        setState(() {
          _isConfirmingPin = false;
          _pin = '';
        });
        _goToPage(OnboardingPage.setupPin);
      }
    } else {
      if (_pin.isNotEmpty) {
        setState(() {
          _pin = _pin.substring(0, _pin.length - 1);
          _pinError = null;
        });
      }
    }
  }

  Future<void> _validatePins() async {
    final l10n = S.of(context);

    if (_pin != _confirmPin) {
      setState(() {
        _pinError = l10n?.pinMismatch ?? 'PINs do not match';
        _confirmPin = '';
      });
      HapticFeedback.heavyImpact();
      return;
    }

    // Save PIN (setupPin automatically enables app lock)
    final success = await _appLockService.setupPin(_pin);
    if (success) {
      // Check if biometric is available
      if (_biometricAvailable) {
        _goToPage(OnboardingPage.biometric);
      } else {
        _goToPage(OnboardingPage.complete);
      }
    } else {
      setState(() {
        _pinError = l10n?.pinSetupFailed ?? 'Failed to setup PIN';
        _pin = '';
        _confirmPin = '';
        _isConfirmingPin = false;
      });
    }
  }

  Future<void> _enableBiometric() async {
    try {
      final authenticated = await _biometricService.authenticate(
        localizedReason: 'Authenticate to enable biometric',
      );

      if (authenticated) {
        await _appLockService.setBiometricForApp(true);
        _goToPage(OnboardingPage.complete);
      }
    } catch (e) {
      // User cancelled or failed, just continue
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (index) {
            setState(() {
              _currentPageIndex = index;
            });
          },
          children: [
            _buildWelcomePage(),
            _buildFeaturesPage(),
            _buildSecurityWarningPage(),
            _buildTermsPage(),
            _buildSetupPinPage(),
            _buildConfirmPinPage(),
            _buildBiometricPage(),
            _buildCompletePage(),
          ],
        ),
      ),
    );
  }

  // ==================== Welcome Page ====================
  Widget _buildWelcomePage() {
    final l10n = S.of(context);
    final theme = Theme.of(context);
    final localeService = Provider.of<LocaleService>(context);

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Language selector at top
          Align(
            alignment: Alignment.topRight,
            child: TextButton.icon(
              onPressed: () => _showLanguageSelector(context),
              icon: Text(
                localeService.currentLanguageFlag,
                style: const TextStyle(fontSize: 20),
              ),
              label: Text(
                localeService.currentLanguageName,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lock,
              size: 80,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            l10n?.onboardingWelcome ?? 'Welcome to',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n?.appName ?? 'Secure Vault',
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n?.appTagline ?? 'Keep your files safe',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          FilledButton(
            onPressed: _nextPage,
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
            ),
            child: Text(
              l10n?.onboardingGetStarted ?? 'Get Started',
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }

  /// Show language selector bottom sheet
  void _showLanguageSelector(BuildContext context) {
    final localeService = Provider.of<LocaleService>(context, listen: false);
    final l10n = S.of(context);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    l10n?.selectLanguage ?? 'Select Language',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const SizedBox(height: 16),
                // Language options
                ...LocaleService.supportedLocales.map((locale) {
                  final langCode = locale.languageCode;
                  final isSelected =
                      localeService.currentLocale.languageCode == langCode;

                  return ListTile(
                    leading: Text(
                      LocaleService.languageFlags[langCode] ?? '',
                      style: const TextStyle(fontSize: 24),
                    ),
                    title: Text(
                      LocaleService.languageNames[langCode] ?? langCode,
                      style: TextStyle(
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(
                            Icons.check_circle,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : null,
                    onTap: () {
                      localeService.setLocale(locale);
                      Navigator.pop(sheetContext);
                    },
                  );
                }),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==================== Features Page ====================
  Widget _buildFeaturesPage() {
    final l10n = S.of(context);
    final theme = Theme.of(context);

    final features = [
      {
        'icon': Icons.shield,
        'title': l10n?.onboardingFeature1Title ?? 'Military-Grade Encryption',
        'desc': l10n?.onboardingFeature1Desc ??
            'All files are encrypted with AES-256.\nEven we cannot access your data.',
      },
      {
        'icon': Icons.cloud_off,
        'title': l10n?.onboardingFeature2Title ?? 'Stored Locally Only',
        'desc': l10n?.onboardingFeature2Desc ??
            'No data is sent to any server.\nYour data stays only on your device.',
      },
      {
        'icon': Icons.security,
        'title': l10n?.onboardingFeature3Title ?? 'Multi-Layer Protection',
        'desc': l10n?.onboardingFeature3Desc ??
            'PIN, Biometric, and\nScreenshot prevention.',
      },
      {
        'icon': Icons.folder_special,
        'title': l10n?.onboardingFeature4Title ?? 'Easy Management',
        'desc': l10n?.onboardingFeature4Desc ??
            'Create multiple vaults,\neach with its own password.',
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const SizedBox(height: 32),
          Expanded(
            child: PageView.builder(
              itemCount: _featurePageCount,
              onPageChanged: (index) {
                setState(() {
                  _featurePageIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final feature = features[index];
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        feature['icon'] as IconData,
                        size: 64,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      feature['title'] as String,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      feature['desc'] as String,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                );
              },
            ),
          ),
          // Page indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _featurePageCount,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _featurePageIndex == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _featurePageIndex == index
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: _nextPage,
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
            ),
            child: Text(
              l10n?.next ?? 'Next',
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== Security Warning Page ====================
  Widget _buildSecurityWarningPage() {
    final l10n = S.of(context);
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const SizedBox(height: 32),
          const Icon(
            Icons.warning_amber_rounded,
            size: 80,
            color: Colors.orange,
          ),
          const SizedBox(height: 24),
          Text(
            l10n?.onboardingSecurityWarningTitle ?? 'Please Read Carefully',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.block, color: Colors.red, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n?.onboardingNoRecovery ?? 'No Password Recovery',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  l10n?.onboardingNoRecoveryDesc ??
                      'If you forget your PIN or Vault password, your data cannot be recovered.',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb_outline,
                        color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      l10n?.onboardingRecommendations ?? 'Recommendations:',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildRecommendationItem(
                  Icons.edit_note,
                  l10n?.onboardingRecommend1 ??
                      'Write down your passwords and keep them safe',
                ),
                _buildRecommendationItem(
                  Icons.psychology,
                  l10n?.onboardingRecommend2 ?? 'Use passwords you can remember',
                ),
                _buildRecommendationItem(
                  Icons.backup,
                  l10n?.onboardingRecommend3 ?? 'Backup your data regularly',
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          CheckboxListTile(
            value: _acceptedRisk,
            onChanged: (value) {
              setState(() {
                _acceptedRisk = value ?? false;
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(
              l10n?.onboardingUnderstandRisk ??
                  'I understand and accept this risk',
              style: theme.textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _acceptedRisk ? _nextPage : null,
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
            ),
            child: Text(
              l10n?.next ?? 'Next',
              style: const TextStyle(fontSize: 18),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildRecommendationItem(IconData icon, String text) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: theme.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  // ==================== Terms Page ====================
  Widget _buildTermsPage() {
    final l10n = S.of(context);
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const SizedBox(height: 32),
          Icon(
            Icons.description_outlined,
            size: 64,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            l10n?.onboardingTermsTitle ?? 'Terms of Service',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTermItem(
                  '1.',
                  l10n?.onboardingTerms1 ??
                      'All data is encrypted and stored locally only',
                ),
                _buildTermItem(
                  '2.',
                  l10n?.onboardingTerms2 ?? 'We do not store your passwords',
                ),
                _buildTermItem(
                  '3.',
                  l10n?.onboardingTerms3 ??
                      'If you forget your password, we cannot help recover your data',
                ),
                _buildTermItem(
                  '4.',
                  l10n?.onboardingTerms4 ??
                      'You are responsible for remembering your passwords',
                ),
                _buildTermItem(
                  '5.',
                  l10n?.onboardingTerms5 ?? 'Regular backups are recommended',
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          CheckboxListTile(
            value: _acceptedTerms,
            onChanged: (value) {
              setState(() {
                _acceptedTerms = value ?? false;
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(
              l10n?.onboardingAcceptTerms ?? 'Accept Terms',
              style: theme.textTheme.bodyMedium,
            ),
          ),
          CheckboxListTile(
            value: _acceptedPrivacy,
            onChanged: (value) {
              setState(() {
                _acceptedPrivacy = value ?? false;
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(
              l10n?.onboardingAcceptPrivacy ?? 'Accept Privacy Policy',
              style: theme.textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: (_acceptedTerms && _acceptedPrivacy) ? _nextPage : null,
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
            ),
            child: Text(
              l10n?.onboardingAcceptAndContinue ?? 'Accept and Continue',
              style: const TextStyle(fontSize: 18),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildTermItem(String number, String text) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            number,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: theme.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  // ==================== Setup PIN Page ====================
  Widget _buildSetupPinPage() {
    final l10n = S.of(context);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const Spacer(),
          Icon(
            Icons.lock_outline,
            size: 64,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            l10n?.onboardingSetupPinTitle ?? 'Setup PIN',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n?.onboardingSetupPinDesc ??
                'This PIN will be used to open the app every time.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Text(
            l10n?.onboardingEnter6DigitPin ?? 'Enter 6-digit PIN',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          _buildPinDots(_pin),
          if (_pinError != null) ...[
            const SizedBox(height: 16),
            Text(
              _pinError!,
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ],
          const Spacer(),
          _buildNumpad(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ==================== Confirm PIN Page ====================
  Widget _buildConfirmPinPage() {
    final l10n = S.of(context);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const Spacer(),
          Icon(
            Icons.check_circle_outline,
            size: 64,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            l10n?.confirmPinTitle ?? 'Confirm PIN',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n?.onboardingConfirmPinDesc ?? 'Enter PIN again to confirm',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          _buildPinDots(_confirmPin),
          if (_pinError != null) ...[
            const SizedBox(height: 16),
            Text(
              _pinError!,
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ],
          const Spacer(),
          _buildNumpad(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildPinDots(String currentPin) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        6,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index < currentPin.length
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildNumpad() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['1', '2', '3']
              .map((digit) => _buildNumpadButton(digit))
              .toList(),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['4', '5', '6']
              .map((digit) => _buildNumpadButton(digit))
              .toList(),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['7', '8', '9']
              .map((digit) => _buildNumpadButton(digit))
              .toList(),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(width: 80), // Empty space
            _buildNumpadButton('0'),
            _buildBackspaceButton(),
          ],
        ),
      ],
    );
  }

  Widget _buildNumpadButton(String digit) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 80,
      height: 80,
      child: Material(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(40),
        child: InkWell(
          borderRadius: BorderRadius.circular(40),
          onTap: () => _onPinDigitPressed(digit),
          child: Center(
            child: Text(
              digit,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceButton() {
    final theme = Theme.of(context);
    return SizedBox(
      width: 80,
      height: 80,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(40),
          onTap: _onPinBackspace,
          child: Center(
            child: Icon(
              Icons.backspace_outlined,
              size: 28,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }

  // ==================== Biometric Page ====================
  Widget _buildBiometricPage() {
    final l10n = S.of(context);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Icon(
            Icons.fingerprint,
            size: 100,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 32),
          Text(
            l10n?.onboardingBiometricTitle(_biometricTypeName) ??
                'Enable $_biometricTypeName?',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            l10n?.onboardingBiometricDesc(_biometricTypeName) ??
                'Use $_biometricTypeName instead of PIN for convenience.\n\n(You still need to remember your PIN for emergencies)',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          FilledButton(
            onPressed: _enableBiometric,
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
            ),
            child: Text(
              l10n?.onboardingEnableBiometric(_biometricTypeName) ??
                  'Enable $_biometricTypeName',
              style: const TextStyle(fontSize: 18),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => _goToPage(OnboardingPage.complete),
            style: TextButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
            child: Text(
              l10n?.onboardingSkipForNow ?? 'Skip for now',
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ==================== Complete Page ====================
  Widget _buildCompletePage() {
    final l10n = S.of(context);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              size: 80,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            l10n?.onboardingCompleteTitle ?? 'All Set!',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb_outline,
                        color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      l10n?.onboardingTips ?? 'Tips:',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTipItem(
                  Icons.add_circle_outline,
                  l10n?.onboardingCompleteTip1 ??
                      'Create your first Vault to start storing files',
                ),
                _buildTipItem(
                  Icons.key,
                  l10n?.onboardingCompleteTip2 ??
                      'Each Vault has its own separate password',
                ),
                _buildTipItem(
                  Icons.backup,
                  l10n?.onboardingCompleteTip3 ??
                      'You can backup your data in Settings',
                ),
              ],
            ),
          ),
          const Spacer(),
          FilledButton(
            onPressed: _completeOnboarding,
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
            ),
            child: Text(
              l10n?.onboardingStartUsing ?? 'Start Using',
              style: const TextStyle(fontSize: 18),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildTipItem(IconData icon, String text) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: theme.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
