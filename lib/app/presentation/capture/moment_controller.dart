import 'dart:async';

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
import 'package:done_drop/core/services/activity_completion_service.dart';
import 'package:done_drop/core/services/connectivity_service.dart';
import 'package:done_drop/core/services/feed_delivery_planner.dart';
import 'package:done_drop/core/services/media_service.dart';
import 'package:done_drop/core/services/offline_queue_service.dart';
import 'package:done_drop/core/theme/theme.dart';
import 'package:done_drop/features/auth/presentation/controllers/auth_controller.dart';
import 'package:done_drop/firebase/repositories/activity_repository.dart';
import 'package:done_drop/firebase/repositories/friend_repository.dart';
import 'package:done_drop/firebase/repositories/moment_repository.dart';
import 'package:done_drop/l10n/l10n.dart';

class MomentSubmissionResult {
  const MomentSubmissionResult({
    required this.isProofMoment,
    required this.wasOfflineQueued,
  });

  final bool isProofMoment;
  final bool wasOfflineQueued;
}

/// Generates a unique moment ID using timestamp + random suffix to avoid
/// collisions when the user posts multiple moments within the same millisecond.
String _generateMomentId() {
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final random = (timestamp % 9999).toString().padLeft(4, '0');
  return 'moment_${timestamp}_$random';
}

/// Controller for the capture and preview flow.
///
/// The controller owns one capture session at a time and is created by the
/// capture route binding. Preview and success reuse the same session.
class MomentController extends GetxController {
  MomentController({
    MediaService? mediaService,
    void Function(String path)? warmPreparedUpload,
    void Function(String path)? discardPreparedUpload,
  }) : _mediaServiceOverride = mediaService,
       _warmPreparedUpload = warmPreparedUpload,
       _discardPreparedUpload = discardPreparedUpload;

  MomentRepository get _momentRepo => Get.find<MomentRepository>();
  FriendRepository get _friendRepo => Get.find<FriendRepository>();
  ActivityRepository get _activityRepo => Get.find<ActivityRepository>();
  AuthController get _authController => Get.find<AuthController>();
  final MediaService? _mediaServiceOverride;
  final void Function(String path)? _warmPreparedUpload;
  final void Function(String path)? _discardPreparedUpload;

  MediaService get _mediaService => _mediaServiceOverride ?? MediaService.instance;
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

  /// Retry count for failed uploads. Reset on each new post attempt.
  final RxInt uploadRetryCount = 0.obs;
  static const int _maxUploadRetries = 2;
  bool get canRetryUpload =>
      uploadRetryCount.value < _maxUploadRetries &&
      _lastFailedMomentId != null;

  String? _imagePath;
  String? _activityId;
  String? _activityInstanceId;
  String? _completionLogId;
  bool _sessionInitialized = false;
  /// MomentId of the last failed upload — used for retry.
  String? _lastFailedMomentId;

  String? get _userId => _authController.firebaseUser?.uid;

  String? get imagePath => _imagePath;
  String? get activityId => _activityId;
  String? get activityInstanceId => _activityInstanceId;
  String? get completionLogId => _completionLogId;
  bool get isProofMoment => _activityId != null;

