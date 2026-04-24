import 'package:get/get.dart';

import 'package:done_drop/core/services/analytics_service.dart';
import 'package:done_drop/core/services/billing_service.dart';
import 'package:done_drop/l10n/l10n.dart';

class PremiumController extends GetxController {
  PremiumController(this.billing);

  final BillingService billing;

  bool get hasPremiumAccess => billing.hasPremiumAccess;
  bool get isStoreBillingReady => billing.isStoreBillingReady;

  String get statusLabel {
    if (billing.isLoadingCatalog.value || billing.isRestoring.value) {
      return currentL10n.billingStatusCheckingChip;
    }
    if (hasPremiumAccess) {
      return currentL10n.billingStatusActiveChip;
    }
    if (isStoreBillingReady) {
      return currentL10n.billingStatusLiveChip;
    }
    return currentL10n.billingStatusIssueChip;
  }

  String planLabel(PremiumProductKind? kind) => switch (kind) {
    PremiumProductKind.monthly => currentL10n.billingMonthlyPlanTitle,
    PremiumProductKind.yearly => currentL10n.billingYearlyPlanTitle,
    PremiumProductKind.lifetime => currentL10n.billingLifetimePlanTitle,
    null => currentL10n.premiumBannerTitle,
  };

  Future<void> purchase(PremiumProductKind kind) async {
    await AnalyticsService.instance.paywallViewed('offer_${kind.name}');
    final launched = await billing.purchase(kind);
    if (launched) {
      Get.snackbar(
        currentL10n.premiumBannerTitle,
        currentL10n.billingPurchaseQueuedMessage,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final message =
        billing.errorMessage.value ?? currentL10n.billingPurchaseStartError;
    Get.snackbar(
      currentL10n.genericErrorTitle,
      message,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> restore() async {
    await billing.restorePurchases();
    if (billing.hasPremiumAccess) {
      Get.snackbar(
        currentL10n.billingRestoreSuccessTitle,
        currentL10n.billingRestoreSuccessMessage,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final message = billing.errorMessage.value?.trim().isNotEmpty == true
        ? billing.errorMessage.value!
        : currentL10n.billingRestorePendingMessage;
    Get.snackbar(
      currentL10n.restoreAction,
      message,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> manageSubscription() async {
    final opened = await billing.openManageSubscription();
    if (opened) return;

    Get.snackbar(
      currentL10n.premiumBannerTitle,
      currentL10n.billingManageUnavailableMessage,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
