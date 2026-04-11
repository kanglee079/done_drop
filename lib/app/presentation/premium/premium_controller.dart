import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:done_drop/core/services/storage_service.dart';
import 'package:done_drop/core/services/analytics_service.dart';

/// Controller for the premium/paywall screen.
/// This is a RevenueCat placeholder — wire in actual purchase logic when ready.
class PremiumController extends GetxController {
  PremiumController();

  StorageService get _storage => StorageService.instance;

  final isMonthly = true.obs;
  final isPurchasing = false.obs;
  final isRestoring = false.obs;

  bool get isPremium => _storage.isPremium;

  double get monthlyPrice => 9.99;
  double get annualPrice => 95.88;

  String get currentPrice =>
      isMonthly.value ? '\$$monthlyPrice' : '\$$annualPrice';

  String get periodLabel => isMonthly.value ? '/month' : '/year';

  void togglePlan() {
    isMonthly.value = !isMonthly.value;
    AnalyticsService.instance.paywallViewed(isMonthly.value ? 'monthly' : 'annual');
  }

  Future<void> purchase() async {
    if (isPurchasing.value) return;

    isPurchasing.value = true;
    AnalyticsService.instance.purchaseStarted();

    // ── RevenueCat placeholder ─────────────────────────────────────────────
    // TODO: Replace with actual RevenueCat purchase call:
    //   await Purchases.purchasePackage(Package.annual);
    // ─────────────────────────────────────────────────────────────────────

    // Simulate purchase for demo (remove when real SDK is wired)
    await Future.delayed(const Duration(seconds: 2));

    await _storage.setPremium(true);
    AnalyticsService.instance.purchaseCompleted();

    isPurchasing.value = false;

    Get.snackbar(
      'Welcome to Premium!',
      'You now have access to all premium features.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFFE8F5E9),
      colorText: const Color(0xFF2E7D32),
    );

    Get.back();
  }

  Future<void> restorePurchases() async {
    if (isRestoring.value) return;

    isRestoring.value = true;

    // ── RevenueCat placeholder ─────────────────────────────────────────────
    // TODO: Replace with actual restore:
    //   final restored = await Purchases.restorePurchases();
    // ─────────────────────────────────────────────────────────────────────

    await Future.delayed(const Duration(seconds: 1));
    AnalyticsService.instance.restoreCompleted(true);

    isRestoring.value = false;

    Get.snackbar(
      'Restore Complete',
      'Your purchases have been restored.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFFE3F2FD),
      colorText: const Color(0xFF1565C0),
    );
  }
}
