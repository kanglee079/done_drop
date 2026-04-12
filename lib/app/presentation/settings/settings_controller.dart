import 'package:get/get.dart';
import 'package:done_drop/features/auth/presentation/controllers/auth_controller.dart';
import 'package:done_drop/core/services/analytics_service.dart';
import 'package:done_drop/core/services/storage_service.dart';

/// Controller for the settings screen.
/// Manages notification preferences, account settings, and sign-out.
class SettingsController extends GetxController {
  SettingsController();

  AuthController get _authController => Get.find<AuthController>();
  StorageService get _storage => StorageService.instance;

  // Notification preferences
  final RxBool momentReminders = true.obs;

  String get userEmail => _authController.firebaseUser?.email ?? '';

  @override
  void onInit() {
    super.onInit();
    // Load preferences from local storage
    momentReminders.value = _storage.getBool('pref_moment_reminders') ?? true;
  }

  void toggleMomentReminders(bool value) {
    momentReminders.value = value;
    _storage.setBool('pref_moment_reminders', value);
    AnalyticsService.instance.settingChanged('moment_reminders', value.toString());
  }

  Future<void> signOut() async {
    await AnalyticsService.instance.signOut();
    await _authController.signOut();
  }
}
