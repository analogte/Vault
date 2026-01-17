import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/utils/logger.dart';

/// Service for managing app security settings and auto-lock
class SecurityService {
  static const String _tag = 'SecurityService';
  static final SecurityService _instance = SecurityService._internal();
  factory SecurityService() => _instance;
  SecurityService._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Storage keys
  static const String _autoLockEnabledKey = 'auto_lock_enabled';
  static const String _autoLockTimeoutKey = 'auto_lock_timeout'; // in seconds
  static const String _lockOnBackgroundKey = 'lock_on_background';
  static const String _screenshotPreventionKey = 'screenshot_prevention';

  // Auto-lock state
  Timer? _autoLockTimer;
  DateTime? _lastActivity;
  bool _isLocked = false;
  int? _currentOpenVaultId;

  // Callbacks
  Function()? onAutoLock;

  /// Initialize security service
  Future<void> initialize() async {
    _lastActivity = DateTime.now();
    AppLogger.log('Initialized', tag: _tag);
  }

  /// Check if auto-lock is enabled
  Future<bool> isAutoLockEnabled() async {
    try {
      final value = await _storage.read(key: _autoLockEnabledKey);
      return value == 'true';
    } catch (e) {
      return true; // Default to enabled for security
    }
  }

  /// Enable/disable auto-lock
  Future<void> setAutoLockEnabled(bool enabled) async {
    await _storage.write(key: _autoLockEnabledKey, value: enabled.toString());
    if (enabled) {
      _startAutoLockTimer();
    } else {
      _stopAutoLockTimer();
    }
  }

  /// Get auto-lock timeout in seconds
  Future<int> getAutoLockTimeout() async {
    try {
      final value = await _storage.read(key: _autoLockTimeoutKey);
      return int.tryParse(value ?? '') ?? 60; // Default 60 seconds
    } catch (e) {
      return 60;
    }
  }

  /// Set auto-lock timeout
  Future<void> setAutoLockTimeout(int seconds) async {
    await _storage.write(key: _autoLockTimeoutKey, value: seconds.toString());
    _restartAutoLockTimer();
  }

  /// Check if lock on background is enabled
  Future<bool> isLockOnBackgroundEnabled() async {
    try {
      final value = await _storage.read(key: _lockOnBackgroundKey);
      return value != 'false'; // Default to true for security
    } catch (e) {
      return true;
    }
  }

  /// Enable/disable lock on background
  Future<void> setLockOnBackgroundEnabled(bool enabled) async {
    await _storage.write(key: _lockOnBackgroundKey, value: enabled.toString());
  }

  /// Check if screenshot prevention is enabled
  Future<bool> isScreenshotPreventionEnabled() async {
    try {
      final value = await _storage.read(key: _screenshotPreventionKey);
      return value != 'false'; // Default to true for security
    } catch (e) {
      return true;
    }
  }

  /// Enable/disable screenshot prevention
  Future<void> setScreenshotPreventionEnabled(bool enabled) async {
    await _storage.write(key: _screenshotPreventionKey, value: enabled.toString());
  }

  /// Record user activity (resets auto-lock timer)
  void recordActivity() {
    _lastActivity = DateTime.now();
    _restartAutoLockTimer();
  }

  /// Set current open vault
  void setCurrentVault(int? vaultId) {
    _currentOpenVaultId = vaultId;
    if (vaultId != null) {
      _startAutoLockTimer();
    } else {
      _stopAutoLockTimer();
    }
  }

  /// Get current open vault id
  int? get currentVaultId => _currentOpenVaultId;

  /// Check if app is locked
  bool get isLocked => _isLocked;

  /// Lock the app
  void lock() {
    _isLocked = true;
    _currentOpenVaultId = null;
    _stopAutoLockTimer();
    onAutoLock?.call();
    AppLogger.log('App locked', tag: _tag);
  }

  /// Unlock the app
  void unlock() {
    _isLocked = false;
    _lastActivity = DateTime.now();
    AppLogger.log('App unlocked', tag: _tag);
  }

  /// Called when app goes to background
  Future<void> onAppPaused() async {
    final lockOnBackground = await isLockOnBackgroundEnabled();
    if (lockOnBackground && _currentOpenVaultId != null) {
      AppLogger.log('App paused - locking vault', tag: _tag);
      lock();
    }
  }

  /// Called when app comes to foreground
  Future<void> onAppResumed() async {
    // Check if we need to re-authenticate
    if (_isLocked && _currentOpenVaultId != null) {
      // Trigger re-authentication through callback
      onAutoLock?.call();
    }
  }

  /// Start auto-lock timer
  Future<void> _startAutoLockTimer() async {
    _stopAutoLockTimer();

    final enabled = await isAutoLockEnabled();
    if (!enabled) return;

    final timeout = await getAutoLockTimeout();
    AppLogger.log('Starting auto-lock timer: ${timeout}s', tag: _tag);

    _autoLockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_lastActivity != null && _currentOpenVaultId != null) {
        final elapsed = DateTime.now().difference(_lastActivity!).inSeconds;
        if (elapsed >= timeout) {
          AppLogger.log('Auto-lock timeout reached', tag: _tag);
          lock();
        }
      }
    });
  }

  /// Stop auto-lock timer
  void _stopAutoLockTimer() {
    _autoLockTimer?.cancel();
    _autoLockTimer = null;
  }

  /// Restart auto-lock timer
  void _restartAutoLockTimer() {
    if (_currentOpenVaultId != null) {
      _startAutoLockTimer();
    }
  }

  /// Get available timeout options
  List<AutoLockOption> getTimeoutOptions() {
    return [
      AutoLockOption(seconds: 30, label: '30 วินาที'),
      AutoLockOption(seconds: 60, label: '1 นาที'),
      AutoLockOption(seconds: 120, label: '2 นาที'),
      AutoLockOption(seconds: 300, label: '5 นาที'),
      AutoLockOption(seconds: 600, label: '10 นาที'),
      AutoLockOption(seconds: 1800, label: '30 นาที'),
    ];
  }

  /// Dispose
  void dispose() {
    _stopAutoLockTimer();
  }
}

/// Auto-lock timeout option
class AutoLockOption {
  final int seconds;
  final String label;

  AutoLockOption({required this.seconds, required this.label});
}
