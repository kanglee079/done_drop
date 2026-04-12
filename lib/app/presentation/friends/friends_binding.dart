import 'package:get/get.dart';
import 'package:done_drop/app/presentation/friends/friends_controller.dart';
import 'package:done_drop/firebase/repositories/friend_repository.dart';

class FriendsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => FriendsController(Get.find<FriendRepository>()));
  }
}
