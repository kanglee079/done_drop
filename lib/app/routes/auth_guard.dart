import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:done_drop/app/routes/app_routes.dart';
import 'package:done_drop/features/auth/data/onboarding_service.dart';
import 'package:done_drop/features/auth/presentation/controllers/auth_controller.dart';

/// GetX Middleware — protects routes that require authentication.
///
/// Usage: add `middlewares: [AuthGuard()]` to GetPage definitions
/// for all routes that should require a logged-in user.
///
/// Public routes (no guard needed):
///   /splash, /onboarding, /sign-in, /sign-up, /forgot-password
///
/// Protected routes (require AuthGuard):
///   /home, /capture, /preview, /success, /feed, /circle/:id,
///   /circle/create, /invite/:circleId, /join, /wall, /recap,
///   /settings, /profile, /premium, /report/:targetType/:targetId, /blocked
class AuthGuard extends GetMiddleware {
  @override
  int? get priority => 1;

  /// Returns true if the route is public (does not require auth).
  bool _isPublicRoute(String route) {
    return route == AppRoutes.splash ||
        route == AppRoutes.onboarding ||
        route == AppRoutes.signIn ||
        route == AppRoutes.signUp ||
        route == AppRoutes.forgotPassword;
  }

  @override
  RouteSettings? redirect(String? route) {
    // Public routes — allow through
    if (route != null && _isPublicRoute(route)) {
      return null;
    }

    // For all other routes, check auth state
    if (!Get.isRegistered<AuthController>()) {
      // AuthController not ready yet — redirect to splash
      return RouteSettings(name: AppRoutes.splash);
    }

    final authController = Get.find<AuthController>();
    final onboardingService = Get.find<OnboardingService>();

    if (!authController.isLoggedIn) {
      // Not logged in
      if (!onboardingService.hasCompletedOnboarding) {
        return RouteSettings(name: AppRoutes.onboarding);
      }
      return RouteSettings(name: AppRoutes.signIn);
    }

    if (authController.requiresInitialHabitSetup &&
        route != AppRoutes.initialSetup) {
      return const RouteSettings(name: AppRoutes.initialSetup);
    }

    if (!authController.requiresInitialHabitSetup &&
        route == AppRoutes.initialSetup) {
      return const RouteSettings(name: AppRoutes.home);
    }

    // Logged in — allow through
    return null;
  }
}
