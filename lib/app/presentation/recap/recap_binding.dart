import 'package:get/get.dart';
import 'package:done_drop/app/presentation/recap/recap_controller.dart';

class RecapBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => RecapController());
  }
}
