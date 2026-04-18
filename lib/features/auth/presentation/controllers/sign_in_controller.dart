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

class SignInController extends GetxController {
  SignInController(this._authRepo, this._userProfileRepo);
  final AuthRepository _authRepo;
  final UserProfileRepository _userProfileRepo;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final isEmailLoading = false.obs;
  final isGoogleLoading = false.obs;
  final errorMessage = RxnString();
  final isPasswordVisible = false.obs;

  bool get isBusy => isEmailLoading.value || isGoogleLoading.value;

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
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

  /// Sign-in entry point. Triggers analytics, authenticates, then bootstraps
  /// the user profile in Firestore if it's a new user.
  Future<void> signInWithEmail() async {
    if (isBusy) return;
    if (!(formKey.currentState?.validate() ?? false)) return;

    isEmailLoading.value = true;
    errorMessage.value = null;
    AnalyticsService.instance.signInStarted();

    final result = await _authRepo.signInWithEmail(
      emailController.text.trim(),
      passwordController.text,
    );

    isEmailLoading.value = false;

    await result.fold(
      onSuccess: (credential) async {
        AnalyticsService.instance.logLogin('email');
        final profile = await _bootstrapUserProfile(credential.user?.uid);
        Get.offAllNamed(
          profile.settings.hasCompletedHabitSetup
              ? AppRoutes.home
              : AppRoutes.initialSetup,
        );
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

  /// Google Sign-In entry point.
  Future<void> signInWithGoogle() async {
    if (isBusy) return;

    isGoogleLoading.value = true;
    errorMessage.value = null;
    AnalyticsService.instance.signInStarted();

    final result = await _authRepo.signInWithGoogle();

    isGoogleLoading.value = false;

    await result.fold(
      onSuccess: (credential) async {
        AnalyticsService.instance.logLogin('google');
        final profile = await _bootstrapUserProfile(credential.user?.uid);
        Get.offAllNamed(
          profile.settings.hasCompletedHabitSetup
              ? AppRoutes.home
              : AppRoutes.initialSetup,
        );
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

  /// If the user profile document doesn't exist in Firestore, create one.
  /// This handles the bootstrap case for both new sign-ups and new sign-ins.
  Future<UserProfile> _bootstrapUserProfile(String? uid) async {
    if (uid == null) {
      throw StateError('Cannot bootstrap user profile without uid.');
    }

    final profileResult = await _userProfileRepo.getUserProfile(uid);
    UserProfile? existingProfile;
    profileResult.fold(
      onSuccess: (profile) => existingProfile = profile,
      onFailure: (_) {},
    );
    if (existingProfile != null) {
      return existingProfile!;
    }

    final user = _authRepo.currentUser;
    final localeCode = Get.find<LocaleController>().currentLanguageCode;
    final profile = UserProfile(
      id: uid,
      displayName: user?.displayName ?? 'DoneDrop User',
      username: null,
      avatarUrl: user?.photoURL,
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

    await _userProfileRepo.createUserProfile(profile);
    return profile;
  }

  void goToSignUp() {
    Get.toNamed(AppRoutes.signUp);
  }

  void goToForgotPassword() {
    Get.toNamed(AppRoutes.forgotPassword);
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
