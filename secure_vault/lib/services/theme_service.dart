import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/utils/logger.dart';

/// Service to manage app theme (Dark/Light/System)
class ThemeService extends ChangeNotifier {
  static const String _tag = 'ThemeService';
  static const String _themeKey = 'app_theme_mode';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  /// Initialize and load saved theme preference
  Future<void> initialize() async {
    await loadThemeMode();
  }

  /// Load theme mode from storage
  Future<void> loadThemeMode() async {
    try {
      final savedTheme = await _storage.read(key: _themeKey);
      if (savedTheme != null) {
        _themeMode = _parseThemeMode(savedTheme);
        AppLogger.log('Loaded theme: $_themeMode', tag: _tag);
        notifyListeners();
      }
    } catch (e) {
      AppLogger.error('Error loading theme', tag: _tag, error: e);
    }
  }

  /// Set and save theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    try {
      await _storage.write(key: _themeKey, value: mode.name);
      _themeMode = mode;
      AppLogger.log('Theme changed to: $mode', tag: _tag);
      notifyListeners();
    } catch (e) {
      AppLogger.error('Error saving theme', tag: _tag, error: e);
    }
  }

  /// Parse theme mode from string
  ThemeMode _parseThemeMode(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  /// Get display name for theme mode
  String getThemeModeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'สว่าง';
      case ThemeMode.dark:
        return 'มืด';
      case ThemeMode.system:
        return 'ตามระบบ';
    }
  }

  /// Get icon for theme mode
  IconData getThemeModeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.brightness_auto;
    }
  }
}
