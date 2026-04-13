import 'package:get/get.dart';
import 'package:done_drop/features/auth/presentation/controllers/auth_controller.dart';
import 'package:done_drop/features/auth/repositories/user_profile_repository.dart';
import 'home_controller.dart';
import 'navigation_controller.dart';
import '../feed/feed_controller.dart';
import '../capture/moment_controller.dart';
import '../streak/streak_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:done_drop/firebase/repositories/activity_repository.dart';
import 'package:done_drop/firebase/repositories/friend_repository.dart';

/// Home screen dependency injection.
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NavigationController>(() => NavigationController());
    Get.lazyPut<StreakController>(() => StreakController());
    Get.lazyPut<ActivityRepository>(() => ActivityRepository(FirebaseFirestore.instance));

    Get.lazyPut<HomeController>(
      () => HomeController(
        Get.find<AuthController>(),
        Get.find<UserProfileRepository>(),
        Get.find<ActivityRepository>(),
        Get.find<FriendRepository>(),
      ),
    );
    Get.lazyPut<FeedController>(() => FeedController());
    Get.lazyPut<MomentController>(() => MomentController());
  }
}