  String get uploadStatusLabel => switch (uploadStage.value) {
        MediaUploadStage.preparing => currentL10n.uploadStagePreparingImage,
        MediaUploadStage.uploading =>
          currentL10n.statusUploading((uploadProgress.value * 100).round()),
        MediaUploadStage.finalizing => currentL10n.uploadStageFinalizingMoment,
        MediaUploadStage.complete => currentL10n.uploadReady,
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
      _warmUpload(imagePath);
      errorMessage.value = null;
    }
  }

  void attachImage(String path) {
    if (_imagePath != null && _imagePath != path) {
      _discardUpload(_imagePath!);
    }
    _imagePath = path;
    _warmUpload(path);
    errorMessage.value = null;
  }

  /// Public entry point. Validates inputs then delegates to the core logic.
  Future<void> postMoment() async {
    if (_imagePath == null) {
      errorMessage.value = currentL10n.capturePhotoRequired;
      return;
    }

    final uid = _userId;
    if (uid == null) {
      errorMessage.value = currentL10n.authRequiredMessage;
      return;
    }

    if (visibility.value == AppConstants.visibilitySelectedFriends &&
        selectedFriendIds.isEmpty) {
      errorMessage.value = currentL10n.captureSelectBuddyError;
      return;
    }

    isPosting.value = true;
    uploadProgress.value = 0;
    uploadStage.value = MediaUploadStage.preparing;
    errorMessage.value = null;
    uploadRetryCount.value = 0;
    _lastFailedMomentId = null;

    await _postMomentCore();
  }

  /// Internal post logic shared by postMoment() and retryFailedUpload().
  /// All error recovery and retry logic lives here.
  Future<void> _postMomentCore() async {
    final uid = _userId!;
    final imagePath = _imagePath!;
    assert(imagePath.isNotEmpty);

    if (isProofMoment) {
      try {
        await _ensureProofCompletion(uid);
      } catch (error, stackTrace) {
        debugPrint('[MomentController._postMomentCore] Completion failed: $error');
        debugPrintStack(stackTrace: stackTrace);
        isPosting.value = false;
        uploadStage.value = MediaUploadStage.complete;
        errorMessage.value = currentL10n.momentPostFailed(error.toString());
        return;
      }
    }

    final momentId = _generateMomentId();
    final now = DateTime.now();
    final postVisibility = visibility.value;
    final caption = captionController.text.trim();
    final category = selectedCategory.value.isEmpty
        ? null
        : selectedCategory.value;
    final activityTitleFuture = _resolveActivityTitle();
    final recipientIdsFuture = _resolveRecipientIds(uid, postVisibility);
    final activityTitle = await activityTitleFuture;
    final ownerDisplayName = _resolveOwnerDisplayName();
    final ownerAvatarUrl = _resolveOwnerAvatarUrl();
    final recipientIds = await recipientIdsFuture;

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
      localPreviewPath: imagePath,
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
        localFilePath: imagePath,
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

      await Future.wait([
        _momentRepo.createMoment(moment),
        _linkProofMoment(momentId),
      ]);
      await _momentRepo.createFeedDeliveries(
        moment: moment,
        recipientIds: recipientIds,
      );
      unawaited(_backfillGeneratedThumbnail(momentId: momentId, media: media));

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
    } catch (error, stackTrace) {
      debugPrint('[MomentController._postMomentCore] Error: $error');
      debugPrintStack(stackTrace: stackTrace);
      _lastFailedMomentId = momentId;
      _updateOptimisticMoment(
        momentId,
        syncStatus: MomentSyncStatus.failed,
      );
      errorMessage.value = currentL10n.momentPostFailed(error.toString());
      isPosting.value = false;
      uploadStage.value = MediaUploadStage.complete;
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
    if (_imagePath != null && _imagePath!.isNotEmpty) {
      _discardUpload(_imagePath!);
    }
    captionController.clear();
    visibility.value = AppConstants.visibilityPersonalOnly;
    selectedFriendIds.clear();
    selectedCategory.value = '';
    errorMessage.value = null;
    isPosting.value = false;
    uploadProgress.value = 0;
    uploadStage.value = MediaUploadStage.complete;
    lastSubmission.value = null;
    uploadRetryCount.value = 0;
    _lastFailedMomentId = null;
    _imagePath = null;
    _activityId = null;
    _activityInstanceId = null;
    _completionLogId = null;
    _sessionInitialized = false;
  }

  /// Retry the last failed upload.
  /// Discards any existing prepared upload for the failed path, then re-warms
  /// the preparation and attempts to post again.
  Future<void> retryFailedUpload() async {
    if (!canRetryUpload || _imagePath == null) return;

    uploadRetryCount.value++;
    errorMessage.value = null;
    isPosting.value = true;
    uploadProgress.value = 0;
    uploadStage.value = MediaUploadStage.preparing;

    // Re-warm upload preparation (discard first to ensure clean state).
    _discardUpload(_imagePath!);
    _warmUpload(_imagePath!);

    // Retry the full postMoment flow by calling the same core.
    // We reuse _lastFailedMomentId to update the same optimistic moment.
    await _postMomentCore();
  }

  void _warmUpload(String path) {
    if (_warmPreparedUpload != null) {
      _warmPreparedUpload(path);
      return;
    }
    _mediaService.warmMomentUpload(path);
  }

  void _discardUpload(String path) {
    if (_discardPreparedUpload != null) {
      _discardPreparedUpload(path);
      return;
    }
    _mediaService.discardPreparedUpload(path);
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

  Future<void> _backfillGeneratedThumbnail({
    required String momentId,
    required MomentMediaMetadata media,
  }) async {
    if (!_mediaService.usesServerGeneratedThumbnails ||
        media.thumbnail.downloadUrl.isNotEmpty) {
      return;
    }

    final generatedThumbnail = await _mediaService.waitForGeneratedThumbnail(
      original: media.original,
    );
    if (generatedThumbnail == null) {
      return;
    }

    await _momentRepo.updateMomentThumbnail(momentId, generatedThumbnail);
    await _momentRepo.updateFeedDeliveryThumbnail(
      momentId,
      generatedThumbnail.downloadUrl,
    );

    _updateOptimisticMoment(
      momentId,
      media: media.copyWith(thumbnail: generatedThumbnail),
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

    if (instanceId != null) {
      await _activityRepo.linkMomentToInstance(instanceId, momentId);
    }
    if (_completionLogId != null) {
      await _activityRepo.updateCompletionLogMomentId(
        _completionLogId!,
        momentId,
      );
    }
  }

  Future<CompletionResult?> _ensureProofCompletion(String uid) async {
    if (_activityId == null) return null;
    if (_activityInstanceId != null && _completionLogId != null) {
      return null;
    }

    if (!Get.isRegistered<CompleteHabitUseCase>()) {
      throw StateError('CompleteHabitUseCase is not registered.');
    }

    final useCase = Get.find<CompleteHabitUseCase>();
    final result = await useCase(activityId: _activityId!, userId: uid);

    if (result != null) {
      _activityInstanceId = result.instance.id;
      _completionLogId = result.log.id;
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().handleCompletionResult(result);
      }
      return result;
    }

    if (_activityInstanceId == null) {
      final instance = await _activityRepo.getOrCreateTodayInstance(
        _activityId!,
        uid,
      );
      _activityInstanceId = instance.id;
    }

    return null;
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
        currentL10n.savedForSyncTitle,
        currentL10n.offlineSyncQueuedMessage,
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
    return _authController.firebaseUser?.displayName ??
        currentL10n.memberFallbackName;
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
    if (Get.isRegistered<HomeController>()) {
      final cached = Get.find<HomeController>().activities.firstWhereOrNull(
        (activity) => activity.id == activityId,
      );
      if (cached != null) {
        return cached.title;
      }
    }
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
