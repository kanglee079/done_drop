import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:done_drop/core/constants/app_constants.dart';
import 'package:done_drop/core/models/activity.dart';
import 'package:done_drop/core/models/activity_instance.dart';
import 'package:done_drop/core/models/completion_log.dart';
import 'package:done_drop/core/services/activity_completion_service.dart';

/// Repository for discipline activities, instances, and completion logs.
class ActivityRepository implements HabitCompletionRepository {
  ActivityRepository(this._db);
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _activityCol =>
      _db.collection(AppConstants.colActivities);

  CollectionReference<Map<String, dynamic>> get _instanceCol =>
      _db.collection(AppConstants.colActivityInstances);

  CollectionReference<Map<String, dynamic>> get _logCol =>
      _db.collection(AppConstants.colCompletionLogs);

  // ══════════════════════════════════════════════════════════════════
  // ACTIVITIES
  // ══════════════════════════════════════════════════════════════════

  Stream<List<Activity>> watchActiveActivities(String userId) {
    return _activityCol
        .where('ownerId', isEqualTo: userId)
        .where('isArchived', isEqualTo: false)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => Activity.fromFirestore(d.data())).toList(),
        );
  }

  Stream<List<Activity>> watchArchivedActivities(String userId) {
    return _activityCol
        .where('ownerId', isEqualTo: userId)
        .where('isArchived', isEqualTo: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => Activity.fromFirestore(d.data())).toList(),
        );
  }

  Future<Activity?> getActivity(String activityId) async {
    final doc = await _activityCol.doc(activityId).get();
    if (!doc.exists) return null;
    return Activity.fromFirestore(doc.data()!);
  }

  Future<void> createActivity(Activity activity) async {
    await _activityCol.doc(activity.id).set(activity.toFirestore());
  }

  Future<void> updateActivity(Activity activity) async {
    await _activityCol.doc(activity.id).update({
      ...activity.toFirestore(),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> archiveActivity(String activityId) async {
    await _activityCol.doc(activityId).update({
      'isArchived': true,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> unarchiveActivity(String activityId) async {
    await _activityCol.doc(activityId).update({
      'isArchived': false,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  /// Increment streak on activity after completion.
  Future<void> incrementStreak(String activityId) async {
    final ref = _activityCol.doc(activityId);
    final doc = await ref.get();
    if (!doc.exists) return;

    final data = doc.data()!;
    final current = (data['currentStreak'] as int?) ?? 0;
    final longest = (data['longestStreak'] as int?) ?? 0;
    final newStreak = current + 1;

    await ref.update({
      'currentStreak': newStreak,
      'longestStreak': newStreak > longest ? newStreak : longest,
      'lastCompletedAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  /// Reset streak on activity (called when user misses a day).
  Future<void> resetStreak(String activityId) async {
    await _activityCol.doc(activityId).update({
      'currentStreak': 0,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  // ══════════════════════════════════════════════════════════════════
  // ACTIVITY INSTANCES
  // ══════════════════════════════════════════════════════════════════

  /// Get instance for a specific activity on a specific date.
  Future<ActivityInstance?> getInstance(
    String activityId,
    String ownerId,
    DateTime date,
  ) async {
    final dateStr = _dateToString(date);
    final snap = await _instanceCol
        .where('ownerId', isEqualTo: ownerId)
        .where('activityId', isEqualTo: activityId)
        .where('date', isEqualTo: dateStr)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return ActivityInstance.fromFirestore(snap.docs.first.data());
  }

  /// Watch today's instances for all active activities.
  Stream<List<ActivityInstance>> watchTodayInstances(String userId) {
    final today = _dateToString(DateTime.now());
    return _instanceCol
        .where('ownerId', isEqualTo: userId)
        .where('date', isEqualTo: today)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => ActivityInstance.fromFirestore(d.data()))
              .toList(),
        );
  }

  /// Create or get today's instance for an activity.
  Future<ActivityInstance> getOrCreateTodayInstance(
    String activityId,
    String ownerId,
  ) async {
    final today = DateTime.now();
    final dateStr = _dateToString(today);

    final snap = await _instanceCol
        .where('activityId', isEqualTo: activityId)
        .where('ownerId', isEqualTo: ownerId)
        .where('date', isEqualTo: dateStr)
        .limit(1)
        .get();

    if (snap.docs.isNotEmpty) {
      return ActivityInstance.fromFirestore(snap.docs.first.data());
    }

    final instance = ActivityInstance(
      id: 'inst_${activityId}_$dateStr',
      activityId: activityId,
      ownerId: ownerId,
      date: today,
      status: AppConstants.instanceStatusPending,
      createdAt: today,
      updatedAt: today,
    );

    await _instanceCol.doc(instance.id).set(instance.toFirestore());
    return instance;
  }

  /// Mark instance as completed with optional moment link.
  Future<void> completeInstance(String instanceId, {String? momentId}) async {
    final now = DateTime.now();
    await _instanceCol.doc(instanceId).update({
      'status': AppConstants.instanceStatusCompleted,
      'momentId': momentId,
      'completedAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
    });
  }

  /// Mark instance as missed.
  Future<void> missInstance(String instanceId) async {
    await _instanceCol.doc(instanceId).update({
      'status': AppConstants.instanceStatusMissed,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  /// Link a moment to an activity instance after the moment is posted.
  Future<void> linkMomentToInstance(String instanceId, String momentId) async {
    await _instanceCol.doc(instanceId).update({
      'momentId': momentId,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  /// Ensure activity instances exist for today + next N days for all active activities.
  /// Called at app startup to pre-generate instances so pending/complete tracking
  /// is ready from day one.
  Future<void> ensureUpcomingInstances(
    String userId, {
    int daysAhead = 7,
  }) async {
    final snap = await _activityCol
        .where('ownerId', isEqualTo: userId)
        .where('isArchived', isEqualTo: false)
        .get();

    if (snap.docs.isEmpty) return;

    final activityIds = snap.docs.map((d) => d.id).toList();
    final today = DateTime.now();
    final from = DateTime(today.year, today.month, today.day);
    final to = from.add(Duration(days: daysAhead - 1));

    await ensureInstancesExist(activityIds, userId, from, to);
  }

  /// Batch-create instances for all active activities for a date range.
  Future<void> ensureInstancesExist(
    List<String> activityIds,
    String ownerId,
    DateTime from,
    DateTime to,
  ) async {
    final batch = _db.batch();
    var current = from;

    while (!current.isAfter(to)) {
      for (final activityId in activityIds) {
        final dateStr = _dateToString(current);
        final instanceId = 'inst_${activityId}_$dateStr';

        final snap = await _instanceCol.doc(instanceId).get();
        if (!snap.exists) {
          final instance = ActivityInstance(
            id: instanceId,
            activityId: activityId,
            ownerId: ownerId,
            date: current,
            status: AppConstants.instanceStatusPending,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          batch.set(_instanceCol.doc(instanceId), instance.toFirestore());
        }
      }
      current = current.add(const Duration(days: 1));
    }

    await batch.commit();
  }

  // ══════════════════════════════════════════════════════════════════
  // COMPLETION LOGS
  // ══════════════════════════════════════════════════════════════════

  Future<void> createCompletionLog(CompletionLog log) async {
    await _logCol.doc(log.id).set(log.toFirestore());
  }

  Stream<List<CompletionLog>> watchCompletionLogs(
    String userId, {
    int limit = 50,
  }) {
    return _logCol
        .where('ownerId', isEqualTo: userId)
        .orderBy('completedAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => CompletionLog.fromFirestore(d.data()))
              .toList(),
        );
  }

  /// Update CompletionLog with the momentId after a proof moment is posted.
  Future<void> updateCompletionLogMomentId(
    String completionLogId,
    String momentId,
  ) async {
    await _logCol.doc(completionLogId).update({'momentId': momentId});
  }

  /// Count completions for an activity within a date range.
  Future<int> countCompletions(
    String activityId,
    String ownerId,
    DateTime from,
    DateTime to,
  ) async {
    final snap = await _logCol
        .where('ownerId', isEqualTo: ownerId)
        .where('activityId', isEqualTo: activityId)
        .where('completedAt', isGreaterThanOrEqualTo: from.toIso8601String())
        .where('completedAt', isLessThanOrEqualTo: to.toIso8601String())
        .count()
        .get();
    return snap.count ?? 0;
  }

  /// Get streak for an activity from completion logs.
  Future<int> calculateStreak(String activityId, String ownerId) async {
    final snap = await _logCol
        .where('ownerId', isEqualTo: ownerId)
        .where('activityId', isEqualTo: activityId)
        .orderBy('completedAt', descending: true)
        .limit(100)
        .get();

    if (snap.docs.isEmpty) return 0;

    int streak = 0;
    DateTime? prevDate;

    for (final doc in snap.docs) {
      final log = CompletionLog.fromFirestore(doc.data());
      final logDate = DateTime(
        log.completedAt.year,
        log.completedAt.month,
        log.completedAt.day,
      );

      if (prevDate == null) {
        streak = 1;
        prevDate = logDate;
      } else {
        final diff = prevDate.difference(logDate).inDays;
        if (diff == 1) {
          streak++;
          prevDate = logDate;
        } else {
          break;
        }
      }
    }

    return streak;
  }

  String _dateToString(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
