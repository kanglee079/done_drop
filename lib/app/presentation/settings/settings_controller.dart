import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:done_drop/features/auth/presentation/controllers/auth_controller.dart';
import 'package:done_drop/app/routes/app_routes.dart';
import 'package:done_drop/core/constants/app_constants.dart';
import 'package:done_drop/core/errors/failures.dart';
import 'package:done_drop/core/errors/result.dart';
import 'package:done_drop/core/services/account_deletion_service.dart';
import 'package:done_drop/core/services/analytics_service.dart';
import 'package:done_drop/core/services/locale_controller.dart';
import 'package:done_drop/core/services/legal_service.dart';
import 'package:done_drop/core/services/notification_service.dart';
import 'package:done_drop/core/services/storage_service.dart';
import 'package:done_drop/features/auth/repositories/user_profile_repository.dart';
import 'package:done_drop/l10n/l10n.dart';
import 'package:done_drop/app/core/widgets/widgets.dart';
import 'package:done_drop/app/presentation/home/home_controller.dart';

/// Controller for the settings screen.
/// Manages notification preferences, account settings, and sign-out.
class SettingsController extends GetxController {
  SettingsController();

  AuthController get _authController => Get.find<AuthController>();
  AccountDeletionService get _accountDeletionService =>
      Get.find<AccountDeletionService>();
  UserProfileRepository get _userProfileRepo =>
      Get.find<UserProfileRepository>();
  LocaleController get _localeController => Get.find<LocaleController>();
  StorageService get _storage => StorageService.instance;

  // Notification preferences
  final RxBool momentReminders = true.obs;
  final RxBool isDeletingAccount = false.obs;

  String get userEmail => _authController.firebaseUser?.email ?? '';
  String get buildLabel => 'Version ${AppConstants.appVersion} (build 1)';
  String get currentLanguageCode => _localeController.currentLanguageCode;
  String get currentLanguageLabel => _localeController.isVietnamese
      ? currentL10n.languageVietnamese
      : currentL10n.languageEnglish;

  @override
  void onInit() {
    super.onInit();
    // Load preferences from local storage
    momentReminders.value = _storage.getBool('pref_moment_reminders') ?? true;
  }

  Future<void> toggleMomentReminders(bool value) async {
    momentReminders.value = value;
    await _storage.setBool('pref_moment_reminders', value);
    AnalyticsService.instance.settingChanged(
      'moment_reminders',
      value.toString(),
    );

    if (!value) {
      await NotificationService.instance.cancelAllActivityReminders();
      return;
    }

    if (Get.isRegistered<HomeController>()) {
      await NotificationService.instance.syncActivityReminders(
        Get.find<HomeController>().activities,
      );
    }
  }

  Future<void> signOut() async {
    await _accountDeletionService.clearSessionState();
    await AnalyticsService.instance.signOut();
    await _authController.signOut();
  }

  Future<void> openPrivacyPolicy() => LegalService.instance.openPrivacyPolicy();

  Future<void> openTermsOfService() =>
      LegalService.instance.openTermsOfService();

  Future<void> openSupport() async {
    await Get.toNamed(
      AppRoutes.report
          .replaceFirst(':targetType', 'app')
          .replaceFirst(':targetId', 'support'),
    );
  }

  Future<void> changeLanguage(String code) async {
    await _localeController.setLocaleCode(code);

    final profile = await _authController.ensureCurrentUserProfile();
    if (profile != null) {
      final updatedProfile = profile.copyWith(
        settings: profile.settings.copyWith(preferredLocaleCode: code),
      );
      await _userProfileRepo.updateUserProfile(updatedProfile);
    }
  }

