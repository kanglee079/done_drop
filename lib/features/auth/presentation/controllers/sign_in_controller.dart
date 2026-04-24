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

class SignInController extends GetxController {
  SignInController(this._authRepo, this._userProfileRepo);
  final AuthRepository _authRepo;
  final UserProfileRepository _userProfileRepo;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final isEmailLoading = false.obs;
  final isGoogleLoading = false.obs;
  final statusMessage = RxnString();
  final errorMessage = RxnString();
  final isPasswordVisible = false.obs;

  bool get isBusy => isEmailLoading.value || isGoogleLoading.value;
  bool get shouldOfferGoogleSignIn => _authRepo.shouldOfferGoogleSignIn;
  String? get googleSignInAvailabilityNotice =>
      _authRepo.googleSignInAvailabilityNotice;

  void clearInlineMessages() {
    if (isBusy) return;
    errorMessage.value = null;
  }

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
    await _runSignInFlow(
      loadingFlag: isEmailLoading,
      signInFuture: _authRepo.signInWithEmail(
        emailController.text.trim(),
        passwordController.text,
      ),
      loginMethod: 'email',
    );
  }

  /// Google Sign-In entry point.
  Future<void> signInWithGoogle() async {
    await _runSignInFlow(
      loadingFlag: isGoogleLoading,
      signInFuture: _authRepo.signInWithGoogle(),
      loginMethod: 'google',
    );
  }

  Future<void> _runSignInFlow({
    required RxBool loadingFlag,
    required Future<Result<dynamic>> signInFuture,
    required String loginMethod,
  }) async {
    if (isBusy) return;
    if (loginMethod == 'email' &&
        !(formKey.currentState?.validate() ?? false)) {
      return;
    }

    loadingFlag.value = true;
    statusMessage.value = currentL10n.authSigningInStatus;
    errorMessage.value = null;
    AnalyticsService.instance.signInStarted();
    var keepBusyUntilDisposed = false;

    try {
      final result = await signInFuture;

      await result.fold(
        onSuccess: (credential) async {
          AnalyticsService.instance.logLogin(loginMethod);
          statusMessage.value = currentL10n.authLoadingProfileStatus;
          final profileResult = await _bootstrapUserProfile(
            credential.user?.uid,
          );

          await profileResult.fold(
            onSuccess: (profile) async {
              statusMessage.value = currentL10n.authPreparingAppStatus;
              keepBusyUntilDisposed = true;
              Get.offAllNamed(
                profile.settings.hasCompletedHabitSetup
                    ? AppRoutes.home
                    : AppRoutes.initialSetup,
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
          loadingFlag.value = false;
        }
      }
    }
  }

  /// If the user profile document doesn't exist in Firestore, create one.
  /// This handles the bootstrap case for both new sign-ups and new sign-ins.
  Future<Result<UserProfile>> _bootstrapUserProfile(String? uid) async {
    if (uid == null) {
      return Result.failure(
        AppFailure.unauthorized(
          currentL10n.authProfileBootstrapError,
          'auth_missing_uid',
        ),
      );
    }

    final user = _authRepo.currentUser;
    try {
      final profileResult = await _userProfileRepo.getUserProfile(uid);
      final existingProfile = profileResult.dataOrNull;
      if (existingProfile != null) {
        final ensuredResult = await _userProfileRepo.ensureUserCode(
          existingProfile,
        );
        return await ensuredResult.fold(
          onSuccess: (ensuredProfile) async {
            unawaited(
              _userProfileRepo.syncDiscoveryProfile(
                ensuredProfile,
                email: user?.email,
              ),
            );
            return Result.success(ensuredProfile);
          },
          onFailure: (failure) async => Result.failure(failure),
        );
      }

      final localeCode = Get.find<LocaleController>().currentLanguageCode;
      final codeResult = await _userProfileRepo.generateUniqueUserCode();
      return await codeResult.fold(
        onSuccess: (userCode) async {
          final profile = UserProfile(
            id: uid,
            displayName: user?.displayName ?? 'DoneDrop User',
            username: null,
            userCode: userCode,
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

          final createResult = await _userProfileRepo.createUserProfile(
            profile,
          );
          return createResult.fold(
            onSuccess: (_) => Result.success(profile),
            onFailure: (failure) => Result.failure(failure),
          );
        },
        onFailure: (failure) async => Result.failure(failure),
      );
    } catch (e) {
      return Result.failure(
        AppFailure.unexpected(
          e.toString(),
          'auth_profile_bootstrap_unexpected',
        ),
      );
    }
  }

  String _failureMessage(dynamic failure, {String? fallback}) {
    if (failure is AppFailure && failure.message.trim().isNotEmpty) {
      return failure.message;
    }
    return fallback ?? currentL10n.authProfileBootstrapError;
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
