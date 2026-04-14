import 'package:get/get.dart';
import 'package:done_drop/app/presentation/feed/feed_controller.dart';
import 'package:done_drop/app/presentation/feed/reaction_controller.dart';
import 'package:done_drop/firebase/repositories/activity_repository.dart';

class FeedBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FeedController>(
      () => FeedController(Get.find<ActivityRepository>()),
    );
  }
}

class ReactionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReactionController>(() => ReactionController());
  }
}
