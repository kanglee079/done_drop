import 'package:get/get.dart';
import 'home_screen.dart';
import 'home_controller.dart';

/// Home screen dependency injection.
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
  }
}
