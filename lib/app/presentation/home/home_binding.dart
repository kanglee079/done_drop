import 'package:get/get.dart';
import 'home_controller.dart';
import '../feed/feed_controller.dart';
import '../feed/reaction_controller.dart';
import '../capture/moment_controller.dart';

/// Home screen dependency injection.
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<FeedController>(() => FeedController());
    Get.lazyPut<ReactionController>(() => ReactionController());
    Get.lazyPut<MomentController>(() => MomentController());
  }
}
