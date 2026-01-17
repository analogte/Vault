import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:safe_device/safe_device.dart';
import '../core/utils/logger.dart';

/// Service for checking app integrity and detecting tampering
/// Detects debug mode, emulators, and other suspicious environments
class AppIntegrityService {
  static const String _tag = 'AppIntegrityService';
  static final AppIntegrityService _instance = AppIntegrityService._internal();
  factory AppIntegrityService() => _instance;
  AppIntegrityService._internal();

  /// Check if app is running in a safe environment
  Future<IntegrityResult> checkIntegrity() async {
    if (kIsWeb) {
      // Web has limited checks
      return IntegrityResult(
        isDebugMode: kDebugMode,
        isEmulator: false,
        isOnExternalStorage: false,
        isRealDevice: true,
        isSafe: !kDebugMode,
        warnings: kDebugMode ? ['Running in debug mode'] : [],
      );
    }

    final warnings = <String>[];

    try {
      // Check using safe_device package
      final isSafeDevice = await SafeDevice.isSafeDevice;
      final isRealDevice = await SafeDevice.isRealDevice;
      final isJailBroken = await SafeDevice.isJailBroken;
      final isOnExternalStorage = await SafeDevice.isOnExternalStorage;
      final isDevelopmentModeEnable = await SafeDevice.isDevelopmentModeEnable;

      // Collect warnings
      if (!isRealDevice) {
        warnings.add('Running on emulator/simulator');
      }
      if (isJailBroken) {
        warnings.add('Device is rooted/jailbroken');
      }
      if (isOnExternalStorage) {
        warnings.add('App installed on external storage');
      }
      if (isDevelopmentModeEnable) {
        warnings.add('Developer mode enabled');
      }
      if (kDebugMode) {
        warnings.add('Running in debug mode');
      }

      final result = IntegrityResult(
        isDebugMode: kDebugMode,
        isEmulator: !isRealDevice,
        isOnExternalStorage: isOnExternalStorage,
        isRealDevice: isRealDevice,
        isDeveloperModeEnabled: isDevelopmentModeEnable,
        isRooted: isJailBroken,
        isSafe: isSafeDevice && !kDebugMode,
        warnings: warnings,
      );

      _logResult(result);
      return result;
    } catch (e) {
      AppLogger.error('Integrity check failed', tag: _tag, error: e);

      // Return degraded result on error
      return IntegrityResult(
        isDebugMode: kDebugMode,
        isEmulator: false,
        isOnExternalStorage: false,
        isRealDevice: true,
        isSafe: !kDebugMode,
        warnings: ['Integrity check partially failed: $e'],
      );
    }
  }

  /// Quick check - is the environment safe for sensitive operations?
  Future<bool> isSafeEnvironment() async {
    if (kIsWeb) return !kDebugMode;

    try {
      return await SafeDevice.isSafeDevice;
    } catch (e) {
      AppLogger.error('Safe device check failed', tag: _tag, error: e);
      return true; // Assume safe if check fails
    }
  }

  /// Check if running on emulator
  Future<bool> isEmulator() async {
    if (kIsWeb) return false;

    try {
      return !(await SafeDevice.isRealDevice);
    } catch (e) {
      // Fallback manual check
      return _manualEmulatorCheck();
    }
  }

  /// Manual emulator detection as fallback
  bool _manualEmulatorCheck() {
    if (Platform.isAndroid) {
      // Check common Android emulator indicators
      final brand = Platform.environment['ANDROID_BRAND'] ?? '';
      final model = Platform.environment['ANDROID_MODEL'] ?? '';
      final product = Platform.environment['ANDROID_PRODUCT'] ?? '';

      final emulatorIndicators = [
        'google_sdk',
        'sdk_gphone',
        'vbox',
        'emulator',
        'goldfish',
        'ranchu',
        'generic',
        'sdk',
        'genymotion',
      ];

      for (final indicator in emulatorIndicators) {
        if (brand.toLowerCase().contains(indicator) ||
            model.toLowerCase().contains(indicator) ||
            product.toLowerCase().contains(indicator)) {
          return true;
        }
      }
    }

    return false;
  }

  /// Check if USB debugging is enabled
  Future<bool> isUsbDebuggingEnabled() async {
    if (kIsWeb) return false;

    try {
      return await SafeDevice.isDevelopmentModeEnable;
    } catch (e) {
      return false;
    }
  }

  /// Log integrity result
  void _logResult(IntegrityResult result) {
    if (result.isSafe) {
      AppLogger.log('Integrity check passed', tag: _tag);
    } else {
      AppLogger.warning(
        'Integrity check found issues: ${result.warnings.join(", ")}',
        tag: _tag,
      );
    }
  }

  /// Get security recommendations based on integrity result
  List<SecurityRecommendation> getRecommendations(IntegrityResult result) {
    final recommendations = <SecurityRecommendation>[];

    if (result.isEmulator) {
      recommendations.add(SecurityRecommendation(
        title: 'Running on Emulator',
        description: 'App should be used on a real device for maximum security.',
        severity: RecommendationSeverity.warning,
      ));
    }

    if (result.isRooted ?? false) {
      recommendations.add(SecurityRecommendation(
        title: 'Device is Rooted/Jailbroken',
        description: 'Rooted devices are vulnerable to security attacks. Consider using a non-rooted device.',
        severity: RecommendationSeverity.critical,
      ));
    }

    if (result.isDeveloperModeEnabled ?? false) {
      recommendations.add(SecurityRecommendation(
        title: 'Developer Mode Enabled',
        description: 'Developer mode increases security risk. Consider disabling it.',
        severity: RecommendationSeverity.warning,
      ));
    }

    if (result.isOnExternalStorage) {
      recommendations.add(SecurityRecommendation(
        title: 'App on External Storage',
        description: 'Apps on external storage are more vulnerable. Install on internal storage.',
        severity: RecommendationSeverity.warning,
      ));
    }

    if (result.isDebugMode) {
      recommendations.add(SecurityRecommendation(
        title: 'Debug Mode',
        description: 'App is running in debug mode. Use release build for production.',
        severity: RecommendationSeverity.info,
      ));
    }

    return recommendations;
  }
}

/// Result of integrity check
class IntegrityResult {
  final bool isDebugMode;
  final bool isEmulator;
  final bool isOnExternalStorage;
  final bool isRealDevice;
  final bool? isDeveloperModeEnabled;
  final bool? isRooted;
  final bool isSafe;
  final List<String> warnings;

  IntegrityResult({
    required this.isDebugMode,
    required this.isEmulator,
    required this.isOnExternalStorage,
    required this.isRealDevice,
    this.isDeveloperModeEnabled,
    this.isRooted,
    required this.isSafe,
    required this.warnings,
  });

  bool get hasWarnings => warnings.isNotEmpty;
}

/// Security recommendation
class SecurityRecommendation {
  final String title;
  final String description;
  final RecommendationSeverity severity;

  SecurityRecommendation({
    required this.title,
    required this.description,
    required this.severity,
  });
}

/// Recommendation severity levels
enum RecommendationSeverity {
  info,
  warning,
  critical,
}
