import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:done_drop/features/auth/repositories/auth_repository.dart';
import 'package:done_drop/features/auth/repositories/user_profile_repository.dart';
import 'package:done_drop/app/routes/app_routes.dart';
import 'package:done_drop/core/errors/failures.dart';
import 'package:done_drop/core/errors/result.dart';
import 'package:done_drop/core/services/analytics_service.dart';
import 'package:done_drop/core/models/user_profile.dart';
import 'package:done_drop/core/services/locale_controller.dart';
import 'package:done_drop/l10n/l10n.dart';

class SignUpController extends GetxController {
  SignUpController(this._authRepo, this._userProfileRepo);
  final AuthRepository _authRepo;
  final UserProfileRepository _userProfileRepo;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final isLoading = false.obs;
  final statusMessage = RxnString();
  final errorMessage = RxnString();
  final isPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;

  void clearInlineMessages() {
    if (isLoading.value) return;
    errorMessage.value = null;
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return currentL10n.nameRequired;
    }
    if (value.trim().length < 2) {
      return currentL10n.nameTooShort;
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return currentL10n.emailRequired;
    }
    if (!GetUtils.isEmail(value)) {
      return currentL10n.emailInvalid;
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return currentL10n.passwordRequired;
    }
    if (value.length < 6) {
      return currentL10n.passwordTooShort;
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return currentL10n.confirmPasswordRequired;
    }
    if (value != passwordController.text) {
      return currentL10n.confirmPasswordMismatch;
    }
    return null;
  }

  /// Sign-up: creates Firebase Auth account, then bootstraps Firestore profile.
  Future<void> signUp() async {
    if (isLoading.value) return;
    if (!(formKey.currentState?.validate() ?? false)) return;

    isLoading.value = true;
    statusMessage.value = currentL10n.authCreatingAccountStatus;
    errorMessage.value = null;
    AnalyticsService.instance.signInStarted();
    var keepBusyUntilDisposed = false;

    try {
      final result = await _authRepo.signUpWithEmail(
        emailController.text.trim(),
        passwordController.text,
      );

      await result.fold(
        onSuccess: (credential) async {
          AnalyticsService.instance.logLogin('email_signup');
          statusMessage.value = currentL10n.authPreparingProfileStatus;

          final uid = credential.user?.uid;
          if (uid == null) {
            final msg = currentL10n.authProfileBootstrapError;
            errorMessage.value = msg;
            AnalyticsService.instance.signInFailed(msg);
            await _authRepo.signOut();
            return;
          }

          final localeCode = Get.find<LocaleController>().currentLanguageCode;
          final codeResult = await _userProfileRepo.generateUniqueUserCode();

          await codeResult.fold(
            onSuccess: (userCode) async {
              final profile = UserProfile(
                id: uid,
                displayName: nameController.text.trim(),
                username: null,
                userCode: userCode,
                avatarUrl: null,
                bio: null,
                createdAt: DateTime.now(),
                premiumStatus: false,
                blockedUserIds: const [],
                settings: UserSettings(
                  hasCompletedHabitSetup: false,
                  preferredLocaleCode: localeCode,
                ),
                widgetPreferences: const WidgetPreferences(),
              );

              final profileResult = await _userProfileRepo.createUserProfile(
                profile,
              );
              await profileResult.fold(
                onSuccess: (_) async {
                  statusMessage.value = currentL10n.authPreparingAppStatus;
                  keepBusyUntilDisposed = true;
                  Get.offAllNamed(AppRoutes.initialSetup);
                },
                onFailure: (failure) async {
                  final msg = _failureMessage(
                    failure,
                    fallback: currentL10n.authProfileBootstrapError,
                  );
                  errorMessage.value = msg;
                  AnalyticsService.instance.signInFailed(msg);
                  await _authRepo.signOut();
                },
              );
            },
            onFailure: (failure) async {
              final msg = _failureMessage(
                failure,
                fallback: currentL10n.authProfileBootstrapError,
              );
              errorMessage.value = msg;
              AnalyticsService.instance.signInFailed(msg);
              await _authRepo.signOut();
            },
          );
        },
        onFailure: (failure) async {
          final msg = _failureMessage(failure);
          errorMessage.value = msg;
          AnalyticsService.instance.signInFailed(msg);
        },
      );
    } finally {
      if (!keepBusyUntilDisposed) {
        statusMessage.value = null;
        if (!isClosed) {
          isLoading.value = false;
        }
      }
    }
  }

  String _failureMessage(dynamic failure, {String? fallback}) {
    if (failure is AppFailure && failure.message.trim().isNotEmpty) {
      return failure.message;
    }
    return fallback ?? currentL10n.authProfileBootstrapError;
  }

  void goToSignIn() {
    Get.back();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
