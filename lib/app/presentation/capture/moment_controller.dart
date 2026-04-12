import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:done_drop/features/auth/presentation/controllers/auth_controller.dart';
import 'package:done_drop/firebase/repositories/moment_repository.dart';
import 'package:done_drop/firebase/repositories/friend_repository.dart';
import 'package:done_drop/core/models/moment.dart';
import 'package:done_drop/core/services/media_service.dart';
import 'package:done_drop/core/services/analytics_service.dart';
import 'package:done_drop/app/routes/app_routes.dart';
import 'package:done_drop/core/constants/app_constants.dart';

class MomentController extends GetxController {
  MomentController();

  MomentRepository get _momentRepo => Get.find<MomentRepository>();
  FriendRepository get _friendRepo => Get.find<FriendRepository>();
  AuthController get _authController => Get.find<AuthController>();
  MediaService get _mediaService => MediaService.instance;

  // Post form state
  final captionController = TextEditingController();
  final Rx<String> visibility = AppConstants.visibilityPersonalOnly.obs;
  final RxList<String> selectedFriendIds = <String>[].obs;
  final Rx<String> selectedCategory = ''.obs;

  // Post state
  final isPosting = false.obs;
  final RxnString errorMessage = RxnString();

  String? _imagePath;

  void setImagePath(String path) {
    _imagePath = path;
  }

  String? get _userId => _authController.firebaseUser?.uid;

  Future<void> postMoment() async {
    if (_imagePath == null) {
      errorMessage.value = 'No image selected';
      return;
    }

    final caption = captionController.text.trim();
    if (caption.isEmpty) {
      errorMessage.value = 'Please add a caption';
      return;
    }

    final uid = _userId;
    if (uid == null) {
      errorMessage.value = 'You must be signed in';
      return;
    }

    isPosting.value = true;
    errorMessage.value = null;

    try {
      final momentId = 'moment_${DateTime.now().millisecondsSinceEpoch}';
      final now = DateTime.now();

      // Upload images to Firebase Storage
      final media = await _mediaService.uploadMomentImages(
        userId: uid,
        momentId: momentId,
        localFilePath: _imagePath!,
      );

      // Build visibility
      final postVisibility = visibility.value;
      final friendsIds = postVisibility == AppConstants.visibilitySelectedFriends
          ? selectedFriendIds.toList()
          : <String>[];

      // Create moment document in Firestore
      final moment = Moment(
        id: momentId,
        ownerId: uid,
        visibility: postVisibility,
        selectedFriendIds: friendsIds,
        media: media,
        caption: caption,
        category: selectedCategory.value.isEmpty ? null : selectedCategory.value,
        completedAt: now,
        createdAt: now,
        updatedAt: now,
        reactionCounts: const {},
        isDeleted: false,
        moderationStatus: 'approved',
      );

      await _momentRepo.createMoment(moment);

      // Create feed deliveries for shared moments
      if (postVisibility == AppConstants.visibilityAllFriends) {
        final friendships = await _friendRepo.watchFriendships(uid).first;
        final friendIds = friendships.map((f) => f.otherUserId(uid)).toList();
        await _momentRepo.createFeedDeliveries(
          momentId: momentId,
          ownerId: uid,
          visibility: postVisibility,
          recipientIds: friendIds,
        );
      } else if (postVisibility == AppConstants.visibilitySelectedFriends &&
          friendsIds.isNotEmpty) {
        await _momentRepo.createFeedDeliveries(
          momentId: momentId,
          ownerId: uid,
          visibility: postVisibility,
          recipientIds: friendsIds,
        );
      }

      AnalyticsService.instance.momentPosted(
        visibility: postVisibility,
        category: selectedCategory.value.isEmpty ? null : selectedCategory.value,
      );

      isPosting.value = false;
      Get.offNamed(AppRoutes.success);
    } catch (e) {
      isPosting.value = false;
      errorMessage.value = 'Failed to post moment: ${e.toString()}';
    }
  }

  void setVisibility(String v) {
    visibility.value = v;
    if (v != AppConstants.visibilitySelectedFriends) {
      selectedFriendIds.clear();
    }
  }

  void toggleSelectedFriend(String friendId) {
    if (selectedFriendIds.contains(friendId)) {
      selectedFriendIds.remove(friendId);
    } else {
      selectedFriendIds.add(friendId);
    }
  }

  void setCategory(String? cat) {
    selectedCategory.value = cat ?? '';
  }

  void reset() {
    captionController.clear();
    visibility.value = AppConstants.visibilityPersonalOnly;
    selectedFriendIds.clear();
    selectedCategory.value = '';
    _imagePath = null;
    errorMessage.value = null;
  }

  @override
  void onClose() {
    captionController.dispose();
    super.onClose();
  }
}
