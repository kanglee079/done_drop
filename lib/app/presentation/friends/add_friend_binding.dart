import 'package:get/get.dart';
import 'package:done_drop/app/presentation/friends/add_friend_controller.dart';
import 'package:done_drop/firebase/repositories/friend_repository.dart';

class AddFriendBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AddFriendController(Get.find<FriendRepository>()));
  }
}
