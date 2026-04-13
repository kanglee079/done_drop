import 'package:get/get.dart';
import 'package:done_drop/firebase/repositories/friend_repository.dart';
import 'package:done_drop/firebase/repositories/activity_repository.dart';
import 'leaderboard_controller.dart';

class LeaderboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LeaderboardController>(
      () => LeaderboardController(
        Get.find<FriendRepository>(),
        Get.find<ActivityRepository>(),
      ),
    );
  }
}
