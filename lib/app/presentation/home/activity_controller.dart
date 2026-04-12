import 'package:get/get.dart';
import 'package:done_drop/features/auth/presentation/controllers/auth_controller.dart';
import 'package:done_drop/firebase/repositories/activity_repository.dart';
import 'package:done_drop/core/models/activity.dart';
import 'package:done_drop/core/models/activity_instance.dart';
import 'package:done_drop/core/constants/app_constants.dart';

/// Controller for the discipline activity system.
/// Manages activities, today's instances, and completion flow.
class ActivityController extends GetxController {
  ActivityController();

  final ActivityRepository _activityRepo = ActivityRepository(Get.find());

  AuthController get _authController => Get.find<AuthController>();
  String? get _userId => _authController.firebaseUser?.uid;

  // ── State ───────────────────────────────────────────────────────────

  /// All active activities
  final RxList<Activity> activities = <Activity>[].obs;

  /// Today's instances mapped by activityId
  final RxMap<String, ActivityInstance> todayInstances = <String, ActivityInstance>{}.obs;

  /// Overall stats
  final RxInt totalStreak = 0.obs;
  final RxInt completedToday = 0.obs;
  final RxInt pendingToday = 0.obs;
  final RxInt missedToday = 0.obs;

  final RxBool isLoading = true.obs;

  // ── Lifecycle ──────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _authController.firebaseUser?.uid;
    _watchActivities();
    _watchTodayInstances();
  }

  void _watchActivities() {
    final uid = _userId;
    if (uid == null) return;

    _activityRepo.watchActiveActivities(uid).listen((list) {
      activities.value = list;
      _updateStats();
    });
  }

  void _watchTodayInstances() {
    final uid = _userId;
    if (uid == null) return;

    _activityRepo.watchTodayInstances(uid).listen((instances) {
      todayInstances.clear();
      for (final inst in instances) {
        todayInstances[inst.activityId] = inst;
      }
      _updateStats();
      isLoading.value = false;
    });
  }

  void _updateStats() {
    final instances = todayInstances.values.toList();
    completedToday.value = instances.where((i) => i.isCompleted).length;
    pendingToday.value = instances.where((i) => i.isPending && !i.isOverdue).length;
    missedToday.value = instances.where((i) => i.isMissed || i.isOverdue).length;

    // Sum of best streaks across all activities
    if (activities.isNotEmpty) {
      totalStreak.value = activities
          .map((a) => a.currentStreak)
          .reduce((a, b) => a > b ? a : b);
    }
  }

  // ── Actions ────────────────────────────────────────────────────────

  Future<void> createActivity({
    required String title,
    String? description,
    String? category,
    String? iconKey,
    String? colorHex,
    String recurrence = AppConstants.recurrenceDaily,
    String? reminderTime,
  }) async {
    final uid = _userId;
    if (uid == null) return;

    final now = DateTime.now();
    final activity = Activity(
      id: 'act_${now.millisecondsSinceEpoch}',
      ownerId: uid,
      title: title,
      description: description,
      category: category,
      iconKey: iconKey,
      colorHex: colorHex,
      recurrence: recurrence,
      reminderTime: reminderTime,
      currentStreak: 0,
      longestStreak: 0,
      createdAt: now,
      updatedAt: now,
    );

    await _activityRepo.createActivity(activity);

    // Create today's instance
    await _activityRepo.getOrCreateTodayInstance(activity.id, uid);
  }

  Future<void> updateActivity(Activity activity) async {
    await _activityRepo.updateActivity(activity);
  }

  Future<void> archiveActivity(String activityId) async {
    await _activityRepo.archiveActivity(activityId);
  }

  Future<void> unarchiveActivity(String activityId) async {
    await _activityRepo.unarchiveActivity(activityId);
  }

  /// Mark an activity as completed for today.
  Future<ActivityInstance?> completeActivity(String activityId) async {
    final uid = _userId;
    if (uid == null) throw Exception('Not signed in');

    // Create or get today's instance
    final instance = await _activityRepo.getOrCreateTodayInstance(activityId, uid);

    if (!instance.isCompleted) {
      await _activityRepo.completeInstance(instance.id);
      await _activityRepo.incrementStreak(activityId);
    }

    return _activityRepo.getInstance(activityId, DateTime.now()) ?? instance;
  }

  /// Skip an activity for today (mark as missed).
  Future<void> skipActivity(String activityId) async {
    final uid = _userId;
    if (uid == null) return;

    final instance = await _activityRepo.getOrCreateTodayInstance(activityId, uid);
    if (!instance.isCompleted) {
      await _activityRepo.missInstance(instance.id);
      await _activityRepo.resetStreak(activityId);
    }
  }

  /// Check if a specific activity has a completed instance today.
  bool isCompletedToday(String activityId) {
    return todayInstances[activityId]?.isCompleted ?? false;
  }

  /// Check if a specific activity has a pending instance today.
  bool isPendingToday(String activityId) {
    final inst = todayInstances[activityId];
    if (inst == null) return false;
    return inst.isPending && !inst.isOverdue;
  }

  /// Check if a specific activity is overdue.
  bool isOverdue(String activityId) {
    return todayInstances[activityId]?.isOverdue ?? false;
  }

  /// Get the instance for an activity today.
  ActivityInstance? getTodayInstance(String activityId) {
    return todayInstances[activityId];
  }
}
