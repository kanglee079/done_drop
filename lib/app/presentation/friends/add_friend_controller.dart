import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:done_drop/features/auth/presentation/controllers/auth_controller.dart';
import 'package:done_drop/features/auth/repositories/user_profile_repository.dart';
import 'package:done_drop/firebase/repositories/friend_repository.dart';
import 'package:done_drop/core/models/user_profile.dart';
import 'package:done_drop/core/errors/result.dart';
import 'package:done_drop/core/services/analytics_service.dart';

class AddFriendController extends GetxController {
  AddFriendController(this._friendRepo, this._userProfileRepo);
  final FriendRepository _friendRepo;
  final UserProfileRepository _userProfileRepo;

  final searchController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final isSearching = false.obs;
  final errorMessage = RxnString();
  final Rx<UserProfile?> foundUser = Rx<UserProfile?>(null);
  final RxBool requestSent = false.obs;

  String? get _currentUserId => Get.find<AuthController>().firebaseUser?.uid;
  String? get _currentUserName => Get.find<AuthController>().firebaseUser?.displayName;
  String? get _currentUserPhoto => Get.find<AuthController>().firebaseUser?.photoURL;

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Enter an email address';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  Future<void> searchByEmail() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    isSearching.value = true;
    errorMessage.value = null;
    foundUser.value = null;
    requestSent.value = false;

    final result = await _friendRepo.findUserByEmail(searchController.text.trim());

    isSearching.value = false;

    result.fold(
      onSuccess: (user) {
        if (user.id == _currentUserId) {
          errorMessage.value = 'That is your own email';
          return;
        }
        foundUser.value = user;
      },
      onFailure: (failure) {
        errorMessage.value = failure.toString();
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
      },
      onFailure: (failure) {
        errorMessage.value = failure.toString();
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
