import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:done_drop/features/auth/repositories/auth_repository.dart';
import 'package:done_drop/features/auth/data/onboarding_service.dart';
import 'package:done_drop/features/auth/repositories/user_profile_repository.dart';
import 'package:done_drop/app/routes/app_routes.dart';
import 'package:done_drop/core/errors/result.dart';
import 'package:done_drop/core/models/user_profile.dart';
import 'package:done_drop/core/services/capture_recovery_service.dart';
import 'package:done_drop/core/services/locale_controller.dart';
import 'package:done_drop/core/services/storage_service.dart';

class AuthController extends GetxController {
  AuthController(
    this._authRepo,
    this._onboardingService,
    this._userProfileRepo,
    this._localeController,
  );
  final AuthRepository _authRepo;
  final OnboardingService _onboardingService;
  final UserProfileRepository _userProfileRepo;
  final LocaleController _localeController;
  CaptureRecoveryService get _captureRecovery =>
      Get.find<CaptureRecoveryService>();

  final Rx<User?> _firebaseUser = Rx<User?>(null);
  final Rx<UserProfile?> _userProfile = Rx<UserProfile?>(null);
  User? get firebaseUser => _firebaseUser.value;
  UserProfile? get userProfile => _userProfile.value;
  bool get isLoggedIn => _firebaseUser.value != null;
  bool get requiresInitialHabitSetup =>
      _userProfile.value != null &&
      !_userProfile.value!.settings.hasCompletedHabitSetup;

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<UserProfile?>? _userProfileSubscription;

  /// Exposed stream of Firebase auth state changes.
  /// Use this in SplashScreen and route guards instead of StorageService.userId.
  Stream<User?> get authStateStream => _authRepo.authStateChanges;

  @override
  void onInit() {
    super.onInit();
    _firebaseUser.value = _authRepo.currentUser;
    _bindUserProfileStream(_firebaseUser.value);
    _authSubscription = _authRepo.authStateChanges.listen((user) {
      _firebaseUser.value = user;
      _bindUserProfileStream(user);
    });
  }

  @override
  void onClose() {
    _authSubscription?.cancel();
    _userProfileSubscription?.cancel();
    super.onClose();
  }

  Future<void> handleAuthGate() async {
    if (_firebaseUser.value == null) {
      if (!_onboardingService.hasCompletedOnboarding) {
        Get.offAllNamed(AppRoutes.onboarding);
      } else {
        Get.offAllNamed(AppRoutes.signIn);
      }
      return;
    }

    if (await _captureRecovery.restorePendingCaptureIfNeeded()) {
      return;
    }

    final destination = await resolveAuthenticatedRoute();
    Get.offAllNamed(destination);
  }

  Future<void> signOut() async {
    await _authRepo.signOut();
    Get.offAllNamed(AppRoutes.signIn);
  }

  Future<Result<void>> deleteAccount() => _authRepo.deleteAccount();

  Future<Result<void>> reauthenticateWithPassword({
    required String email,
    required String password,
  }) => _authRepo.reauthenticateWithPassword(email: email, password: password);

  Future<Result<void>> reauthenticateWithGoogle() =>
      _authRepo.reauthenticateWithGoogle();

  bool get hasCompletedOnboarding => _onboardingService.hasCompletedOnboarding;

  Future<String> resolveAuthenticatedRoute() async {
    final uid = _firebaseUser.value?.uid;
    if (uid == null) {
      return AppRoutes.signIn;
    }

    final profile = await ensureCurrentUserProfile();
    if (profile == null) {
      return AppRoutes.home;
    }

    return profile.settings.hasCompletedHabitSetup
        ? AppRoutes.home
        : AppRoutes.initialSetup;
  }

  Future<UserProfile?> ensureCurrentUserProfile() async {
    final uid = _firebaseUser.value?.uid;
    if (uid == null) return null;
    if (_userProfile.value != null) return _userProfile.value;

    final result = await _userProfileRepo.getUserProfile(uid);
    UserProfile? profile;
    result.fold(onSuccess: (value) => profile = value, onFailure: (_) {});

    if (profile != null) {
      _userProfile.value = profile;
      await StorageService.instance.setPremium(profile!.premiumStatus);
      await _localeController.syncFromProfile(profile);
    }
    return profile;
  }

  void _bindUserProfileStream(User? user) {
    _userProfileSubscription?.cancel();
    if (user == null) {
      _userProfile.value = null;
      unawaited(StorageService.instance.setPremium(false));
      return;
    }

    _userProfileSubscription = _userProfileRepo
        .watchUserProfile(user.uid)
        .listen(
          (profile) async {
            _userProfile.value = profile;
            final isPremium = profile?.premiumStatus ?? false;
            await StorageService.instance.setPremium(isPremium);
            await _localeController.syncFromProfile(profile);
          },
          onError: (error) {
            debugPrint('[_bindUserProfileStream] Error: $error');
          },
        );
  }
}
