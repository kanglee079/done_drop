import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/errors/failures.dart';
import '../../../core/errors/result.dart';

class OnboardingService extends GetxService {
  static const _keyOnboarded = 'has_completed_onboarding';
  late final SharedPreferences _prefs;

  Future<OnboardingService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  bool get hasCompletedOnboarding => _prefs.getBool(_keyOnboarded) ?? false;

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
