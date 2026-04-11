import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:done_drop/features/auth/repositories/auth_repository.dart';
import 'package:done_drop/app/routes/app_routes.dart';
import 'package:done_drop/core/errors/failures.dart';
import 'package:done_drop/core/errors/result.dart';
import 'package:done_drop/core/services/analytics_service.dart';

class SignInController extends GetxController {
  SignInController(this._authRepo);
  final AuthRepository _authRepo;

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

  Future<void> signInWithEmail() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    isLoading.value = true;
    errorMessage.value = null;

    final result = await _authRepo.signInWithEmail(
      emailController.text.trim(),
      passwordController.text,
    );

    isLoading.value = false;

    result.fold(
      onSuccess: (credential) {
        AnalyticsService.instance.logLogin('email');
        Get.offAllNamed(AppRoutes.home);
      },
      onFailure: (failure) {
        if (failure is AppFailure) {
          errorMessage.value = failure.message;
        } else {
          errorMessage.value = failure.toString();
        }
      },
    );
  }

  Future<void> signInWithGoogle() async {
    if (isLoading.value) return;

    isLoading.value = true;
    errorMessage.value = null;

    final result = await _authRepo.signInWithGoogle();

    isLoading.value = false;

    result.fold(
      onSuccess: (credential) {
        AnalyticsService.instance.logLogin('google');
        Get.offAllNamed(AppRoutes.home);
      },
      onFailure: (failure) {
        if (failure is AppFailure) {
          errorMessage.value = failure.message;
        } else {
          errorMessage.value = failure.toString();
        }
      },
    );
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
