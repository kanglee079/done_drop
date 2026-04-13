import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:done_drop/features/auth/repositories/auth_repository.dart';
import 'package:done_drop/features/auth/repositories/user_profile_repository.dart';
import 'package:done_drop/app/routes/app_routes.dart';
import 'package:done_drop/app/presentation/home/home_controller.dart';
import 'package:done_drop/core/errors/failures.dart';
import 'package:done_drop/core/errors/result.dart';
import 'package:done_drop/core/services/analytics_service.dart';
import 'package:done_drop/core/models/user_profile.dart';
import 'package:done_drop/core/theme/theme.dart';

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

        // Navigate to home — show "create first activity" dialog if no activities exist.
        Get.offAllNamed(AppRoutes.home);
        // Prompt to create first activity after a short delay so HomeScreen is mounted.
        Future.delayed(const Duration(milliseconds: 800), () {
          final homeCtrl = Get.isRegistered<HomeController>() ? Get.find<HomeController>() : null;
          if (homeCtrl != null && homeCtrl.activities.isEmpty) {
            _showFirstActivityDialog(homeCtrl);
          }
        });
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

  /// Shows a guided dialog to create the user's first activity after sign-up.
  void _showFirstActivityDialog(HomeController ctrl) {
    final titleCtrl = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.celebration, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Welcome! 🎉'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Create your first daily activity.\nKeep your streak alive every day!',
              style: TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: titleCtrl,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'e.g., Morning run, Read 30 pages, Meditate...',
                labelText: 'Activity name',
                prefixIcon: Icon(Icons.task_alt),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Skip'),
          ),
          ElevatedButton(
            onPressed: () {
              final title = titleCtrl.text.trim();
              if (title.isNotEmpty) {
                ctrl.createActivity(title: title);
                Get.back();
                Get.snackbar(
                  'Streak started! 🔥',
                  'Complete this every day to build your streak.',
                  snackPosition: SnackPosition.BOTTOM,
                  duration: const Duration(seconds: 4),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Start'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
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
