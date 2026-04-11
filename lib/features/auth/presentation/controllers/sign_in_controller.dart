import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:done_drop/features/auth/repositories/auth_repository.dart';
import 'package:done_drop/features/auth/repositories/user_profile_repository.dart';
import 'package:done_drop/app/routes/app_routes.dart';
import 'package:done_drop/core/errors/failures.dart';
import 'package:done_drop/core/errors/result.dart';
import 'package:done_drop/core/services/analytics_service.dart';
import 'package:done_drop/core/models/user_profile.dart';

class SignInController extends GetxController {
  SignInController(this._authRepo, this._userProfileRepo);
  final AuthRepository _authRepo;
  final UserProfileRepository _userProfileRepo;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final isLoading = false.obs;
  final errorMessage = RxnString();
  final isPasswordVisible = false.obs;

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
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
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  /// Sign-in entry point. Triggers analytics, authenticates, then bootstraps
  /// the user profile in Firestore if it's a new user.
  Future<void> signInWithEmail() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    isLoading.value = true;
    errorMessage.value = null;
    AnalyticsService.instance.signInStarted();

    final result = await _authRepo.signInWithEmail(
      emailController.text.trim(),
      passwordController.text,
    );

    isLoading.value = false;

    await result.fold(
      onSuccess: (credential) async {
        AnalyticsService.instance.logLogin('email');
        await _bootstrapUserProfile(credential.user?.uid);
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

  /// Google Sign-In entry point.
  Future<void> signInWithGoogle() async {
    if (isLoading.value) return;

    isLoading.value = true;
    errorMessage.value = null;
    AnalyticsService.instance.signInStarted();

    final result = await _authRepo.signInWithGoogle();

    isLoading.value = false;

    await result.fold(
      onSuccess: (credential) async {
        AnalyticsService.instance.logLogin('google');
        await _bootstrapUserProfile(credential.user?.uid);
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

  /// If the user profile document doesn't exist in Firestore, create one.
  /// This handles the bootstrap case for both new sign-ups and new sign-ins.
  Future<void> _bootstrapUserProfile(String? uid) async {
    if (uid == null) return;

    final profileResult = await _userProfileRepo.getUserProfile(uid);
    if (profileResult.isSuccess) return; // Already exists

    final user = _authRepo.currentUser;
    final profile = UserProfile(
      id: uid,
      displayName: user?.displayName ?? 'DoneDrop User',
      username: null,
      avatarUrl: user?.photoURL,
      bio: null,
      createdAt: DateTime.now(),
      premiumStatus: false,
      blockedUserIds: const [],
      settings: const UserSettings(),
      widgetPreferences: const WidgetPreferences(),
    );

    await _userProfileRepo.createUserProfile(profile);
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
