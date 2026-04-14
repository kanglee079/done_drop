import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:done_drop/app/routes/app_routes.dart';
import 'package:done_drop/core/constants/app_constants.dart';
import 'package:done_drop/core/models/moment.dart';
import 'package:done_drop/core/services/analytics_service.dart';
import 'package:done_drop/core/services/connectivity_service.dart';
import 'package:done_drop/core/services/feed_delivery_planner.dart';
import 'package:done_drop/core/services/media_service.dart';
import 'package:done_drop/core/services/offline_queue_service.dart';
import 'package:done_drop/features/auth/presentation/controllers/auth_controller.dart';
import 'package:done_drop/firebase/repositories/activity_repository.dart';
import 'package:done_drop/firebase/repositories/friend_repository.dart';
import 'package:done_drop/firebase/repositories/moment_repository.dart';

class MomentSubmissionResult {
  const MomentSubmissionResult({
    required this.isProofMoment,
    required this.wasOfflineQueued,
  });

  final bool isProofMoment;
  final bool wasOfflineQueued;
}

/// Controller for the capture and preview flow.
///
/// The controller owns one capture session at a time and is created by the
/// capture route binding. Preview and success reuse the same session.
class MomentController extends GetxController {
  MomentController();

  MomentRepository get _momentRepo => Get.find<MomentRepository>();
  FriendRepository get _friendRepo => Get.find<FriendRepository>();
  ActivityRepository get _activityRepo => Get.find<ActivityRepository>();
  AuthController get _authController => Get.find<AuthController>();
  MediaService get _mediaService => MediaService.instance;
  FeedDeliveryPlanner get _deliveryPlanner => const FeedDeliveryPlanner();

  final captionController = TextEditingController();
  final Rx<String> visibility = AppConstants.visibilityPersonalOnly.obs;
  final RxList<String> selectedFriendIds = <String>[].obs;
  final Rx<String> selectedCategory = ''.obs;
  final isPosting = false.obs;
  final RxnString errorMessage = RxnString();
  final Rxn<MomentSubmissionResult> lastSubmission =
      Rxn<MomentSubmissionResult>();

  String? _imagePath;
  String? _activityId;
  String? _activityInstanceId;
  String? _completionLogId;
  bool _sessionInitialized = false;

  String? get _userId => _authController.firebaseUser?.uid;

  String? get imagePath => _imagePath;
  String? get activityId => _activityId;
  String? get activityInstanceId => _activityInstanceId;
  String? get completionLogId => _completionLogId;
  bool get isProofMoment => _activityId != null;

  void startCaptureSession(Map<String, dynamic>? args) {
    if (_sessionInitialized && !_isSameContext(args)) {
      resetComposer();
    }

    _sessionInitialized = true;
    _activityId = args?['activityId'] as String?;
    _activityInstanceId = args?['activityInstanceId'] as String?;
    _completionLogId = args?['completionLogId'] as String?;
    _imagePath = null;
    errorMessage.value = null;
    lastSubmission.value = null;
  }

  void hydratePreview(Map<String, dynamic>? args) {
    final imagePath = args?['imagePath'] as String?;
    if (imagePath != null && imagePath.isNotEmpty) {
      _imagePath = imagePath;
      errorMessage.value = null;
    }
  }

  void attachImage(String path) {
    _imagePath = path;
    errorMessage.value = null;
  }

  Future<void> postMoment() async {
    if (_imagePath == null) {
      errorMessage.value = 'No image selected';
      return;
    }

    final uid = _userId;
    if (uid == null) {
      errorMessage.value = 'You must be signed in';
      return;
    }

    isPosting.value = true;
    errorMessage.value = null;

    final momentId = 'moment_${DateTime.now().millisecondsSinceEpoch}';
    final now = DateTime.now();
    final postVisibility = visibility.value;
    final caption = captionController.text.trim();
    final category = selectedCategory.value.isEmpty
        ? null
        : selectedCategory.value;
    final recipientIds = await _resolveRecipientIds(uid, postVisibility);

    final momentData = {
      'visibility': postVisibility,
      'selectedFriendIds': selectedFriendIds.toList(),
      'caption': caption,
      'category': category,
      'completedAt': now.toIso8601String(),
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
    };

    try {
      final connectivity = Get.find<ConnectivityService>();
      if (!connectivity.isOnlineNow) {
        await _queueMomentForSync(
          momentId: momentId,
          ownerId: uid,
          recipientIds: recipientIds,
          momentData: momentData,
        );
        await _finishSubmission(wasOfflineQueued: true);
        return;
      }

      final media = await _mediaService.uploadMomentImages(
        userId: uid,
        momentId: momentId,
        localFilePath: _imagePath!,
      );

      final moment = Moment(
        id: momentId,
        ownerId: uid,
        activityId: _activityId,
        activityInstanceId: _activityInstanceId,
        completionLogId: _completionLogId,
        visibility: postVisibility,
        selectedFriendIds: selectedFriendIds.toList(),
        media: media,
        caption: caption,
        category: category,
        completedAt: now,
        createdAt: now,
        updatedAt: now,
        reactionCounts: const {},
        isDeleted: false,
        moderationStatus: 'approved',
      );

      await _momentRepo.createMoment(moment);
      await _linkProofMoment(momentId);
      await _momentRepo.createFeedDeliveries(
        momentId: momentId,
        ownerId: uid,
        visibility: postVisibility,
        recipientIds: recipientIds,
      );

      AnalyticsService.instance.momentPosted(
        visibility: postVisibility,
        category: category,
      );
      await _finishSubmission(wasOfflineQueued: false);
    } catch (error) {
      isPosting.value = false;
      errorMessage.value = 'Failed to post moment: $error';
    }
  }

