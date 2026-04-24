import 'package:get/get.dart';
import 'package:done_drop/app/presentation/premium/premium_controller.dart';
import 'package:done_drop/core/services/billing_service.dart';

class PremiumBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PremiumController(Get.find<BillingService>()));
  }
}
