import 'package:get/get.dart';

import 'package:done_drop/app/presentation/chat/chat_controller.dart';
import 'package:done_drop/firebase/repositories/chat_repository.dart';
import 'package:done_drop/firebase/repositories/friend_repository.dart';

class ChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChatController>(
      () => ChatController(
        Get.find<ChatRepository>(),
        Get.find<FriendRepository>(),
      ),
    );
  }
}
