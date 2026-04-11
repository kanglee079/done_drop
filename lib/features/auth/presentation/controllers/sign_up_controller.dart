import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:done_drop/features/auth/repositories/auth_repository.dart';
import 'package:done_drop/features/auth/repositories/user_profile_repository.dart';
import 'package:done_drop/app/routes/app_routes.dart';
import 'package:done_drop/core/errors/failures.dart';
import 'package:done_drop/core/errors/result.dart';
import 'package:done_drop/core/services/analytics_service.dart';
import 'package:done_drop/core/models/user_profile.dart';

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
      return 'Please enter your name';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != passwordController.text) {
      return 'Passwords do not match';
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
          final profile = UserProfile(
            id: uid,
            displayName: nameController.text.trim(),
            username: null,
            avatarUrl: null,
            bio: null,
            createdAt: DateTime.now(),
            premiumStatus: false,
            blockedUserIds: const [],
            settings: const UserSettings(),
            widgetPreferences: const WidgetPreferences(),
          );
          await _userProfileRepo.createUserProfile(profile);
        }

        Get.offAllNamed(AppRoutes.home);
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
