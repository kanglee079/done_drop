import 'package:get/get.dart';

import 'package:done_drop/app/presentation/buddy_wall/buddy_wall_controller.dart';
import 'package:done_drop/firebase/repositories/moment_repository.dart';

class BuddyWallBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BuddyWallController>(
      () => BuddyWallController(Get.find<MomentRepository>()),
    );
  }
}
