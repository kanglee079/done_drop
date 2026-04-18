import 'dart:math';

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

String _generateUserCode() {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  final random = Random.secure();
  return List.generate(6, (_) => chars[random.nextInt(chars.length)]).join();
}

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
  final errorMessage = RxnString();
  final isPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;

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
    if (!(formKey.currentState?.validate() ?? false)) return;

    isLoading.value = true;
    errorMessage.value = null;
    AnalyticsService.instance.signInStarted();

    final result = await _authRepo.signUpWithEmail(
      emailController.text.trim(),
      passwordController.text,
    );

    isLoading.value = false;

    await result.fold(
      onSuccess: (credential) async {
        AnalyticsService.instance.logLogin('email_signup');

        // Bootstrap user profile in Firestore
        final uid = credential.user?.uid;
        if (uid != null) {
          final localeCode = Get.find<LocaleController>().currentLanguageCode;
          final profile = UserProfile(
            id: uid,
            displayName: nameController.text.trim(),
            username: null,
            userCode: _generateUserCode(),
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

          // Retry user profile creation to handle Firestore propagation delay
          Result<UserProfile>? profileResult;
          for (var attempt = 0; attempt < 3; attempt++) {
            profileResult = await _userProfileRepo.createUserProfile(profile);
            if (profileResult.isSuccess) break;
            await Future.delayed(Duration(milliseconds: 500 * (attempt + 1)));
          }

          // Verify profile was created by reading it back
          if (profileResult?.isSuccess ?? false) {
            await Future.delayed(const Duration(milliseconds: 300));
            final verifyResult = await _userProfileRepo.getUserProfile(uid);
            if (verifyResult.isFailure) {
              // Last retry if verification fails
              await _userProfileRepo.createUserProfile(profile);
              await Future.delayed(const Duration(milliseconds: 500));
            }
          }
        }

        Get.offAllNamed(AppRoutes.initialSetup);
      },
      onFailure: (failure) {
        final msg = failure is AppFailure
            ? failure.message
            : failure.toString();
        errorMessage.value = msg;
        AnalyticsService.instance.signInFailed(msg);
      },
    );
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
