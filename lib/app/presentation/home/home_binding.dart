import 'package:get/get.dart';
import 'package:done_drop/features/auth/presentation/controllers/auth_controller.dart';
import 'package:done_drop/features/auth/repositories/user_profile_repository.dart';
import 'home_controller.dart';
import 'navigation_controller.dart';
import '../feed/feed_controller.dart';
import '../capture/moment_controller.dart';
import '../streak/streak_controller.dart';

/// Home screen dependency injection.
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NavigationController>(() => NavigationController());
    Get.lazyPut<StreakController>(() => StreakController());

    Get.lazyPut<HomeController>(
      () => HomeController(
        Get.find<AuthController>(),
        Get.find<UserProfileRepository>(),
      ),
    );
    Get.lazyPut<FeedController>(() => FeedController());
    Get.lazyPut<MomentController>(() => MomentController());
  }
}
