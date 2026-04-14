import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:done_drop/core/models/activity.dart';
import 'package:done_drop/core/models/activity_instance.dart';
import 'package:done_drop/core/models/completion_log.dart';
import 'package:done_drop/core/constants/app_constants.dart';

abstract class HabitCompletionRepository {
  Future<ActivityInstance> getOrCreateTodayInstance(
    String activityId,
    String ownerId,
  );

  Future<void> completeInstance(String instanceId, {String? momentId});

  Future<void> createCompletionLog(CompletionLog log);

  Future<void> incrementStreak(String activityId);
}

abstract class ConnectivityStatusReader {
  bool get isOnlineNow;
}

abstract class HabitCompletionQueue {
  Future<void> queueCompleteHabit({
    required String activityId,
    required String instanceId,
    required String ownerId,
    required String completionLogId,
    required DateTime completedAt,
  });
}

/// Single completion pipeline for DoneDrop's discipline loop.
///
/// Both "Complete now" and "Complete + proof" use this flow first.
/// UI layers only decide what happens after a successful completion.
class CompleteHabitUseCase {
  CompleteHabitUseCase({
    required HabitCompletionRepository activityRepository,
    required ConnectivityStatusReader connectivity,
    required HabitCompletionQueue offlineQueue,
    required Future<void> Function() invalidateTodayInstances,
    this.onCompletionHaptic = HapticFeedback.mediumImpact,
  }) : _activityRepository = activityRepository,
       _connectivity = connectivity,
       _offlineQueue = offlineQueue,
       _invalidateTodayInstances = invalidateTodayInstances;

  final HabitCompletionRepository _activityRepository;
  final ConnectivityStatusReader _connectivity;
  final HabitCompletionQueue _offlineQueue;
  final Future<void> Function() _invalidateTodayInstances;
  final Future<void> Function() onCompletionHaptic;

  /// Reactive map of today's instances — shared with HomeController for
  /// optimistic local updates and immediate post-completion UI.
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

  /// Completes a habit for the current day.
  ///
  /// Returns `null` when the instance was already completed.
  Future<CompletionResult?> call({
    required String activityId,
    required String userId,
  }) async {
    try {
      final instance = await _activityRepository.getOrCreateTodayInstance(
        activityId,
        userId,
      );
      if (instance.isCompleted) return null;

      final activity = _activities?.firstWhereOrNull((a) => a.id == activityId);
      final previousStreak = activity?.currentStreak ?? 0;
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

      final isOnline = _connectivity.isOnlineNow;

      if (!isOnline) {
        await _offlineQueue.queueCompleteHabit(
          activityId: activityId,
          instanceId: instance.id,
          ownerId: userId,
          completionLogId: logId,
          completedAt: now,
        );
      } else {
        await _activityRepository.completeInstance(instance.id);
        await _activityRepository.createCompletionLog(log);
        await _activityRepository.incrementStreak(activityId);
        await _invalidateTodayInstances();
      }

      final updatedInstance = instance.copyWith(
        status: AppConstants.instanceStatusCompleted,
        completedAt: now,
        updatedAt: now,
      );
      final updatedActivity = activity?.copyWith(
        currentStreak: previousStreak + 1,
        longestStreak: (previousStreak + 1) > activity.longestStreak
            ? previousStreak + 1
            : activity.longestStreak,
        lastCompletedAt: now,
        updatedAt: now,
      );

      _applyOptimisticUpdate(
        activityId: activityId,
        updatedInstance: updatedInstance,
        updatedActivity: updatedActivity,
      );
      await onCompletionHaptic();

      return CompletionResult(
        log: log,
        instance: updatedInstance,
        activity: updatedActivity,
        activityId: activityId,
        previousStreak: previousStreak,
        newStreak: previousStreak + 1,
        wasOffline: !isOnline,
      );
    } catch (e) {
      Get.log('CompleteHabitUseCase.call failed: $e');
      rethrow;
    }
  }

  void _applyOptimisticUpdate({
    required String activityId,
    required ActivityInstance updatedInstance,
    required Activity? updatedActivity,
  }) {
    _todayInstances?[activityId] = updatedInstance;

    if (_activities == null || updatedActivity == null) return;
    final activityIndex = _activities!.indexWhere(
      (activity) => activity.id == activityId,
    );
    if (activityIndex == -1) return;
    _activities![activityIndex] = updatedActivity;
  }
}

/// Result of a successful completion. Provides all context the caller needs
/// to decide what to do next (show reward, navigate to capture, etc).
class CompletionResult {
  const CompletionResult({
    required this.log,
    required this.instance,
    required this.activity,
    required this.activityId,
    required this.previousStreak,
    required this.newStreak,
    required this.wasOffline,
  });

  final CompletionLog log;
  final ActivityInstance instance;
  final Activity? activity;
  final String activityId;
  final int previousStreak;
  final int newStreak;
  final bool wasOffline;
}

@Deprecated('Use CompleteHabitUseCase instead.')
typedef ActivityCompletionService = CompleteHabitUseCase;
