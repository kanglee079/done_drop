import 'package:get/get.dart';

import 'package:done_drop/core/services/analytics_service.dart';
import 'package:done_drop/l10n/l10n.dart';

class PremiumController extends GetxController {
  PremiumController();

  bool get isStoreBillingReady => false;

  String get statusLabel => currentL10n.statusPreviewOnly;

  Future<void> showUnavailableMessage() async {
    await AnalyticsService.instance.paywallViewed('preview_only');
    Get.snackbar(
      currentL10n.premiumHiddenTitle,
      currentL10n.premiumHiddenMessage,
      snackPosition: SnackPosition.TOP,
    );
  }
}
