import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/errors/failures.dart';
import '../../../core/errors/result.dart';

class OnboardingService extends GetxService {
  // Unified onboarding key — single source of truth for onboarding state.
  // Previously there were two conflicting keys: 'has_completed_onboarding' (OnboardingService)
  // and 'onboarding_complete' (StorageService). Now using 'onboarding_complete' everywhere.
  static const _keyOnboarded = 'onboarding_complete';
  late final SharedPreferences _prefs;

  // Call this in main.dart before registering, pass the prefs instance
  void configureWithPrefs(SharedPreferences prefs) {
    _prefs = prefs;
  }

  bool get hasCompletedOnboarding {
    // Check new key first, then fall back to old key (migration)
    if (_prefs.containsKey(_keyOnboarded)) {
      return _prefs.getBool(_keyOnboarded) ?? false;
    }
    // Migration: support the old key name used before Phase 1 fix
    if (_prefs.containsKey('has_completed_onboarding')) {
      final oldValue = _prefs.getBool('has_completed_onboarding') ?? false;
      // Migrate to new key
      _prefs.setBool(_keyOnboarded, oldValue);
      return oldValue;
    }
    return false;
  }

  Future<Result<void>> markOnboardingComplete() async {
    try {
      await _prefs.setBool(_keyOnboarded, true);
      return Result.success(null);
    } catch (e) {
      return Result.failure(AppFailure.unexpected(e.toString()));
    }
  }

  Future<Result<void>> resetOnboarding() async {
    try {
      await _prefs.remove(_keyOnboarded);
      return Result.success(null);
    } catch (e) {
      return Result.failure(AppFailure.unexpected(e.toString()));
    }
  }
}
