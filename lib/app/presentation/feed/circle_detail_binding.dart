import 'package:get/get.dart';
import 'package:done_drop/app/presentation/feed/circle_detail_controller.dart';

class CircleDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CircleDetailController());
  }
}
