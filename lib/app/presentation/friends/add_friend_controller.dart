import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:done_drop/features/auth/presentation/controllers/auth_controller.dart';
import 'package:done_drop/firebase/repositories/friend_repository.dart';
import 'package:done_drop/core/models/user_profile.dart';
import 'package:done_drop/core/errors/result.dart';
import 'package:done_drop/core/services/analytics_service.dart';

/// Controller for Add Friend screen.
class AddFriendController extends GetxController {
  AddFriendController(this._friendRepo);
  final FriendRepository _friendRepo;

  final searchController = TextEditingController();

  final isSearching = false.obs;
  final RxnString errorMessage = RxnString();
  final Rx<UserProfile?> foundUser = Rx<UserProfile?>(null);
  final RxBool requestSent = false.obs;
  final RxBool isAtCap = false.obs;

  String? get _currentUserId => Get.find<AuthController>().firebaseUser?.uid;
  String? get _currentUserName => Get.find<AuthController>().firebaseUser?.displayName;
  String? get _currentUserPhoto => Get.find<AuthController>().firebaseUser?.photoURL;

  int get maxFriends => FriendRepository.maxFriendsFree;

  @override
  void onInit() {
    super.onInit();
    _checkCap();
  }

  Future<void> _checkCap() async {
    final uid = _currentUserId;
    if (uid == null) return;
    isAtCap.value = !(await _friendRepo.canAddFriend(uid));
  }

  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Enter a username';
    }
    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }
    return null;
  }

  Future<void> searchByUsername() async {
    final username = searchController.text.trim();
    if (username.isEmpty) return;

    isSearching.value = true;
    errorMessage.value = null;
    foundUser.value = null;
    requestSent.value = false;

    final result = await _friendRepo.findUserByUsername(username);

    isSearching.value = false;

    result.fold(
      onSuccess: (user) {
        if (user.id == _currentUserId) {
          errorMessage.value = 'That is your own username';
          return;
        }
        foundUser.value = user;
      },
      onFailure: (failure) {
        errorMessage.value = failure.message;
      },
    );
  }

  Future<void> sendRequest() async {
    final user = foundUser.value;
    if (user == null) return;

    isSearching.value = true;
    errorMessage.value = null;

    final result = await _friendRepo.sendFriendRequest(
      senderId: _currentUserId!,
      receiverId: user.id,
      senderDisplayName: _currentUserName ?? 'User',
      senderAvatarUrl: _currentUserPhoto,
    );

    isSearching.value = false;

    result.fold(
      onSuccess: (_) {
        requestSent.value = true;
        AnalyticsService.instance.inviteSent();
        Get.snackbar(
          'Request Sent',
          'Friend request sent to ${user.displayName}',
          snackPosition: SnackPosition.BOTTOM,
        );
        _checkCap();
      },
      onFailure: (failure) {
        errorMessage.value = failure.message;
      },
    );
  }

  void reset() {
    searchController.clear();
    foundUser.value = null;
    requestSent.value = false;
    errorMessage.value = null;
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
