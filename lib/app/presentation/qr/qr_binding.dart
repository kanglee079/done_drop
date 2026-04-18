import 'package:get/get.dart';

import 'package:done_drop/app/presentation/qr/qr_controller.dart';

class QrBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<QrController>(() => QrController());
  }
}
