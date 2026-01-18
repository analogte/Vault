import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/utils/logger.dart';
import 'biometric_service.dart';

/// Service for managing app-level security (PIN, Auto-lock, etc.)
class AppLockService {
  static const String _tag = 'AppLockService';
  static final AppLockService _instance = AppLockService._internal();
  factory AppLockService() => _instance;
  AppLockService._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final BiometricService _biometricService = BiometricService();

  // Storage keys
  static const String _pinHashKey = 'app_pin_hash';
  static const String _pinSaltKey = 'app_pin_salt';
  static const String _appLockEnabledKey = 'app_lock_enabled';
  static const String _biometricForAppKey = 'biometric_for_app';
  static const String _autoLockTimeoutKey = 'auto_lock_timeout';
  static const String _failedAttemptsKey = 'failed_attempts';
  static const String _lockoutUntilKey = 'lockout_until';
  static const String _lastActivityKey = 'last_activity';
  static const String _rememberMeKey = 'remember_me';
  static const String _savedEmailKey = 'saved_email';

  // Security constants
  static const int maxFailedAttempts = 5;
  static const int lockoutDurationMinutes = 5;
  static const List<int> autoLockOptions = [0, 1, 5, 15, 30]; // 0 = immediate

  // In-memory state
  bool _isUnlocked = false;
  DateTime? _lastActivity;

  /// Check if app lock is enabled
  Future<bool> isAppLockEnabled() async {
    try {
      final value = await _storage.read(key: _appLockEnabledKey);
      return value == 'true';
    } catch (e) {
      AppLogger.error('isAppLockEnabled error', tag: _tag, error: e);
      return false;
    }
  }

