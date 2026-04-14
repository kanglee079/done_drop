import 'package:get/get.dart';
import 'package:done_drop/features/auth/presentation/controllers/auth_controller.dart';
import 'package:done_drop/features/auth/repositories/user_profile_repository.dart';
import 'home_controller.dart';
import 'navigation_controller.dart';
import '../feed/feed_controller.dart';
import '../streak/streak_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:done_drop/firebase/repositories/activity_repository.dart';
import 'package:done_drop/firebase/repositories/friend_repository.dart';
import 'package:done_drop/core/services/activity_completion_service.dart';

/// Home screen dependency injection.
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NavigationController>(() => NavigationController());
    Get.lazyPut<StreakController>(() => StreakController());
    Get.lazyPut<ActivityRepository>(
        () => ActivityRepository(FirebaseFirestore.instance));

    // Register ActivityCompletionService — single source of truth for
    // marking activities done (both online and offline).
    Get.lazyPut<ActivityCompletionService>(
        () => ActivityCompletionService(Get.find<ActivityRepository>()));

    Get.lazyPut<HomeController>(
      () => HomeController(
        Get.find<AuthController>(),
        Get.find<UserProfileRepository>(),
        Get.find<ActivityRepository>(),
        Get.find<FriendRepository>(),
      ),
    );
    Get.lazyPut<FeedController>(() => FeedController());
    // NOTE: MomentController is NOT pre-registered here.
    // It is created when entering the capture flow and deleted after success.
  }
}
