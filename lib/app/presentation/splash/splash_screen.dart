import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:done_drop/core/theme/theme.dart';
import 'package:done_drop/app/routes/app_routes.dart';
import 'package:done_drop/features/auth/data/onboarding_service.dart';
import 'package:done_drop/features/auth/presentation/controllers/auth_controller.dart';

/// DoneDrop Splash Screen
///
/// Routing logic (single source of truth):
/// - NOT logged in + onboarding NOT complete → /onboarding
/// - NOT logged in + onboarding complete  → /sign-in
/// - Logged in (any onboarding state)     → /home
///
/// Previously this screen used StorageService.userId which was never written,
/// causing every user to be redirected to /sign-in even when logged in via Firebase.
/// Now correctly uses AuthController.firebaseUser (FirebaseAuth as source of truth).
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  Timer? _navTimer;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();

    // Delay navigation to allow animation + auth state to settle
    _navTimer = Timer(const Duration(milliseconds: 1500), _navigate);
  }

  void _navigate() {
    if (!mounted) return;

    final authController = Get.find<AuthController>();
    final onboardingService = Get.find<OnboardingService>();

    if (_hasNavigated) return;
    _hasNavigated = true;

    if (authController.isLoggedIn) {
      // Logged in → go to home (onboarding state doesn't matter once logged in)
      Get.offAllNamed(AppRoutes.home);
    } else if (!onboardingService.hasCompletedOnboarding) {
      Get.offAllNamed(AppRoutes.onboarding);
    } else {
      Get.offAllNamed(AppRoutes.signIn);
    }
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'DoneDrop',
                style: AppTypography.displayLarge(color: AppColors.primary).copyWith(
                  fontStyle: FontStyle.italic,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: AppSizes.space8),
              Text(
                'Complete it. Capture it.\nShare the moment.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium(color: AppColors.onSurfaceVariant).copyWith(
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
