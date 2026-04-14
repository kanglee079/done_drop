import 'package:get/get.dart';
import 'package:done_drop/app/presentation/capture/moment_controller.dart';

class CaptureBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MomentController>(() => MomentController());
  }
}
