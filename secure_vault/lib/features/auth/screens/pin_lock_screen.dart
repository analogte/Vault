import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/app_lock_service.dart';
import '../../../services/biometric_service.dart';

enum PinScreenMode {
  unlock,      // Unlock app
  setup,       // First time setup
  confirm,     // Confirm new PIN
  change,      // Change existing PIN
  verify,      // Verify before action
}

class PinLockScreen extends StatefulWidget {
  final PinScreenMode mode;
  final VoidCallback? onSuccess;
  final String? title;
  final String? subtitle;

  const PinLockScreen({
    super.key,
    this.mode = PinScreenMode.unlock,
    this.onSuccess,
    this.title,
    this.subtitle,
  });

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen>
    with SingleTickerProviderStateMixin {
  final AppLockService _appLockService = AppLockService();
  final BiometricService _biometricService = BiometricService();

  String _pin = '';
  String _confirmPin = '';
  bool _isConfirmStep = false;
  bool _isLoading = false;
  String? _errorMessage;
  int? _attemptsLeft;
  bool _isLockedOut = false;
  int? _lockoutMinutes;
  bool _biometricAvailable = false;
  bool _biometricEnabled = false;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  static const int pinLength = 6;

  @override
  void initState() {
    super.initState();
    _initShakeAnimation();
    _checkBiometric();
  }

  void _initShakeAnimation() {
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 24)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _shakeController.reverse();
        }
      });
  }

  Future<void> _checkBiometric() async {
    if (widget.mode == PinScreenMode.unlock) {
      final available = await _biometricService.isBiometricAvailable();
      final enabled = await _appLockService.isBiometricForAppEnabled();

      setState(() {
        _biometricAvailable = available;
        _biometricEnabled = enabled;
      });

      // Auto-trigger biometric on unlock
      if (available && enabled) {
        _authenticateWithBiometric();
      }
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  String _getTitle(S? l10n) {
    if (widget.title != null) return widget.title!;

    switch (widget.mode) {
      case PinScreenMode.unlock:
        return l10n?.unlock ?? 'Unlock';
      case PinScreenMode.setup:
        return _isConfirmStep
            ? (l10n?.confirmPinTitle ?? 'Confirm PIN')
            : (l10n?.setupPinTitle ?? 'Setup PIN');
      case PinScreenMode.confirm:
        return l10n?.confirmPinTitle ?? 'Confirm PIN';
      case PinScreenMode.change:
        return _isConfirmStep
            ? (l10n?.confirmNewPinTitle ?? 'Confirm New PIN')
            : (l10n?.enterCurrentPinTitle ?? 'Enter Current PIN');
      case PinScreenMode.verify:
        return l10n?.verifyIdentity ?? 'Verify Identity';
    }
  }

  String _getSubtitle(S? l10n) {
    if (widget.subtitle != null) return widget.subtitle!;

    switch (widget.mode) {
      case PinScreenMode.unlock:
        return l10n?.enter6DigitPinToUnlock ?? 'Enter 6-digit PIN to open the app';
      case PinScreenMode.setup:
        return _isConfirmStep
            ? (l10n?.enterPinAgainToConfirm ?? 'Enter PIN again to confirm')
            : (l10n?.enter6DigitPinToSetup ?? 'Create a 6-digit PIN for security');
      case PinScreenMode.confirm:
        return l10n?.enterPinAgainToConfirm ?? 'Enter PIN again to confirm';
      case PinScreenMode.change:
        return _isConfirmStep
            ? (l10n?.enterNewPinAgain ?? 'Enter new PIN again')
            : (l10n?.enterYourCurrentPin ?? 'Enter your current PIN');
      case PinScreenMode.verify:
        return l10n?.enterPinToContinue ?? 'Enter PIN to continue';
    }
  }

  void _onKeyPressed(String key) {
    if (_isLoading || _isLockedOut) return;

    HapticFeedback.lightImpact();

    setState(() {
      _errorMessage = null;

      if (key == 'delete') {
        if (_pin.isNotEmpty) {
          _pin = _pin.substring(0, _pin.length - 1);
        }
      } else if (key == 'biometric') {
        _authenticateWithBiometric();
      } else {
        if (_pin.length < pinLength) {
          _pin += key;

          if (_pin.length == pinLength) {
            _handlePinComplete();
          }
        }
      }
    });
  }

  Future<void> _handlePinComplete() async {
    setState(() => _isLoading = true);

    // Small delay for visual feedback
    await Future.delayed(const Duration(milliseconds: 200));

    switch (widget.mode) {
      case PinScreenMode.unlock:
      case PinScreenMode.verify:
        await _verifyPin();
        break;
      case PinScreenMode.setup:
        _handleSetup();
        break;
      case PinScreenMode.confirm:
        await _verifyPin();
        break;
      case PinScreenMode.change:
        if (_isConfirmStep) {
          _handleSetup();
        } else {
          await _verifyPinForChange();
        }
        break;
    }

    setState(() => _isLoading = false);
  }

  Future<void> _verifyPin() async {
    final l10n = S.of(context);
    final result = await _appLockService.verifyPin(_pin);

    if (result.success) {
      HapticFeedback.mediumImpact();
      widget.onSuccess?.call();
    } else {
      _showError(result.error ?? l10n?.wrongPin ?? 'Wrong PIN');
      _attemptsLeft = result.attemptsLeft;
      _isLockedOut = result.isLockedOut;
      _lockoutMinutes = result.lockoutMinutes;
      _pin = '';
      _shakeController.forward();
    }
  }

  Future<void> _verifyPinForChange() async {
    final l10n = S.of(context);
    final result = await _appLockService.verifyPin(_pin);

    if (result.success) {
      setState(() {
        _confirmPin = _pin;
        _pin = '';
        _isConfirmStep = true;
      });
    } else {
      _showError(result.error ?? l10n?.wrongPin ?? 'Wrong PIN');
      _attemptsLeft = result.attemptsLeft;
      _isLockedOut = result.isLockedOut;
      _lockoutMinutes = result.lockoutMinutes;
      _pin = '';
      _shakeController.forward();
    }
  }

  void _handleSetup() {
    final l10n = S.of(context);
    if (!_isConfirmStep) {
      // First entry - save and ask for confirmation
      setState(() {
        _confirmPin = _pin;
        _pin = '';
        _isConfirmStep = true;
      });
    } else {
      // Second entry - verify match
      if (_pin == _confirmPin) {
        _savePinAndComplete();
      } else {
        _showError(l10n?.pinMismatch ?? 'PINs do not match');
        setState(() {
          _pin = '';
          _confirmPin = '';
          _isConfirmStep = false;
        });
        _shakeController.forward();
      }
    }
  }

  Future<void> _savePinAndComplete() async {
    final l10n = S.of(context);
    final success = await _appLockService.setupPin(_pin);

    if (success) {
      HapticFeedback.mediumImpact();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n?.pinSetupSuccess ?? 'PIN setup successful'),
            backgroundColor: Colors.green,
          ),
        );
      }

      widget.onSuccess?.call();
    } else {
      _showError(l10n?.pinSetupFailed ?? 'Unable to setup PIN');
    }
  }

  void _showError(String message) {
    HapticFeedback.heavyImpact();
    setState(() {
      _errorMessage = message;
    });
  }

  Future<void> _authenticateWithBiometric() async {
    if (!_biometricAvailable || !_biometricEnabled) return;

    final success = await _appLockService.authenticateWithBiometric();

    if (success) {
      HapticFeedback.mediumImpact();
      widget.onSuccess?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = S.of(context);

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Expanded(
              flex: 2,
              child: _buildHeader(theme, l10n),
            ),

            // PIN dots
            AnimatedBuilder(
              animation: _shakeAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(_shakeAnimation.value, 0),
                  child: child,
                );
              },
              child: _buildPinDots(theme),
            ),

            // Error message
            _buildErrorMessage(l10n),

            // Number pad
            Expanded(
              flex: 4,
              child: _buildNumberPad(theme, isDark),
            ),

            // Bottom actions
            _buildBottomActions(theme, l10n),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, S? l10n) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Lock icon with animation
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 600),
          curve: Curves.elasticOut,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: child,
            );
          },
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(
              _isLockedOut ? Icons.lock_clock : Icons.lock,
              size: 48,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Title
        Text(
          _getTitle(l10n),
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        // Subtitle
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            _getSubtitle(l10n),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildPinDots(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(pinLength, (index) {
          final isFilled = index < _pin.length;
          final isCurrentDot = index == _pin.length;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 8),
            width: isFilled ? 20 : 16,
            height: isFilled ? 20 : 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isFilled
                  ? theme.colorScheme.primary
                  : Colors.transparent,
              border: Border.all(
                color: isCurrentDot
                    ? theme.colorScheme.primary
                    : isFilled
                        ? theme.colorScheme.primary
                        : Colors.grey[400]!,
                width: isCurrentDot ? 2 : 1.5,
              ),
              boxShadow: isFilled
                  ? [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.4),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildErrorMessage(S? l10n) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _errorMessage != null || _attemptsLeft != null ? 60 : 0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isLockedOut ? Icons.timer : Icons.warning_amber_rounded,
                    color: Colors.red,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          if (_attemptsLeft != null && _attemptsLeft! > 0 && !_isLockedOut)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                l10n?.attemptsRemaining(_attemptsLeft!) ?? '$_attemptsLeft attempts remaining',
                style: TextStyle(
                  color: Colors.orange[700],
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNumberPad(ThemeData theme, bool isDark) {
    final buttonColor = isDark ? Colors.grey[800] : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildNumberRow(['1', '2', '3'], buttonColor!, textColor, theme),
          const SizedBox(height: 16),
          _buildNumberRow(['4', '5', '6'], buttonColor, textColor, theme),
          const SizedBox(height: 16),
          _buildNumberRow(['7', '8', '9'], buttonColor, textColor, theme),
          const SizedBox(height: 16),
          _buildBottomRow(buttonColor, textColor, theme),
        ],
      ),
    );
  }

  Widget _buildNumberRow(
    List<String> numbers,
    Color buttonColor,
    Color textColor,
    ThemeData theme,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: numbers.map((number) {
        return _buildNumberButton(number, buttonColor, textColor, theme);
      }).toList(),
    );
  }

  Widget _buildBottomRow(Color buttonColor, Color textColor, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Biometric or empty
        _biometricAvailable && _biometricEnabled && widget.mode == PinScreenMode.unlock
            ? _buildBiometricButton(theme)
            : const SizedBox(width: 72),

        // 0
        _buildNumberButton('0', buttonColor, textColor, theme),

        // Delete
        _buildDeleteButton(theme),
      ],
    );
  }

  Widget _buildNumberButton(
    String number,
    Color buttonColor,
    Color textColor,
    ThemeData theme,
  ) {
    return Material(
      color: buttonColor,
      borderRadius: BorderRadius.circular(36),
      elevation: 2,
      shadowColor: Colors.black26,
      child: InkWell(
        onTap: _isLoading || _isLockedOut ? null : () => _onKeyPressed(number),
        borderRadius: BorderRadius.circular(36),
        child: Container(
          width: 72,
          height: 72,
          alignment: Alignment.center,
          child: Text(
            number,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w500,
              color: _isLockedOut ? Colors.grey : textColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton(ThemeData theme) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _pin.isEmpty || _isLoading || _isLockedOut
            ? null
            : () => _onKeyPressed('delete'),
        borderRadius: BorderRadius.circular(36),
        child: Container(
          width: 72,
          height: 72,
          alignment: Alignment.center,
          child: Icon(
            Icons.backspace_outlined,
            size: 28,
            color: _pin.isEmpty || _isLockedOut
                ? Colors.grey[400]
                : theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildBiometricButton(ThemeData theme) {
    return Material(
      color: theme.colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(36),
      child: InkWell(
        onTap: _isLoading || _isLockedOut ? null : _authenticateWithBiometric,
        borderRadius: BorderRadius.circular(36),
        child: Container(
          width: 72,
          height: 72,
          alignment: Alignment.center,
          child: Icon(
            Icons.fingerprint,
            size: 36,
            color: _isLockedOut
                ? Colors.grey
                : theme.colorScheme.onPrimaryContainer,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActions(ThemeData theme, S? l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          if (widget.mode == PinScreenMode.setup && !_isConfirmStep)
            Text(
              l10n?.pinUsedToUnlock ?? 'PIN will be used to unlock the app',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),

          if (widget.mode == PinScreenMode.unlock && _isLockedOut)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                l10n?.waitMinutes(_lockoutMinutes ?? 0) ?? 'Wait $_lockoutMinutes minutes then try again',
                style: TextStyle(
                  color: Colors.orange[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
    );
  }
}
