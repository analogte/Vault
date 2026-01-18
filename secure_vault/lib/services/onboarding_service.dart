import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service for managing onboarding state
class OnboardingService {
  static const String _onboardingCompleteKey = 'onboarding_completed';
  static const String _onboardingVersionKey = 'onboarding_version';

  // Increment this when you want to show onboarding again
  // (e.g., major app update with new features)
  static const int _currentOnboardingVersion = 1;

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// Check if onboarding has been completed
  Future<bool> hasCompletedOnboarding() async {
    try {
      final completed = await _storage.read(key: _onboardingCompleteKey);
      if (completed != 'true') return false;

      // Check version - if app updated with new onboarding, show again
      final versionStr = await _storage.read(key: _onboardingVersionKey);
      final version = int.tryParse(versionStr ?? '0') ?? 0;

      return version >= _currentOnboardingVersion;
    } catch (e) {
      return false;
    }
  }

  /// Mark onboarding as completed
  Future<void> completeOnboarding() async {
    try {
      await _storage.write(key: _onboardingCompleteKey, value: 'true');
      await _storage.write(
        key: _onboardingVersionKey,
        value: _currentOnboardingVersion.toString(),
      );
    } catch (e) {
      // Ignore errors, user will just see onboarding again
    }
  }

  /// Reset onboarding (for testing or if user wants to see it again)
  Future<void> resetOnboarding() async {
    try {
      await _storage.delete(key: _onboardingCompleteKey);
      await _storage.delete(key: _onboardingVersionKey);
    } catch (e) {
      // Ignore errors
    }
  }
}
