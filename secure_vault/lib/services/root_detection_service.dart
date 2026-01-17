import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:safe_device/safe_device.dart';
import '../core/utils/logger.dart';

/// Service for detecting rooted/jailbroken devices
/// Provides security checks to prevent app usage on compromised devices
class RootDetectionService {
  static const String _tag = 'RootDetectionService';
  static final RootDetectionService _instance = RootDetectionService._internal();
  factory RootDetectionService() => _instance;
  RootDetectionService._internal();

  /// Check if device is rooted/jailbroken
  /// Returns true if device is compromised
  Future<bool> isDeviceCompromised() async {
    // Skip detection on web
    if (kIsWeb) {
      AppLogger.log('Web platform - skipping root detection', tag: _tag);
      return false;
    }

    try {
      // Use safe_device package for root/jailbreak detection
      final isJailbroken = await SafeDevice.isJailBroken;

      if (isJailbroken) {
        AppLogger.warning('Device is rooted/jailbroken!', tag: _tag);
        return true;
      }

      // Additional manual checks
      final hasManualIndicators = await _performManualChecks();
      if (hasManualIndicators) {
        AppLogger.warning('Manual root indicators detected!', tag: _tag);
        return true;
      }

      AppLogger.log('Device is clean', tag: _tag);
      return false;
    } catch (e) {
      AppLogger.error('Root detection error', tag: _tag, error: e);
      // Return false to allow app usage if detection fails
      return false;
    }
  }

  /// Check if developer mode / USB debugging is enabled
  Future<bool> isDeveloperModeEnabled() async {
    if (kIsWeb) return false;

    try {
      final developerMode = await SafeDevice.isDevelopmentModeEnable;
      if (developerMode) {
        AppLogger.warning('Developer mode is enabled', tag: _tag);
      }
      return developerMode;
    } catch (e) {
      AppLogger.error('Developer mode check failed', tag: _tag, error: e);
      return false;
    }
  }

  /// Perform additional manual root/jailbreak checks
  Future<bool> _performManualChecks() async {
    if (Platform.isAndroid) {
      return _checkAndroidRoot();
    } else if (Platform.isIOS) {
      return _checkiOSJailbreak();
    }
    return false;
  }

  /// Check for common Android root indicators
  Future<bool> _checkAndroidRoot() async {
    // Common su binary paths
    final suPaths = [
      '/system/app/Superuser.apk',
      '/sbin/su',
      '/system/bin/su',
      '/system/xbin/su',
      '/data/local/xbin/su',
      '/data/local/bin/su',
      '/system/sd/xbin/su',
      '/system/bin/failsafe/su',
      '/data/local/su',
      '/su/bin/su',
    ];

    // Magisk indicators
    final magiskPaths = [
      '/sbin/.magisk',
      '/sbin/.core',
      '/data/adb/magisk',
      '/data/adb/modules',
    ];

    // Check for su binary
    for (final path in suPaths) {
      if (await _fileExists(path)) {
        AppLogger.warning('Found su binary at: $path', tag: _tag);
        return true;
      }
    }

    // Check for Magisk
    for (final path in magiskPaths) {
      if (await _fileExists(path)) {
        AppLogger.warning('Found Magisk indicator at: $path', tag: _tag);
        return true;
      }
    }

    // Note: Checking for installed dangerous apps (like Magisk, SuperSU)
    // requires additional platform channel implementation
    // This is a simplified check based on file system indicators

    return false;
  }

  /// Check for common iOS jailbreak indicators
  Future<bool> _checkiOSJailbreak() async {
    // Common jailbreak paths
    final jailbreakPaths = [
      '/Applications/Cydia.app',
      '/Applications/Sileo.app',
      '/Applications/Zebra.app',
      '/Library/MobileSubstrate/MobileSubstrate.dylib',
      '/bin/bash',
      '/usr/sbin/sshd',
      '/etc/apt',
      '/private/var/lib/apt/',
      '/usr/bin/ssh',
      '/var/cache/apt',
      '/var/lib/cydia',
      '/var/log/syslog',
      '/var/tmp/cydia.log',
      '/bin/sh',
      '/usr/libexec/sftp-server',
      '/private/var/stash',
      '/private/var/mobile/Library/SBSettings/Themes',
      '/System/Library/LaunchDaemons/com.ikey.bbot.plist',
      '/System/Library/LaunchDaemons/com.saurik.Cydia.Startup.plist',
    ];

    for (final path in jailbreakPaths) {
      if (await _fileExists(path)) {
        AppLogger.warning('Found jailbreak indicator at: $path', tag: _tag);
        return true;
      }
    }

    return false;
  }

  /// Check if file exists at path
  Future<bool> _fileExists(String path) async {
    try {
      final file = File(path);
      return await file.exists();
    } catch (e) {
      // Access denied or other error - might indicate root protection
      return false;
    }
  }

  /// Get detailed security status
  Future<SecurityStatus> getSecurityStatus() async {
    final isCompromised = await isDeviceCompromised();
    final isDeveloperMode = await isDeveloperModeEnabled();

    return SecurityStatus(
      isRooted: isCompromised,
      isDeveloperModeEnabled: isDeveloperMode,
      riskLevel: _calculateRiskLevel(isCompromised, isDeveloperMode),
    );
  }

  /// Calculate risk level based on findings
  RiskLevel _calculateRiskLevel(bool isRooted, bool isDeveloperMode) {
    if (isRooted) {
      return RiskLevel.critical;
    } else if (isDeveloperMode) {
      return RiskLevel.medium;
    }
    return RiskLevel.low;
  }
}

/// Security status result
class SecurityStatus {
  final bool isRooted;
  final bool isDeveloperModeEnabled;
  final RiskLevel riskLevel;

  SecurityStatus({
    required this.isRooted,
    required this.isDeveloperModeEnabled,
    required this.riskLevel,
  });

  bool get isSecure => riskLevel == RiskLevel.low;
}

/// Risk level enumeration
enum RiskLevel {
  low,
  medium,
  high,
  critical,
}
