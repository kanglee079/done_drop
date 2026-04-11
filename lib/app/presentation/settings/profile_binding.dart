import 'package:get/get.dart';
import 'package:done_drop/app/presentation/settings/profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ProfileController());
  }
}
