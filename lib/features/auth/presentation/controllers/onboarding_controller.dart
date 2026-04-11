import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:done_drop/features/auth/data/onboarding_service.dart';
import 'package:done_drop/app/routes/app_routes.dart';

class OnboardingController extends GetxController {
  OnboardingController(this._onboardingService);
  final OnboardingService _onboardingService;

  final pageController = PageController();
  final currentPage = 0.obs;

  final pages = const [
    _OnboardingPage(
      icon: Icons.camera_alt_outlined,
      title: 'Capture Moments',
      description:
          'Take a photo of your accomplishment.\nEvery task completed deserves to be celebrated.',
    ),
    _OnboardingPage(
      icon: Icons.group_outlined,
      title: 'Share with Your Circle',
      description:
          'Build your inner circle.\nShare your wins with those who matter most.',
    ),
    _OnboardingPage(
      icon: Icons.auto_awesome_outlined,
      title: 'Your Weekly Recap',
      description:
          'Get a beautiful weekly summary.\nSee your progress and celebrate every week.',
    ),
  ];

  void onPageChanged(int page) {
    currentPage.value = page;
  }

  void nextPage() {
    if (currentPage.value < pages.length - 1) {
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

class _OnboardingPage {
  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;
}
