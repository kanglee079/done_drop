import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:done_drop/features/auth/repositories/auth_repository.dart';
import 'package:done_drop/features/auth/data/onboarding_service.dart';
import 'package:done_drop/app/routes/app_routes.dart';
import 'package:done_drop/core/errors/result.dart';

class AuthController extends GetxController {
  AuthController(this._authRepo, this._onboardingService);
  final AuthRepository _authRepo;
  final OnboardingService _onboardingService;

  final Rx<User?> _firebaseUser = Rx<User?>(null);
  User? get firebaseUser => _firebaseUser.value;
  bool get isLoggedIn => _firebaseUser.value != null;

  StreamSubscription<User?>? _authSubscription;

  /// Exposed stream of Firebase auth state changes.
  /// Use this in SplashScreen and route guards instead of StorageService.userId.
  Stream<User?> get authStateStream => _authRepo.authStateChanges;

  @override
  void onInit() {
    super.onInit();
    _authSubscription = _authRepo.authStateChanges.listen((user) {
      _firebaseUser.value = user;
    });
  }

  @override
  void onClose() {
    _authSubscription?.cancel();
    super.onClose();
  }

  Future<void> handleAuthGate() async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (_firebaseUser.value == null) {
      if (!_onboardingService.hasCompletedOnboarding) {
        Get.offAllNamed(AppRoutes.onboarding);
      } else {
        Get.offAllNamed(AppRoutes.signIn);
      }
      return;
    }

    Get.offAllNamed(AppRoutes.home);
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
}