  /// Check if PIN is set
  Future<bool> isPinSet() async {
    try {
      final pinHash = await _storage.read(key: _pinHashKey);
      return pinHash != null && pinHash.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Check if biometric is enabled for app lock
  Future<bool> isBiometricForAppEnabled() async {
    try {
      final value = await _storage.read(key: _biometricForAppKey);
      return value == 'true';
    } catch (e) {
      return false;
    }
  }

  /// Set up PIN
  Future<bool> setupPin(String pin) async {
    if (pin.length < 4 || pin.length > 6) {
      AppLogger.error('PIN must be 4-6 digits', tag: _tag);
      return false;
    }

    try {
      // Generate salt
      final salt = DateTime.now().millisecondsSinceEpoch.toString();

      // Hash PIN with salt
      final pinHash = _hashPin(pin, salt);

      // Store securely
      await _storage.write(key: _pinHashKey, value: pinHash);
      await _storage.write(key: _pinSaltKey, value: salt);
      await _storage.write(key: _appLockEnabledKey, value: 'true');

      // Reset failed attempts
      await _resetFailedAttempts();

      AppLogger.log('PIN setup successful', tag: _tag);
      return true;
    } catch (e) {
      AppLogger.error('setupPin error', tag: _tag, error: e);
      return false;
    }
  }

  /// Verify PIN
  Future<PinVerifyResult> verifyPin(String pin) async {
    try {
      // Check if locked out
      final lockoutCheck = await _checkLockout();
      if (lockoutCheck != null) {
        return lockoutCheck;
      }

      // Get stored hash and salt
      final storedHash = await _storage.read(key: _pinHashKey);
      final salt = await _storage.read(key: _pinSaltKey);

      if (storedHash == null || salt == null) {
        return PinVerifyResult(
          success: false,
          error: 'PIN ยังไม่ได้ตั้งค่า',
        );
      }

      // Verify
      final inputHash = _hashPin(pin, salt);

      if (inputHash == storedHash) {
        await _resetFailedAttempts();
        _isUnlocked = true;
        _updateLastActivity();
        AppLogger.log('PIN verified successfully', tag: _tag);
        return PinVerifyResult(success: true);
      } else {
        // Increment failed attempts
        final attemptsLeft = await _incrementFailedAttempts();

        if (attemptsLeft <= 0) {
          await _setLockout();
          return PinVerifyResult(
            success: false,
            error: 'ใส่ผิดเกินกำหนด กรุณารอ $lockoutDurationMinutes นาที',
            isLockedOut: true,
            lockoutMinutes: lockoutDurationMinutes,
          );
        }

        return PinVerifyResult(
          success: false,
          error: 'รหัส PIN ไม่ถูกต้อง',
          attemptsLeft: attemptsLeft,
        );
      }
    } catch (e) {
      AppLogger.error('verifyPin error', tag: _tag, error: e);
      return PinVerifyResult(
        success: false,
        error: 'เกิดข้อผิดพลาด กรุณาลองใหม่',
      );
    }
  }

  /// Change PIN (requires old PIN verification)
  Future<bool> changePin(String oldPin, String newPin) async {
    final verifyResult = await verifyPin(oldPin);
    if (!verifyResult.success) {
      return false;
    }

    return await setupPin(newPin);
  }

  /// Remove PIN and disable app lock
  Future<bool> removePin(String currentPin) async {
    final verifyResult = await verifyPin(currentPin);
    if (!verifyResult.success) {
      return false;
    }

    try {
      await _storage.delete(key: _pinHashKey);
      await _storage.delete(key: _pinSaltKey);
      await _storage.write(key: _appLockEnabledKey, value: 'false');
      await _storage.write(key: _biometricForAppKey, value: 'false');
      _isUnlocked = false;

      AppLogger.log('PIN removed successfully', tag: _tag);
      return true;
    } catch (e) {
      AppLogger.error('removePin error', tag: _tag, error: e);
      return false;
    }
  }

  /// Enable/disable biometric for app lock
  Future<bool> setBiometricForApp(bool enabled) async {
    try {
      if (enabled) {
        // Check if biometric is available
        final available = await _biometricService.isBiometricAvailable();
        if (!available) {
          return false;
        }
      }

      await _storage.write(key: _biometricForAppKey, value: enabled.toString());
      AppLogger.log('Biometric for app set to $enabled', tag: _tag);
      return true;
    } catch (e) {
      AppLogger.error('setBiometricForApp error', tag: _tag, error: e);
      return false;
    }
  }

  /// Authenticate with biometric for app unlock
  Future<bool> authenticateWithBiometric() async {
    try {
      final enabled = await isBiometricForAppEnabled();
      if (!enabled) {
        return false;
      }

      final authenticated = await _biometricService.authenticate(
        localizedReason: 'ยืนยันตัวตนเพื่อเปิดแอป Secure Vault',
      );

      if (authenticated) {
        await _resetFailedAttempts();
        _isUnlocked = true;
        _updateLastActivity();
        AppLogger.log('Biometric authentication successful', tag: _tag);
      }

      return authenticated;
    } catch (e) {
      AppLogger.error('authenticateWithBiometric error', tag: _tag, error: e);
      return false;
    }
  }

  // Auto-lock settings

  /// Get auto-lock timeout in minutes (0 = immediate)
  Future<int> getAutoLockTimeout() async {
    try {
      final value = await _storage.read(key: _autoLockTimeoutKey);
      return value != null ? int.parse(value) : 5; // Default 5 minutes
    } catch (e) {
      return 5;
    }
  }

  /// Set auto-lock timeout
  Future<void> setAutoLockTimeout(int minutes) async {
    await _storage.write(key: _autoLockTimeoutKey, value: minutes.toString());
  }

  /// Check if app should be locked (based on auto-lock timeout)
  Future<bool> shouldLock() async {
    if (!await isAppLockEnabled()) {
      return false;
    }

    if (!_isUnlocked) {
      return true; // Already locked
    }

    final timeout = await getAutoLockTimeout();
    if (timeout == 0) {
      return true; // Immediate lock
    }

    if (_lastActivity == null) {
      return true;
    }

    final elapsed = DateTime.now().difference(_lastActivity!).inMinutes;
    return elapsed >= timeout;
  }

  /// Update last activity timestamp
  void _updateLastActivity() {
    _lastActivity = DateTime.now();
  }

  /// Call this when user interacts with app
  void recordActivity() {
    if (_isUnlocked) {
      _updateLastActivity();
    }
  }

  /// Lock the app manually
  void lockApp() {
    _isUnlocked = false;
    _lastActivity = null;
    AppLogger.log('App locked', tag: _tag);
  }

  /// Check if app is currently unlocked
  bool get isUnlocked => _isUnlocked;

  // Remember me functionality

  /// Get remember me status
  Future<bool> isRememberMeEnabled() async {
    try {
      final value = await _storage.read(key: _rememberMeKey);
      return value == 'true';
    } catch (e) {
      return false;
    }
  }

  /// Set remember me
  Future<void> setRememberMe(bool enabled, {String? email}) async {
    await _storage.write(key: _rememberMeKey, value: enabled.toString());
    if (enabled && email != null) {
      await _storage.write(key: _savedEmailKey, value: email);
    } else if (!enabled) {
      await _storage.delete(key: _savedEmailKey);
    }
  }

  /// Get saved email
  Future<String?> getSavedEmail() async {
    try {
      if (await isRememberMeEnabled()) {
        return await _storage.read(key: _savedEmailKey);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Helper methods

  String _hashPin(String pin, String salt) {
    final bytes = utf8.encode(pin + salt);
    return sha256.convert(bytes).toString();
  }

  Future<PinVerifyResult?> _checkLockout() async {
    try {
      final lockoutUntilStr = await _storage.read(key: _lockoutUntilKey);
      if (lockoutUntilStr != null) {
        final lockoutUntil = DateTime.parse(lockoutUntilStr);
        if (DateTime.now().isBefore(lockoutUntil)) {
          final remaining = lockoutUntil.difference(DateTime.now()).inMinutes + 1;
          return PinVerifyResult(
            success: false,
            error: 'บัญชีถูกล็อค กรุณารอ $remaining นาที',
            isLockedOut: true,
            lockoutMinutes: remaining,
          );
        } else {
          // Lockout expired
          await _resetFailedAttempts();
        }
      }
    } catch (e) {
      AppLogger.error('_checkLockout error', tag: _tag, error: e);
    }
    return null;
  }

  Future<int> _incrementFailedAttempts() async {
    try {
      final attemptsStr = await _storage.read(key: _failedAttemptsKey);
      final attempts = (attemptsStr != null ? int.parse(attemptsStr) : 0) + 1;
      await _storage.write(key: _failedAttemptsKey, value: attempts.toString());
      return maxFailedAttempts - attempts;
    } catch (e) {
      return maxFailedAttempts - 1;
    }
  }

  Future<void> _setLockout() async {
    final lockoutUntil = DateTime.now().add(Duration(minutes: lockoutDurationMinutes));
    await _storage.write(key: _lockoutUntilKey, value: lockoutUntil.toIso8601String());
  }

  Future<void> _resetFailedAttempts() async {
    await _storage.delete(key: _failedAttemptsKey);
    await _storage.delete(key: _lockoutUntilKey);
  }

  /// Get remaining failed attempts
  Future<int> getRemainingAttempts() async {
    try {
      final attemptsStr = await _storage.read(key: _failedAttemptsKey);
      final attempts = attemptsStr != null ? int.parse(attemptsStr) : 0;
      return maxFailedAttempts - attempts;
    } catch (e) {
      return maxFailedAttempts;
    }
  }

  /// Clear all security data (for testing or reset)
  Future<void> clearAll() async {
    await _storage.delete(key: _pinHashKey);
    await _storage.delete(key: _pinSaltKey);
    await _storage.delete(key: _appLockEnabledKey);
    await _storage.delete(key: _biometricForAppKey);
    await _storage.delete(key: _autoLockTimeoutKey);
    await _storage.delete(key: _failedAttemptsKey);
    await _storage.delete(key: _lockoutUntilKey);
    await _storage.delete(key: _lastActivityKey);
    await _storage.delete(key: _rememberMeKey);
    await _storage.delete(key: _savedEmailKey);
    _isUnlocked = false;
    _lastActivity = null;
  }
}

/// Result of PIN verification
class PinVerifyResult {
  final bool success;
  final String? error;
  final int? attemptsLeft;
  final bool isLockedOut;
  final int? lockoutMinutes;

  PinVerifyResult({
    required this.success,
    this.error,
    this.attemptsLeft,
    this.isLockedOut = false,
    this.lockoutMinutes,
  });
}

/// Password strength levels
enum PasswordStrength {
  weak,
  fair,
  good,
  strong,
  veryStrong,
}

/// Helper class for password strength calculation
class PasswordStrengthCalculator {
  static PasswordStrength calculate(String password) {
    if (password.isEmpty) return PasswordStrength.weak;

    int score = 0;

    // Length checks
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;
    if (password.length >= 16) score++;

    // Character type checks
    if (RegExp(r'[a-z]').hasMatch(password)) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) score++;

    // Penalty for common patterns
    if (RegExp(r'(.)\1{2,}').hasMatch(password)) score--; // Repeated chars
    if (RegExp(r'(123|abc|qwerty)', caseSensitive: false).hasMatch(password)) score--;

    if (score <= 2) return PasswordStrength.weak;
    if (score <= 3) return PasswordStrength.fair;
    if (score <= 5) return PasswordStrength.good;
    if (score <= 6) return PasswordStrength.strong;
    return PasswordStrength.veryStrong;
  }

  static String getLabel(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.weak:
        return 'อ่อนมาก';
      case PasswordStrength.fair:
        return 'พอใช้';
      case PasswordStrength.good:
        return 'ดี';
      case PasswordStrength.strong:
        return 'แข็งแรง';
      case PasswordStrength.veryStrong:
        return 'แข็งแรงมาก';
    }
  }

  static double getProgress(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.weak:
        return 0.2;
      case PasswordStrength.fair:
        return 0.4;
      case PasswordStrength.good:
        return 0.6;
      case PasswordStrength.strong:
        return 0.8;
      case PasswordStrength.veryStrong:
        return 1.0;
    }
  }

  static int getColor(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.weak:
        return 0xFFE53935; // Red
      case PasswordStrength.fair:
        return 0xFFFF9800; // Orange
      case PasswordStrength.good:
        return 0xFFFFC107; // Amber
      case PasswordStrength.strong:
        return 0xFF8BC34A; // Light Green
      case PasswordStrength.veryStrong:
        return 0xFF4CAF50; // Green
    }
  }
}
