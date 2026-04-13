import 'package:get/get.dart';
import 'streak_controller.dart';

class StreakBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StreakController>(() => StreakController());
  }
}