  /// Initiates soft delete of the account.
  /// User must confirm by typing the exact phrase, and then re-authenticate.
  Future<void> deleteAccount() async {
    final user = _authController.firebaseUser;
    if (user == null || isDeletingAccount.value) return;

    // Step 1: First confirmation dialog
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text(currentL10n.confirmDeleteAccountTitle),
        content: Text(currentL10n.confirmDeleteAccountMessage),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(currentL10n.keepAccountAction),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(currentL10n.continueAction),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Step 2: Require user to type confirmation phrase
    final typedConfirmed = await ConfirmTypingDialog.show(
      context: Get.context!,
      title: currentL10n.confirmDeleteAccountTitle,
      message: currentL10n.confirmDeleteAccountMessage,
      hint: currentL10n.confirmDeleteAccountTabHint,
      placeholder: currentL10n.confirmDeleteAccountPlaceholder,
      expectedPhrase: currentL10n.confirmDeleteAccountPlaceholder,
      destructive: true,
    );

    if (typedConfirmed != true) return;

    // Step 3: Re-authenticate before soft delete
    final reauthResult = await _reauthenticateForDeletion();
    if (reauthResult.isFailure) {
      final failure = reauthResult.fold(
        onSuccess: (_) => null,
        onFailure: (failure) => failure,
      );
      final message = failure is AppFailure
          ? failure.message
          : currentL10n.verificationRequiredFallback;
      Get.snackbar(
        currentL10n.verificationRequiredTitle,
        message,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isDeletingAccount.value = true;
    AnalyticsService.instance.accountDeletionRequested(_providerLabel());

    // Step 4: Schedule soft delete
    final softDeleteResult = await _accountDeletionService.scheduleSoftDelete(
      user.uid,
    );
    if (softDeleteResult.isFailure) {
      isDeletingAccount.value = false;
      final failure = softDeleteResult.fold(
        onSuccess: (_) => null,
        onFailure: (failure) => failure,
      );
      final message = failure is AppFailure
          ? failure.message
          : currentL10n.deleteFailedFallback;
      Get.snackbar(
        currentL10n.deleteFailedTitle,
        message,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isDeletingAccount.value = false;

    // Show success message
    Get.snackbar(
      currentL10n.softDeleteInitiatedTitle,
      currentL10n.softDeleteInitiatedMessage,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 6),
    );

    // Sign out and redirect
    await _accountDeletionService.clearSessionState();
    await AnalyticsService.instance.signOut();
    await _authController.signOut();
  }

  Future<Result<void>> _reauthenticateForDeletion() async {
    final user = _authController.firebaseUser;
    if (user == null) {
      return Result.failure(AppFailure.unauthorized('No authenticated user.'));
    }

    final providerIds = user.providerData
        .map((provider) => provider.providerId)
        .toSet();
    if (providerIds.contains('password')) {
      final password = await _promptForPassword();
      if (password == null) {
        return Result.failure(
          AppFailure.cancelled('Password verification cancelled.'),
        );
      }
      return _authController.reauthenticateWithPassword(
        email: user.email ?? '',
        password: password,
      );
    }

    if (providerIds.contains('google.com')) {
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: Text(currentL10n.verifyWithGoogleTitle),
          content: Text(currentL10n.verifyWithGoogleMessage),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text(currentL10n.cancelAction),
            ),
            FilledButton(
              onPressed: () => Get.back(result: true),
              child: Text(currentL10n.continueAction),
            ),
          ],
        ),
      );
      if (confirmed != true) {
        return Result.failure(
          AppFailure.cancelled('Google verification cancelled.'),
        );
      }
      return _authController.reauthenticateWithGoogle();
    }

    return Result.failure(
      AppFailure.unexpected(currentL10n.unsupportedDeletionMethod),
    );
  }

  Future<String?> _promptForPassword() async {
    final controller = TextEditingController();
    final password = await Get.dialog<String>(
      AlertDialog(
        title: Text(currentL10n.confirmPasswordTitle),
        content: TextField(
          controller: controller,
          obscureText: true,
          autofocus: true,
          decoration: InputDecoration(
            labelText: currentL10n.passwordLabel,
            hintText: currentL10n.currentPasswordHint,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back<String>(),
            child: Text(currentL10n.cancelAction),
          ),
          FilledButton(
            onPressed: () => Get.back(result: controller.text),
            child: Text(currentL10n.verifyAction),
          ),
        ],
      ),
    );
    controller.dispose();

    final trimmed = password?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }

  String _providerLabel() {
    final providerIds =
        _authController.firebaseUser?.providerData
            .map((provider) => provider.providerId)
            .toSet() ??
        const <String>{};
    if (providerIds.contains('google.com')) return 'google';
    if (providerIds.contains('password')) return 'password';
    return 'unknown';
  }
}
