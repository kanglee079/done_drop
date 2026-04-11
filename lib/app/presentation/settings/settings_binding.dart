import 'package:get/get.dart';
import 'package:done_drop/app/presentation/settings/settings_controller.dart';

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SettingsController());
  }
}
