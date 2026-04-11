import 'package:get/get.dart';
import 'package:done_drop/firebase/repositories/circle_repository.dart';
import 'package:done_drop/firebase/repositories/moment_repository.dart';
import 'package:done_drop/app/presentation/home/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(
      () => HomeController(
        Get.find<CircleRepository>(),
        Get.find<MomentRepository>(),
      ),
    );
  }
}
