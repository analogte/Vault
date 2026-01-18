import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service for managing app locale/language settings
class LocaleService extends ChangeNotifier {
  static const String _localeKey = 'app_locale';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Locale _currentLocale = const Locale('en');
  bool _isInitialized = false;

  /// Current locale
  Locale get currentLocale => _currentLocale;

  /// Whether service is initialized
  bool get isInitialized => _isInitialized;

  /// Supported locales
  static const List<Locale> supportedLocales = [
    Locale('en'),      // English
    Locale('th'),      // Thai
    Locale('zh'),      // Chinese Simplified
    Locale('ja'),      // Japanese
    Locale('ko'),      // Korean
    Locale('id'),      // Indonesian
  ];

  /// Language names for display
  static const Map<String, String> languageNames = {
    'en': 'English',
    'th': 'ไทย',
    'zh': '中文',
    'ja': '日本語',
    'ko': '한국어',
    'id': 'Bahasa Indonesia',
  };

  /// Language flags (emoji)
  static const Map<String, String> languageFlags = {
    'en': '🇺🇸',
    'th': '🇹🇭',
    'zh': '🇨🇳',
    'ja': '🇯🇵',
    'ko': '🇰🇷',
    'id': '🇮🇩',
  };

  /// Initialize the service and load saved locale
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final savedLocale = await _storage.read(key: _localeKey);
      if (savedLocale != null && _isValidLocale(savedLocale)) {
        _currentLocale = Locale(savedLocale);
      } else {
        // Use device locale if supported, otherwise default to English
        final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
        if (_isValidLocale(deviceLocale.languageCode)) {
          _currentLocale = Locale(deviceLocale.languageCode);
        }
      }
    } catch (e) {
      // Use default locale on error
      debugPrint('LocaleService: Error loading locale: $e');
    }

    _isInitialized = true;
    notifyListeners();
  }

  /// Check if locale code is valid
  bool _isValidLocale(String localeCode) {
    return supportedLocales.any((l) => l.languageCode == localeCode);
  }

  /// Set locale
  Future<void> setLocale(Locale locale) async {
    if (!_isValidLocale(locale.languageCode)) return;
    if (_currentLocale.languageCode == locale.languageCode) return;

    try {
      await _storage.write(key: _localeKey, value: locale.languageCode);
      _currentLocale = locale;
      notifyListeners();
    } catch (e) {
      debugPrint('LocaleService: Error saving locale: $e');
    }
  }

  /// Set locale by language code
  Future<void> setLocaleByCode(String languageCode) async {
    await setLocale(Locale(languageCode));
  }

  /// Get display name for a locale
  String getLanguageName(String languageCode) {
    return languageNames[languageCode] ?? languageCode;
  }

  /// Get flag emoji for a locale
  String getLanguageFlag(String languageCode) {
    return languageFlags[languageCode] ?? '';
  }

  /// Get current language display name
  String get currentLanguageName => getLanguageName(_currentLocale.languageCode);

  /// Get current language flag
  String get currentLanguageFlag => getLanguageFlag(_currentLocale.languageCode);
}
