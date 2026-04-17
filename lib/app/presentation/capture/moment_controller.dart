import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:done_drop/app/presentation/feed/feed_controller.dart';
import 'package:done_drop/app/presentation/home/home_controller.dart';
import 'package:done_drop/app/presentation/memory_wall/memory_wall_controller.dart';
import 'package:done_drop/app/routes/app_routes.dart';
import 'package:done_drop/core/constants/app_constants.dart';
import 'package:done_drop/core/models/moment.dart';
import 'package:done_drop/core/services/analytics_service.dart';
import 'package:done_drop/core/services/connectivity_service.dart';
import 'package:done_drop/core/services/feed_delivery_planner.dart';
import 'package:done_drop/core/services/media_service.dart';
import 'package:done_drop/core/services/offline_queue_service.dart';
import 'package:done_drop/core/theme/theme.dart';
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
  final uploadProgress = 0.0.obs;
  final uploadStage = MediaUploadStage.complete.obs;
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

  String get uploadStatusLabel => switch (uploadStage.value) {
        MediaUploadStage.preparing => 'Preparing image…',
        MediaUploadStage.uploading =>
          'Uploading ${(uploadProgress.value * 100).round()}%',
        MediaUploadStage.finalizing => 'Finalizing moment…',
        MediaUploadStage.complete => 'Ready',
      };

  void startCaptureSession(Map<String, dynamic>? args) {
    if (_sessionInitialized && !_isSameContext(args)) {
      resetComposer();
    }

    _sessionInitialized = true;
    _activityId = args?['activityId'] as String?;
    _activityInstanceId = args?['activityInstanceId'] as String?;
    _completionLogId = args?['completionLogId'] as String?;
    _imagePath = null;
    uploadProgress.value = 0;
    uploadStage.value = MediaUploadStage.complete;
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

    if (visibility.value == AppConstants.visibilitySelectedFriends &&
        selectedFriendIds.isEmpty) {
      errorMessage.value = 'Pick at least one buddy before sharing.';
      return;
    }

    isPosting.value = true;
    uploadProgress.value = 0;
    uploadStage.value = MediaUploadStage.preparing;
    errorMessage.value = null;

    final momentId = 'moment_${DateTime.now().millisecondsSinceEpoch}';
    final now = DateTime.now();
    final postVisibility = visibility.value;
    final caption = captionController.text.trim();
    final category = selectedCategory.value.isEmpty
        ? null
        : selectedCategory.value;
    final activityTitle = await _resolveActivityTitle();
    final ownerDisplayName = _resolveOwnerDisplayName();
    final ownerAvatarUrl = _resolveOwnerAvatarUrl();
    final recipientIds = await _resolveRecipientIds(uid, postVisibility);

    final momentData = {
      'ownerDisplayName': ownerDisplayName,
      'ownerAvatarUrl': ownerAvatarUrl,
      'activityTitle': activityTitle,
      'visibility': postVisibility,
      'selectedFriendIds': selectedFriendIds.toList(),
      'caption': caption,
      'category': category,
      'completedAt': now.toIso8601String(),
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
    };

    final optimisticMoment = Moment(
      id: momentId,
      ownerId: uid,
      ownerDisplayName: ownerDisplayName,
      ownerAvatarUrl: ownerAvatarUrl,
      activityId: _activityId,
      activityInstanceId: _activityInstanceId,
      completionLogId: _completionLogId,
      activityTitle: activityTitle,
      visibility: postVisibility,
      selectedFriendIds: selectedFriendIds.toList(),
      media: MomentMedia.empty(),
      caption: caption,
      category: category,
      completedAt: now,
      createdAt: now,
      updatedAt: now,
      localPreviewPath: _imagePath,
      uploadProgress: 0,
      syncStatus: MomentSyncStatus.processing,
    );
    _upsertOptimisticMoment(optimisticMoment);

    try {
      final connectivity = Get.find<ConnectivityService>();
      if (!connectivity.isOnlineNow) {
        _updateOptimisticMoment(
          momentId,
          syncStatus: MomentSyncStatus.queued,
          uploadProgress: 0,
        );
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
        onProgress: (progress) {
          uploadProgress.value = progress.progress;
          uploadStage.value = progress.stage;
          _updateOptimisticMoment(
            momentId,
            syncStatus: _syncStatusForStage(progress.stage),
            uploadProgress: progress.progress,
          );
        },
      );

      final moment = optimisticMoment.copyWith(
        media: media,
        uploadProgress: 1,
        syncStatus: MomentSyncStatus.finalizing,
      );
      _updateOptimisticMoment(
        momentId,
        media: media,
        syncStatus: MomentSyncStatus.finalizing,
        uploadProgress: 1,
      );

      await _momentRepo.createMoment(moment);
      await _linkProofMoment(momentId);
      await _momentRepo.createFeedDeliveries(
        moment: moment,
        recipientIds: recipientIds,
      );

      _updateOptimisticMoment(
        momentId,
        media: media,
        syncStatus: MomentSyncStatus.synced,
        uploadProgress: 1,
      );

      await AnalyticsService.instance.momentPosted(
        visibility: postVisibility,
        category: category,
      );
      await _finishSubmission(wasOfflineQueued: false);
    } catch (error) {
      isPosting.value = false;
      uploadStage.value = MediaUploadStage.complete;
      _updateOptimisticMoment(
        momentId,
        syncStatus: MomentSyncStatus.failed,
      );
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
    uploadProgress.value = 0;
    uploadStage.value = MediaUploadStage.complete;
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
    List<String> friendIds = [];

    if (postVisibility == AppConstants.visibilityAllFriends) {
      final friendships = await _friendRepo.getFriends(uid);
      friendIds = friendships
          .map((friendship) => friendship.otherUserId(uid))
          .toList();
    }

    final recipientIds = _deliveryPlanner.resolveRecipientIds(
      visibility: postVisibility,
      allFriendIds: friendIds,
      selectedFriendIds: selectedFriendIds,
    );
    if (postVisibility != AppConstants.visibilityPersonalOnly &&
        !recipientIds.contains(uid)) {
      recipientIds.add(uid);
    }
    return recipientIds;
  }

  Future<void> _linkProofMoment(String momentId) async {
    String? instanceId = _activityInstanceId;

    if (instanceId == null && _activityId != null && _userId != null) {
      final instance = await _activityRepo.getOrCreateTodayInstance(
        _activityId!,
        _userId!,
      );
      instanceId = instance.id;
    }

    if (instanceId != null && _completionLogId != null) {
      await _activityRepo.linkMomentToInstance(instanceId, momentId);
      await _activityRepo.updateCompletionLogMomentId(
        _completionLogId!,
        momentId,
      );
    }
  }

  Future<void> _finishSubmission({required bool wasOfflineQueued}) async {
    await HapticFeedback.mediumImpact();
    isPosting.value = false;
    uploadProgress.value = wasOfflineQueued ? 0 : 1;
    uploadStage.value = MediaUploadStage.complete;
    errorMessage.value = null;
    lastSubmission.value = MomentSubmissionResult(
      isProofMoment: isProofMoment,
      wasOfflineQueued: wasOfflineQueued,
    );
    if (wasOfflineQueued) {
      Get.snackbar(
        'Saved for sync',
        'Will upload when you are back online.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.inverseSurface,
        colorText: AppColors.inverseOnSurface,
        duration: const Duration(seconds: 3),
      );
    }
    Get.offNamed(AppRoutes.success);
  }

  bool _isSameContext(Map<String, dynamic>? args) {
    return _activityId == args?['activityId'] &&
        _activityInstanceId == args?['activityInstanceId'] &&
        _completionLogId == args?['completionLogId'];
  }

  String _resolveOwnerDisplayName() {
    if (Get.isRegistered<HomeController>()) {
      final displayName = Get.find<HomeController>().profile.value?.displayName;
      if (displayName != null && displayName.isNotEmpty) return displayName;
    }
    return _authController.firebaseUser?.displayName ?? 'DoneDrop member';
  }

  String? _resolveOwnerAvatarUrl() {
    if (Get.isRegistered<HomeController>()) {
      final avatarUrl = Get.find<HomeController>().profile.value?.avatarUrl;
      if (avatarUrl != null && avatarUrl.isNotEmpty) return avatarUrl;
    }
    return _authController.firebaseUser?.photoURL;
  }

  Future<String?> _resolveActivityTitle() async {
    final activityId = _activityId;
    if (activityId == null) return null;
    final activity = await _activityRepo.getActivity(activityId);
    return activity?.title;
  }

  void _upsertOptimisticMoment(Moment moment) {
    if (Get.isRegistered<MemoryWallController>()) {
      Get.find<MemoryWallController>().upsertOptimisticMoment(moment);
    }
    if (moment.visibility != AppConstants.visibilityPersonalOnly &&
        Get.isRegistered<FeedController>()) {
      Get.find<FeedController>().upsertOptimisticMoment(moment);
    }
  }

  void _updateOptimisticMoment(
    String momentId, {
    MomentMedia? media,
    MomentSyncStatus? syncStatus,
    double? uploadProgress,
  }) {
    if (Get.isRegistered<MemoryWallController>()) {
      Get.find<MemoryWallController>().updateOptimisticMoment(
        momentId,
        media: media,
        syncStatus: syncStatus,
        uploadProgress: uploadProgress,
      );
    }
    if (Get.isRegistered<FeedController>()) {
      Get.find<FeedController>().updateOptimisticMoment(
        momentId,
        media: media,
        syncStatus: syncStatus,
        uploadProgress: uploadProgress,
      );
    }
  }

  MomentSyncStatus _syncStatusForStage(MediaUploadStage stage) {
    switch (stage) {
      case MediaUploadStage.preparing:
        return MomentSyncStatus.processing;
      case MediaUploadStage.uploading:
        return MomentSyncStatus.uploading;
      case MediaUploadStage.finalizing:
        return MomentSyncStatus.finalizing;
      case MediaUploadStage.complete:
        return MomentSyncStatus.synced;
    }
  }

  @override
  void onClose() {
    captionController.dispose();
    super.onClose();
  }
}
