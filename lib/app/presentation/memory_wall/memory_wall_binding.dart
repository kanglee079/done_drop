import 'package:get/get.dart';
import 'package:done_drop/app/presentation/memory_wall/memory_wall_controller.dart';
import 'package:done_drop/firebase/repositories/moment_repository.dart';

class MemoryWallBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MemoryWallController(Get.find<MomentRepository>()));
  }
}
