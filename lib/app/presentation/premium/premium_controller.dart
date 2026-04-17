import 'package:get/get.dart';

import 'package:done_drop/core/services/analytics_service.dart';

class PremiumController extends GetxController {
  PremiumController();

  bool get isStoreBillingReady => false;

  String get statusLabel => 'Preview only';

  Future<void> showUnavailableMessage() async {
    await AnalyticsService.instance.paywallViewed('preview_only');
    Get.snackbar(
      'Premium is hidden in this build',
      'Store billing is not wired yet, so subscriptions stay unavailable until native purchases are ready.',
      snackPosition: SnackPosition.TOP,
    );
  }
}
