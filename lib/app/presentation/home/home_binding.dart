import 'package:get/get.dart';
import 'package:done_drop/features/auth/presentation/controllers/auth_controller.dart';
import 'package:done_drop/features/auth/repositories/user_profile_repository.dart';
import 'home_controller.dart';
import 'navigation_controller.dart';
import '../feed/feed_controller.dart';
import '../streak/streak_controller.dart';
import 'package:done_drop/firebase/repositories/activity_repository.dart';
import 'package:done_drop/firebase/repositories/friend_repository.dart';
import 'package:done_drop/firebase/repositories/moment_repository.dart';
import 'package:done_drop/core/services/activity_completion_service.dart';
import 'package:done_drop/core/services/connectivity_service.dart';
import 'package:done_drop/core/services/offline_queue_service.dart';
import 'package:done_drop/core/services/local_cache_service.dart';
import 'package:done_drop/app/presentation/memory_wall/memory_wall_controller.dart';
import 'package:done_drop/app/presentation/notifications/notification_center_controller.dart';
import 'package:done_drop/app/presentation/settings/settings_controller.dart';

/// Home screen dependency injection.
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NavigationController>(() => NavigationController());
    Get.lazyPut<StreakController>(() => StreakController());

    // Register CompleteHabitUseCase — single source of truth for
    // marking activities done (both online and offline).
    Get.lazyPut<CompleteHabitUseCase>(
      () => CompleteHabitUseCase(
        activityRepository: Get.find<ActivityRepository>(),
        connectivity: Get.find<ConnectivityService>(),
        offlineQueue: Get.find<OfflineQueueService>(),
        invalidateTodayInstances: () {
          final uid = Get.find<AuthController>().firebaseUser?.uid;
          if (uid == null) return Future<void>.value();
          return LocalCacheService.instance.invalidateTodayInstances(uid);
        },
      ),
    );

    Get.lazyPut<HomeController>(
      () => HomeController(
        Get.find<AuthController>(),
        Get.find<UserProfileRepository>(),
        Get.find<ActivityRepository>(),
        Get.find<FriendRepository>(),
      ),
    );
    Get.lazyPut<FeedController>(() => FeedController());
    Get.lazyPut<NotificationCenterController>(
      () => NotificationCenterController(),
      fenix: true,
    );
    Get.lazyPut<MemoryWallController>(
      () => MemoryWallController(Get.find<MomentRepository>()),
    );
    Get.lazyPut<SettingsController>(() => SettingsController());
  }
}