  void setVisibility(String nextVisibility) {
    visibility.value = nextVisibility;
    if (nextVisibility != AppConstants.visibilitySelectedFriends) {
      selectedFriendIds.clear();
    }
  }

  void toggleSelectedFriend(String friendId) {
    if (selectedFriendIds.contains(friendId)) {
      selectedFriendIds.remove(friendId);
      return;
    }
    selectedFriendIds.add(friendId);
  }

  void setCategory(String? category) {
    selectedCategory.value = category ?? '';
  }

  void resetComposer() {
    captionController.clear();
    visibility.value = AppConstants.visibilityPersonalOnly;
    selectedFriendIds.clear();
    selectedCategory.value = '';
    errorMessage.value = null;
    isPosting.value = false;
    lastSubmission.value = null;
    _imagePath = null;
    _activityId = null;
    _activityInstanceId = null;
    _completionLogId = null;
    _sessionInitialized = false;
  }

  Future<void> _queueMomentForSync({
    required String momentId,
    required String ownerId,
    required List<String> recipientIds,
    required Map<String, dynamic> momentData,
  }) async {
    await Get.find<OfflineQueueService>().queueCreateMoment(
      momentId: momentId,
      ownerId: ownerId,
      momentData: momentData,
      localMediaPath: _imagePath!,
      recipientIds: recipientIds,
      activityId: _activityId,
      activityInstanceId: _activityInstanceId,
      completionLogId: _completionLogId,
    );
  }

  Future<List<String>> _resolveRecipientIds(
    String uid,
    String postVisibility,
  ) async {
    if (postVisibility == AppConstants.visibilityAllFriends) {
      final friendships = await _friendRepo.getFriends(uid);
      final friendIds = friendships
          .map((friendship) => friendship.otherUserId(uid))
          .toList();
      return _deliveryPlanner.resolveRecipientIds(
        visibility: postVisibility,
        allFriendIds: friendIds,
        selectedFriendIds: selectedFriendIds,
      );
    }

    return _deliveryPlanner.resolveRecipientIds(
      visibility: postVisibility,
      allFriendIds: const <String>[],
      selectedFriendIds: selectedFriendIds,
    );
  }

  Future<void> _linkProofMoment(String momentId) async {
    if (_activityInstanceId != null && _completionLogId != null) {
      await _activityRepo.linkMomentToInstance(_activityInstanceId!, momentId);
      await _activityRepo.updateCompletionLogMomentId(
        _completionLogId!,
        momentId,
      );
      return;
    }

    if (_activityId != null && _completionLogId != null && _userId != null) {
      final instance = await _activityRepo.getOrCreateTodayInstance(
        _activityId!,
        _userId!,
      );
      await _activityRepo.linkMomentToInstance(instance.id, momentId);
      await _activityRepo.updateCompletionLogMomentId(
        _completionLogId!,
        momentId,
      );
    }
  }

  Future<void> _finishSubmission({required bool wasOfflineQueued}) async {
    await HapticFeedback.mediumImpact();
    isPosting.value = false;
    errorMessage.value = null;
    lastSubmission.value = MomentSubmissionResult(
      isProofMoment: isProofMoment,
      wasOfflineQueued: wasOfflineQueued,
    );
    Get.offNamed(AppRoutes.success);
  }

  bool _isSameContext(Map<String, dynamic>? args) {
    return _activityId == args?['activityId'] &&
        _activityInstanceId == args?['activityInstanceId'] &&
        _completionLogId == args?['completionLogId'];
  }

  @override
  void onClose() {
    captionController.dispose();
    super.onClose();
  }
}
