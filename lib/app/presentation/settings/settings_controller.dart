import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:done_drop/features/auth/presentation/controllers/auth_controller.dart';
import 'package:done_drop/app/routes/app_routes.dart';
import 'package:done_drop/core/constants/app_constants.dart';
import 'package:done_drop/core/errors/failures.dart';
import 'package:done_drop/core/errors/result.dart';
import 'package:done_drop/core/services/account_deletion_service.dart';
import 'package:done_drop/core/services/analytics_service.dart';
import 'package:done_drop/core/services/legal_service.dart';
import 'package:done_drop/core/services/storage_service.dart';

/// Controller for the settings screen.
/// Manages notification preferences, account settings, and sign-out.
class SettingsController extends GetxController {
  SettingsController();

  AuthController get _authController => Get.find<AuthController>();
  AccountDeletionService get _accountDeletionService =>
      Get.find<AccountDeletionService>();
  StorageService get _storage => StorageService.instance;

  // Notification preferences
  final RxBool momentReminders = true.obs;
  final RxBool isDeletingAccount = false.obs;

  String get userEmail => _authController.firebaseUser?.email ?? '';
  String get buildLabel => 'Version ${AppConstants.appVersion} (build 1)';

  @override
  void onInit() {
    super.onInit();
    // Load preferences from local storage
    momentReminders.value = _storage.getBool('pref_moment_reminders') ?? true;
  }

  void toggleMomentReminders(bool value) {
    momentReminders.value = value;
    _storage.setBool('pref_moment_reminders', value);
    AnalyticsService.instance.settingChanged(
      'moment_reminders',
      value.toString(),
    );
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

  Future<void> deleteAccount() async {
    final user = _authController.firebaseUser;
    if (user == null || isDeletingAccount.value) return;

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete account'),
        content: const Text(
          'This permanently removes your profile, habits, proof moments, and private buddy data from DoneDrop. Subscription billing, if ever enabled later, must still be cancelled through the app store.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Keep account'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final reauthResult = await _reauthenticateForDeletion();
    if (reauthResult.isFailure) {
      final failure = reauthResult.fold(
        onSuccess: (_) => null,
        onFailure: (failure) => failure,
      );
      final message = failure is AppFailure
          ? failure.message
          : 'Could not verify your account. Please try again.';
      Get.snackbar(
        'Verification required',
        message,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isDeletingAccount.value = true;
    AnalyticsService.instance.accountDeletionRequested(_providerLabel());

    final deleteDataResult = await _accountDeletionService.deleteUserData(
      user.uid,
    );
    if (deleteDataResult.isFailure) {
      isDeletingAccount.value = false;
      final failure = deleteDataResult.fold(
        onSuccess: (_) => null,
        onFailure: (failure) => failure,
      );
      final message = failure is AppFailure
          ? failure.message
          : 'Failed to remove account data.';
      Get.snackbar(
        'Delete failed',
        message,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final authDeleteResult = await _authController.deleteAccount();
    if (authDeleteResult.isFailure) {
      isDeletingAccount.value = false;
      final failure = authDeleteResult.fold(
        onSuccess: (_) => null,
        onFailure: (failure) => failure,
      );
      final message = failure is AppFailure
          ? failure.message
          : 'Account credentials could not be removed.';
      Get.snackbar(
        'Delete incomplete',
        message,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    await _accountDeletionService.clearLocalState();
    isDeletingAccount.value = false;
    Get.offAllNamed(AppRoutes.signIn);
    Get.snackbar(
      'Account deleted',
      'Your DoneDrop account has been removed from this device.',
      snackPosition: SnackPosition.BOTTOM,
    );
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
          title: const Text('Verify with Google'),
          content: const Text(
            'To protect your account, continue with Google one more time before deletion.',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Continue'),
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
      AppFailure.unexpected(
        'This sign-in method is not supported for in-app deletion yet. Sign in again with a supported method and retry.',
      ),
    );
  }

  Future<String?> _promptForPassword() async {
    final controller = TextEditingController();
    final password = await Get.dialog<String>(
      AlertDialog(
        title: const Text('Confirm your password'),
        content: TextField(
          controller: controller,
          obscureText: true,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Password',
            hintText: 'Enter your current password',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back<String>(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Get.back(result: controller.text),
            child: const Text('Verify'),
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
