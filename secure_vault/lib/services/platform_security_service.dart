import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import '../core/utils/logger.dart';

/// Service for platform-specific security features
class PlatformSecurityService {
  static const String _tag = 'PlatformSecurity';

  static final PlatformSecurityService _instance =
      PlatformSecurityService._internal();
  factory PlatformSecurityService() => _instance;
  PlatformSecurityService._internal();

  static const MethodChannel _channel = MethodChannel('com.securevault/security');

  /// Enable screenshot prevention (Android: FLAG_SECURE)
  Future<bool> enableScreenshotPrevention() async {
    if (kIsWeb) return false;

    try {
      final result = await _channel.invokeMethod('enableScreenshotPrevention');
      AppLogger.log('Screenshot prevention enabled: $result', tag: _tag);
      return result == true;
    } on PlatformException catch (e) {
      AppLogger.error('Enable screenshot prevention error: ${e.message}', tag: _tag);
      return false;
    } on MissingPluginException {
      // Platform doesn't support this (e.g., iOS, desktop)
      AppLogger.log('Screenshot prevention not supported on this platform', tag: _tag);
      return false;
    }
  }

  /// Disable screenshot prevention
  Future<bool> disableScreenshotPrevention() async {
    if (kIsWeb) return false;

    try {
      final result = await _channel.invokeMethod('disableScreenshotPrevention');
      AppLogger.log('Screenshot prevention disabled: $result', tag: _tag);
      return result == true;
    } on PlatformException catch (e) {
      AppLogger.error('Disable screenshot prevention error: ${e.message}', tag: _tag);
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  /// Check if screenshot prevention is currently enabled
  Future<bool> isScreenshotPreventionEnabled() async {
    if (kIsWeb) return false;

    try {
      final result =
          await _channel.invokeMethod('isScreenshotPreventionEnabled');
      return result == true;
    } on PlatformException catch (e) {
      AppLogger.error('Check screenshot prevention error: ${e.message}', tag: _tag);
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  /// Apply security settings based on user preferences
  Future<void> applySecuritySettings({required bool preventScreenshots}) async {
    if (preventScreenshots) {
      await enableScreenshotPrevention();
    } else {
      await disableScreenshotPrevention();
    }
  }
}
