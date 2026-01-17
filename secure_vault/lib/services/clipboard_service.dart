import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/utils/logger.dart';

/// Service for managing clipboard with automatic clearing
/// Clears sensitive data from clipboard after a configurable timeout
class ClipboardService {
  static const String _tag = 'ClipboardService';
  static final ClipboardService _instance = ClipboardService._internal();
  factory ClipboardService() => _instance;
  ClipboardService._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Storage keys
  static const String _clipboardTimeoutKey = 'clipboard_timeout';
  static const String _autoClearEnabledKey = 'clipboard_auto_clear';

  // Timer for auto-clear
  Timer? _clearTimer;

  // Default timeout in seconds
  static const int defaultTimeout = 30;

  /// Copy sensitive text to clipboard with auto-clear
  Future<void> copyWithAutoClear(String text) async {
    try {
      // Copy to clipboard
      await Clipboard.setData(ClipboardData(text: text));
      AppLogger.log('Text copied to clipboard', tag: _tag);

      // Check if auto-clear is enabled
      final autoClearEnabled = await isAutoClearEnabled();
      if (autoClearEnabled) {
        _scheduleClear();
      }
    } catch (e) {
      AppLogger.error('Failed to copy to clipboard', tag: _tag, error: e);
      rethrow;
    }
  }

  /// Copy text without auto-clear (for non-sensitive data)
  Future<void> copyWithoutAutoClear(String text) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      _cancelClearTimer();
    } catch (e) {
      AppLogger.error('Failed to copy to clipboard', tag: _tag, error: e);
      rethrow;
    }
  }

  /// Schedule clipboard clear after timeout
  void _scheduleClear() async {
    _cancelClearTimer();

    final timeout = await getTimeout();
    AppLogger.log('Scheduling clipboard clear in ${timeout}s', tag: _tag);

    _clearTimer = Timer(Duration(seconds: timeout), () {
      _clearClipboard();
    });
  }

  /// Cancel any pending clear timer
  void _cancelClearTimer() {
    if (_clearTimer != null && _clearTimer!.isActive) {
      _clearTimer!.cancel();
      _clearTimer = null;
    }
  }

  /// Clear clipboard immediately
  Future<void> _clearClipboard() async {
    try {
      await Clipboard.setData(const ClipboardData(text: ''));
      AppLogger.log('Clipboard cleared', tag: _tag);
    } catch (e) {
      AppLogger.error('Failed to clear clipboard', tag: _tag, error: e);
    }
  }

  /// Manually clear clipboard
  Future<void> clearNow() async {
    _cancelClearTimer();
    await _clearClipboard();
  }

  /// Check if auto-clear is enabled
  Future<bool> isAutoClearEnabled() async {
    try {
      final value = await _storage.read(key: _autoClearEnabledKey);
      return value != 'false'; // Default to true
    } catch (e) {
      return true;
    }
  }

  /// Enable/disable auto-clear
  Future<void> setAutoClearEnabled(bool enabled) async {
    await _storage.write(key: _autoClearEnabledKey, value: enabled.toString());
    AppLogger.log('Auto-clear ${enabled ? 'enabled' : 'disabled'}', tag: _tag);
  }

  /// Get timeout in seconds
  Future<int> getTimeout() async {
    try {
      final value = await _storage.read(key: _clipboardTimeoutKey);
      return int.tryParse(value ?? '') ?? defaultTimeout;
    } catch (e) {
      return defaultTimeout;
    }
  }

  /// Set timeout in seconds
  Future<void> setTimeout(int seconds) async {
    if (seconds < 5 || seconds > 300) {
      throw ArgumentError('Timeout must be between 5 and 300 seconds');
    }
    await _storage.write(key: _clipboardTimeoutKey, value: seconds.toString());
    AppLogger.log('Clipboard timeout set to ${seconds}s', tag: _tag);
  }

  /// Get available timeout options
  List<ClipboardTimeoutOption> getTimeoutOptions() {
    return [
      ClipboardTimeoutOption(seconds: 10, label: '10 วินาที'),
      ClipboardTimeoutOption(seconds: 15, label: '15 วินาที'),
      ClipboardTimeoutOption(seconds: 30, label: '30 วินาที'),
      ClipboardTimeoutOption(seconds: 45, label: '45 วินาที'),
      ClipboardTimeoutOption(seconds: 60, label: '1 นาที'),
      ClipboardTimeoutOption(seconds: 120, label: '2 นาที'),
    ];
  }

  /// Dispose service
  void dispose() {
    _cancelClearTimer();
  }
}

/// Clipboard timeout option
class ClipboardTimeoutOption {
  final int seconds;
  final String label;

  ClipboardTimeoutOption({required this.seconds, required this.label});
}
