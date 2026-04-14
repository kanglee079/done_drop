import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:done_drop/core/models/activity.dart';
import 'package:done_drop/core/models/activity_instance.dart';
import 'package:done_drop/core/models/completion_log.dart';
import 'package:done_drop/firebase/repositories/activity_repository.dart';
import 'package:done_drop/core/services/connectivity_service.dart';
import 'package:done_drop/core/services/offline_queue_service.dart';
import 'package:done_drop/core/services/local_cache_service.dart';
import 'package:done_drop/app/presentation/streak/streak_controller.dart';

/// Single source of truth for completing an activity.
///
/// Replaces the duplicated completion logic that previously existed in:
/// - HomeController.completeActivity()
/// - HomeController.completeAndOpenCapture()
/// - MomentController.completeAndPrepareCapture()
/// - ActivityController.completeActivity()
///
/// Handles both online and offline flows consistently:
/// - Online: completes instance, creates log, increments streak, invalidates cache
/// - Offline: queues operations, updates local state optimistically
///
/// Returns a [CompletionResult] so the caller can decide what to do next
/// (show reward sheet, navigate to capture, etc).
class ActivityCompletionService extends GetxService {
  ActivityCompletionService(this._activityRepo);

  final ActivityRepository _activityRepo;

  /// Reactive map of today's instances — shared with HomeController for
  /// optimistic local updates even when offline.
  RxMap<String, ActivityInstance>? _todayInstances;

  /// Reactive activity list — needed for streak milestone detection.
  RxList<Activity>? _activities;

  /// Inject references to HomeController's reactive state so offline
  /// completions can update UI immediately.
  void bindReactiveState({
    required RxMap<String, ActivityInstance> todayInstances,
    required RxList<Activity> activities,
  }) {
    _todayInstances = todayInstances;
    _activities = activities;
  }

  /// Complete an activity for today.
  ///
  /// This is the ONLY entry point for marking an activity done.
  /// Both "quick complete" and "complete + proof" call this first.
  ///
  /// Returns [CompletionResult] with log and metadata, or null if already completed.
  Future<CompletionResult?> completeActivity({
    required String activityId,
    required String userId,
  }) async {
    try {
      // 1. Get or create today's instance
      final instance =
          await _activityRepo.getOrCreateTodayInstance(activityId, userId);
      if (instance.isCompleted) return null;

      // 2. Find activity for streak context
      final activity =
          _activities?.firstWhereOrNull((a) => a.id == activityId);
      final previousStreak = activity?.currentStreak ?? 0;

      // 3. Create completion log
      final now = DateTime.now();
      final logId = 'log_${now.millisecondsSinceEpoch}';
      final log = CompletionLog(
        id: logId,
        activityId: activityId,
        activityInstanceId: instance.id,
        ownerId: userId,
        completedAt: now,
        createdAt: now,
      );

      // 4. Check connectivity
      final connectivity = Get.find<ConnectivityService>();
      final isOnline = connectivity.isOnline.value;

      if (!isOnline) {
        // ── Offline path ──────────────────────────────────────────────
        final queue = Get.find<OfflineQueueService>();
        await queue.queueCompleteActivity(
          activityId: activityId,
          instanceId: instance.id,
          ownerId: userId,
          completionLogId: logId,
        );

        // Optimistic local update so UI reacts immediately
        _applyOptimisticUpdate(instance, activityId, previousStreak);
      } else {
        // ── Online path ───────────────────────────────────────────────
        await _activityRepo.completeInstance(instance.id);
        await _activityRepo.createCompletionLog(log);
        await _activityRepo.incrementStreak(activityId);
        await LocalCacheService.instance.invalidateTodayInstances();
      }

      // 5. Haptic feedback
      HapticFeedback.mediumImpact();

      // 6. Trigger milestone celebration (works for both online/offline)
      _triggerMilestoneCelebration(activity, previousStreak, previousStreak + 1);

      return CompletionResult(
        log: log,
        activityId: activityId,
        previousStreak: previousStreak,
        newStreak: previousStreak + 1,
        wasOffline: !isOnline,
      );
    } catch (e) {
      // Surface the error to the caller so UI can present it.
      Get.log('ActivityCompletionService.completeActivity failed: $e');
      rethrow;
    }
  }

  /// Apply optimistic update to the local reactive state so UI updates
  /// immediately even when offline.
  void _applyOptimisticUpdate(
    ActivityInstance instance,
    String activityId,
    int previousStreak,
  ) {
    if (_todayInstances == null) return;

    // Mark instance completed locally
    final updatedInstance = ActivityInstance(
      id: instance.id,
      activityId: instance.activityId,
      ownerId: instance.ownerId,
      date: instance.date,
      status: 'completed',
      completedAt: DateTime.now(),
      createdAt: instance.createdAt,
      updatedAt: DateTime.now(),
    );
    _todayInstances![activityId] = updatedInstance;
  }

  void _triggerMilestoneCelebration(
    Activity? activity,
    int before,
    int after,
  ) {
    if (activity == null) return;
    if (!Get.isRegistered<StreakController>()) return;
    final streakCtrl = Get.find<StreakController>();
    streakCtrl.onActivityCompleted(
      activity: activity,
      previousStreak: before,
      newStreak: after,
    );
  }
}

/// Result of a successful completion. Provides all context the caller needs
/// to decide what to do next (show reward, navigate to capture, etc).
class CompletionResult {
  const CompletionResult({
    required this.log,
    required this.activityId,
    required this.previousStreak,
    required this.newStreak,
    required this.wasOffline,
  });

  final CompletionLog log;
  final String activityId;
  final int previousStreak;
  final int newStreak;
  final bool wasOffline;
}
