import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:done_drop/features/auth/data/onboarding_service.dart';
import 'package:done_drop/app/routes/app_routes.dart';
import 'package:done_drop/core/services/analytics_service.dart';

/// Controller for OnboardingScreen's 3-page PageView.
///
/// IMPORTANT: The actual page content (WelcomePage, UseCasePage, PermissionsPage)
/// is defined in OnboardingScreen widget, NOT here. The `pages` list below
/// only defines metadata for the page indicator dots.
///
/// Page index → screen content mapping:
///   0 → _WelcomePage (tagline + value prop)
///   1 → _UseCasePage (who are you sharing with — personal/couple/friends/squad)
///   2 → _PermissionsPage (camera access explanation)
class OnboardingController extends GetxController {
  OnboardingController(this._onboardingService);
  final OnboardingService _onboardingService;

  final pageController = PageController();
  final currentPage = 0.obs;

  // Page metadata — must match the 3 pages in OnboardingScreen
  static const totalPages = 3;
  static const ctaLabels = ['Get Started', 'Continue', 'Done'];

  /// Which use case the user selected on page 1 (index 1 of the PageView).
  /// Null if no selection made yet.
  String? selectedUseCase;

  void onPageChanged(int page) {
    currentPage.value = page;
  }

  void selectUseCase(String key) {
    selectedUseCase = key;
    AnalyticsService.instance.useCaseSelected(key);
  }

  void nextPage() {
    if (currentPage.value < totalPages - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      completeOnboarding();
    }
  }

  void skip() {
    completeOnboarding();
  }

  Future<void> completeOnboarding() async {
    await _onboardingService.markOnboardingComplete();
    Get.offAllNamed(AppRoutes.signIn);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
