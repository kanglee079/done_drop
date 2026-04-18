import 'package:get/get.dart';

import 'notification_center_controller.dart';

class NotificationCenterBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<NotificationCenterController>()) {
      Get.lazyPut<NotificationCenterController>(
        () => NotificationCenterController(),
        fenix: true,
      );
    }
  }
}
