import 'package:get/get.dart';
import 'package:done_drop/app/presentation/feed/feed_controller.dart';
import 'package:done_drop/app/presentation/feed/reaction_controller.dart';

class FeedBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FeedController>(() => FeedController());
  }
}

class ReactionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReactionController>(() => ReactionController());
  }
}
