import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:done_drop/features/auth/presentation/controllers/auth_controller.dart';
import 'package:done_drop/firebase/repositories/moment_repository.dart';
import 'package:done_drop/firebase/repositories/friend_repository.dart';
import 'package:done_drop/firebase/repositories/activity_repository.dart';
import 'package:done_drop/core/models/moment.dart';
import 'package:done_drop/core/models/completion_log.dart';
import 'package:done_drop/core/services/media_service.dart';
import 'package:done_drop/core/services/analytics_service.dart';
import 'package:done_drop/core/services/connectivity_service.dart';
import 'package:done_drop/core/services/offline_queue_service.dart';
import 'package:done_drop/app/routes/app_routes.dart';
import 'package:done_drop/core/constants/app_constants.dart';

/// Controller for the capture/post moment flow.
///
/// Supports two modes:
/// 1. Free capture — user opens capture screen directly (no linked activity)
/// 2. Proof moment — user completes an activity and is redirected to capture
///    (activityId + completionLogId passed via route arguments)
///
/// Both modes post a Moment with optional activity linkage.
class MomentController extends GetxController {
  MomentController();

  MomentRepository get _momentRepo => Get.find<MomentRepository>();
  FriendRepository get _friendRepo => Get.find<FriendRepository>();
  ActivityRepository get _activityRepo => Get.find<ActivityRepository>();
  AuthController get _authController => Get.find<AuthController>();
  MediaService get _mediaService => MediaService.instance;

  // ── Proof moment context ────────────────────────────────────────────────
  // Set when user completes an activity from Today tab
  String? _activityId;
  String? _completionLogId;

  /// Whether this moment is a proof of a completed activity.
  bool get isProofMoment => _activityId != null;

  /// ── Post form state ──────────────────────────────────────────────────
  final captionController = TextEditingController();
  final Rx<String> visibility = AppConstants.visibilityPersonalOnly.obs;
  final RxList<String> selectedFriendIds = <String>[].obs;
  final Rx<String> selectedCategory = ''.obs;

  // Post state
  final isPosting = false.obs;
  final RxnString errorMessage = RxnString();

  String? _imagePath;

  /// Public getter for the selected image path.
  String? get imagePath => _imagePath;

  /// Whether the last post was queued for offline sync.
  bool wasOfflineQueued = false;

  void setImagePath(String path) {
    _imagePath = path;
  }

  String? get _userId => _authController.firebaseUser?.uid;

  /// Initialize proof moment context from route arguments.
  /// Call this from PreviewScreen before using postMoment.
  /// ALWAYS resets proof context first to prevent stale state from previous flows.
  void initFromArgs(Map<String, dynamic>? args) {
    // Always clear proof context to prevent stale state
    _activityId = null;
    _completionLogId = null;

    if (args == null) return;
    _activityId = args['activityId'] as String?;
    _completionLogId = args['completionLogId'] as String?;
  }

  // NOTE: completeAndPrepareCapture() has been removed.
  // Activity completion is now handled by ActivityCompletionService
  // before entering the capture flow. This controller only handles
  // the moment posting + media upload concerns.

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

    // Build moment data for offline queueing
    final postVisibility = visibility.value;
    final friendsIds = postVisibility == AppConstants.visibilitySelectedFriends
        ? selectedFriendIds.toList()
        : <String>[];

    final momentData = {
      'visibility': postVisibility,
      'selectedFriendIds': friendsIds,
      'caption': captionController.text.trim(),
      'category': selectedCategory.value.isEmpty ? null : selectedCategory.value,
      'completedAt': now.toIso8601String(),
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
    };

    try {
      // Check connectivity
      final connectivity = Get.find<ConnectivityService>();
      if (!connectivity.isOnline.value) {
        // Offline: queue for later sync
        wasOfflineQueued = true;
        final queue = Get.find<OfflineQueueService>();
        await queue.queueCreateMoment(
          momentId: momentId,
          ownerId: uid,
          momentData: momentData,
          localMediaPath: _imagePath!,
          activityId: _activityId,
          completionLogId: _completionLogId,
        );
        isPosting.value = false;
        // Navigate to success — moment will appear after sync
        Get.offNamed(AppRoutes.success);
        return;
      }

      // Online: upload normally
      final media = await _mediaService.uploadMomentImages(
        userId: uid,
        momentId: momentId,
        localFilePath: _imagePath!,
      );

      // Create moment document in Firestore with optional activity linkage
      final moment = Moment(
        id: momentId,
        ownerId: uid,
        activityId: _activityId,
        activityInstanceId: null,
        completionLogId: _completionLogId,
        visibility: postVisibility,
        selectedFriendIds: friendsIds,
        media: media,
        caption: captionController.text.trim(),
        category: selectedCategory.value.isEmpty ? null : selectedCategory.value,
        completedAt: now,
        createdAt: now,
        updatedAt: now,
        reactionCounts: const {},
        isDeleted: false,
        moderationStatus: 'approved',
      );

      await _momentRepo.createMoment(moment);

      // Update activity instance with momentId if this is a proof moment
      if (_activityId != null && _completionLogId != null) {
        final instance = await _activityRepo.getOrCreateTodayInstance(_activityId!, uid);
        await _activityRepo.linkMomentToInstance(instance.id, momentId);
        // Link moment back to CompletionLog for audit trail
        await _activityRepo.updateCompletionLogMomentId(_completionLogId!, momentId);
      }

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
    _activityId = null;
    _completionLogId = null;
    errorMessage.value = null;
  }

  @override
  void onClose() {
    captionController.dispose();
    super.onClose();
  }
}
