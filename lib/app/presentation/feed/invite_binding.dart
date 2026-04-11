import 'package:get/get.dart';
import 'package:done_drop/app/presentation/feed/invite_controller.dart';

class InviteBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => InviteController());
  }
}
