import 'package:get/get.dart';
import 'package:done_drop/app/presentation/settings/profile_controller.dart';
import 'package:done_drop/app/presentation/settings/settings_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<SettingsController>()) {
      Get.lazyPut(() => SettingsController());
    }
    Get.lazyPut(() => ProfileController());
  }
}
