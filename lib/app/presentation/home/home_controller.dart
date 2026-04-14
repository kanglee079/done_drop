import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:done_drop/features/auth/presentation/controllers/auth_controller.dart';
import 'package:done_drop/features/auth/repositories/user_profile_repository.dart';
import 'package:done_drop/core/models/user_profile.dart';
import 'package:done_drop/core/models/activity.dart';
import 'package:done_drop/core/models/activity_instance.dart';
import 'package:done_drop/firebase/repositories/activity_repository.dart';
import 'package:done_drop/firebase/repositories/friend_repository.dart';
import 'package:done_drop/core/models/completion_log.dart';
import 'package:done_drop/app/routes/app_routes.dart';
import 'package:done_drop/core/services/local_cache_service.dart';
import 'package:done_drop/core/services/activity_completion_service.dart';
import 'package:done_drop/core/theme/theme.dart';
import 'package:done_drop/app/presentation/streak/streak_controller.dart';

enum HabitActionState { none, quickComplete, completeWithProof }

/// Home controller — provides data to HomeScreen tabs.
///
/// Completion logic is delegated to [CompleteHabitUseCase] —
/// there is exactly ONE code path for marking an activity done.
class HomeController extends GetxController {
  HomeController(
    this._authController,
    this._userProfileRepo,
    this._activityRepo,
    this._friendRepo,
  );

  final AuthController _authController;
  final UserProfileRepository _userProfileRepo;
  final ActivityRepository _activityRepo;
  final FriendRepository _friendRepo;

  String? get _userId => _authController.firebaseUser?.uid;
  String? get currentUserId => _userId;

  /// User profile for display
  final Rx<UserProfile?> profile = Rx<UserProfile?>(null);

  /// Active activities
  final RxList<Activity> activities = <Activity>[].obs;

  /// Archived activities shown in Me.
  final RxList<Activity> archivedActivities = <Activity>[].obs;

  /// Today's instances mapped by activityId
  final RxMap<String, ActivityInstance> todayInstances =
      <String, ActivityInstance>{}.obs;

  /// Completion logs for the week
  final RxList<CompletionLog> weekLogs = <CompletionLog>[].obs;

  /// Stats
  final RxInt completedToday = 0.obs;
  final RxInt pendingToday = 0.obs;
  final RxInt overdueToday = 0.obs;
  final RxInt currentBestStreak = 0.obs;

  /// Friend count for display in stats header
  final RxInt friendCount = 0.obs;

  /// Loading state: false once cached data is loaded (never blocks UI after first paint).
  final RxBool isLoading = true.obs;

  /// In-flight completion actions keyed by activity id.
  final RxMap<String, HabitActionState> actionStates =
      <String, HabitActionState>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _preloadCache();
    _bindCompletionService();
  }

  /// Bind our reactive state to the completion service so it can do
  /// optimistic local updates when offline.
  void _bindCompletionService() {
    if (Get.isRegistered<CompleteHabitUseCase>()) {
      final service = Get.find<CompleteHabitUseCase>();
      service.bindReactiveState(
        todayInstances: todayInstances,
        activities: activities,
      );
    }
  }

  /// Load from local cache first — synchronous, no loading spinner.
  /// Then stream Firestore data for live updates.
  Future<void> _preloadCache() async {
    final cache = LocalCacheService.instance;
    final cachedActs = cache.loadCachedActivities();
    final cachedInsts = cache.loadCachedTodayInstances();

    if (cachedActs.isNotEmpty) {
      activities.value = cachedActs
          .map((m) => Activity.fromFirestore(m))
          .toList();
    }
    if (cachedInsts.isNotEmpty) {
      todayInstances.clear();
      for (final m in cachedInsts) {
        final inst = ActivityInstance.fromFirestore(m);
        todayInstances[inst.activityId] = inst;
      }
      _recalcStats();
    }

    if (cachedActs.isNotEmpty) isLoading.value = false;

    // 2. Stream Firestore data in background
    _watchProfile();
    _watchActivities();
    _watchTodayInstances();
    _watchFriendCount();

    // 3. Pre-generate future instances
    _ensureUpcomingInstances();
  }

  /// Pre-generate activity instances for today + next 7 days at app startup.
  Future<void> _ensureUpcomingInstances() async {
    final uid = _userId;
    if (uid == null) return;
    try {
      await _activityRepo.ensureUpcomingInstances(uid, daysAhead: 7);
    } catch (_) {
      // Non-critical: instances are created on-demand when accessed anyway
    }
  }

  void _watchFriendCount() {
    final uid = _userId;
    if (uid == null) return;
    _friendRepo.watchFriendships(uid).listen((list) {
      friendCount.value = list.length;
    });
  }

  void _watchProfile() {
    final uid = _userId;
    if (uid == null) return;
    _userProfileRepo.watchUserProfile(uid).listen((p) {
      profile.value = p;
    });
  }

  void _watchActivities() {
    final uid = _userId;
    if (uid == null) return;

    _activityRepo.watchActiveActivities(uid).listen((list) async {
      activities.value = list;
      _recalcStats();
      isLoading.value = false;
      // Persist to local cache for next startup
      await LocalCacheService.instance.cacheActivities(
        list.map((a) => a.toFirestore()).toList(),
      );
    });

    _activityRepo.watchCompletionLogs(uid, limit: 100).listen((logs) {
      weekLogs.value = logs;
    });

    _activityRepo.watchArchivedActivities(uid).listen((list) {
      archivedActivities.value = list;
    });
  }

  void _watchTodayInstances() {
    final uid = _userId;
    if (uid == null) return;

    _activityRepo.watchTodayInstances(uid).listen((instances) async {
      todayInstances.clear();
      for (final inst in instances) {
        todayInstances[inst.activityId] = inst;
      }
      _recalcStats();
      await LocalCacheService.instance.cacheTodayInstances(
        instances.map((i) => i.toFirestore()).toList(),
      );
    });
  }

  void _recalcStats() {
    final instances = todayInstances.values.toList();
    completedToday.value = instances.where((i) => i.isCompleted).length;
    pendingToday.value = instances
        .where((i) => i.isPending && !i.isOverdue)
        .length;
    overdueToday.value = instances.where((i) => i.isOverdue).length;

    if (activities.isNotEmpty) {
      currentBestStreak.value = activities
          .map((a) => a.longestStreak)
          .reduce((a, b) => a > b ? a : b);
    } else {
      currentBestStreak.value = 0;
    }
  }

  String get greetingName {
    final displayName = profile.value?.displayName.trim();
    if (displayName == null || displayName.isEmpty) {
      return 'you';
    }
    return displayName.split(' ').first;
  }

  int get totalHabits => activities.length;

  double get todayProgress =>
      activities.isEmpty ? 0 : completedToday.value / activities.length;

  List<Activity> get overdueActivities => activities
      .where((activity) => isOverdue(activity.id))
      .toList(growable: false);

  List<Activity> get openHabits => activities
      .where(
        (activity) => !isOverdue(activity.id) && !isCompletedToday(activity.id),
      )
      .toList(growable: false);

  Activity? get nextUpHabit => openHabits.firstOrNull;

  List<Activity> get laterTodayHabits => nextUpHabit == null
      ? const <Activity>[]
      : openHabits.skip(1).toList(growable: false);

  List<Activity> get completedHabits => activities
      .where((activity) => isCompletedToday(activity.id))
      .toList(growable: false);

  List<Activity> get proofCapturedHabits => completedHabits
      .where(
        (activity) => (todayInstances[activity.id]?.momentId ?? '').isNotEmpty,
      )
      .toList(growable: false);

  int get reminderCount =>
      activities.where((activity) => activity.hasReminder).length;

  int get weeklyCompletionCount {
    final now = DateTime.now();
    final weekStart = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(const Duration(days: 6));
    return weekLogs.where((log) => !log.completedAt.isBefore(weekStart)).length;
  }

  bool isActionBusy(String activityId) => actionStates.containsKey(activityId);

  HabitActionState actionStateFor(String activityId) =>
      actionStates[activityId] ?? HabitActionState.none;

  /// Check if an activity is completed today.
  bool isCompletedToday(String activityId) =>
      todayInstances[activityId]?.isCompleted ?? false;

  /// Check if an activity is pending today.
  bool isPendingToday(String activityId) {
    final inst = todayInstances[activityId];
    if (inst == null) return false;
    return inst.isPending && !inst.isOverdue;
  }

  /// Check if an activity is overdue.
  bool isOverdue(String activityId) =>
      todayInstances[activityId]?.isOverdue ?? false;

  /// Get today's instance for an activity.
  ActivityInstance? getInstance(String activityId) =>
      todayInstances[activityId];

  /// Create a new activity.
  Future<void> createActivity({
    required String title,
    String? description,
    String? category,
    String? iconKey,
    String? colorHex,
    String recurrence = 'daily',
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
    await _activityRepo.getOrCreateTodayInstance(activity.id, uid);
  }

  /// Complete an activity for today.
  /// Delegates to [CompleteHabitUseCase] for consistent online/offline handling.
  /// Returns the [CompletionResult] so UI can decide next steps.
  Future<CompletionResult?> completeActivity(String activityId) async {
    return _runCompletionAction(
      activityId: activityId,
      actionState: HabitActionState.quickComplete,
      afterSuccess: (_) async {},
    );
  }

  /// Complete an activity and immediately open camera to capture proof moment.
  /// Uses the same [CompleteHabitUseCase] as quick-complete, then navigates.
  Future<CompletionResult?> completeAndOpenCapture(String activityId) async {
    return _runCompletionAction(
      activityId: activityId,
      actionState: HabitActionState.completeWithProof,
      afterSuccess: (result) async {
        await Get.toNamed(
          AppRoutes.capture,
          arguments: {
            'activityId': activityId,
            'activityInstanceId': result.instance.id,
            'completionLogId': result.log.id,
          },
        );
      },
    );
  }

  /// Archive an activity.
  Future<void> archiveActivity(String activityId) async {
    await _activityRepo.archiveActivity(activityId);
  }

  /// Mark today's instance of an activity as missed.
  Future<void> missActivity(String activityId) async {
    final uid = _userId;
    if (uid == null) return;
    final instance = await _activityRepo.getOrCreateTodayInstance(
      activityId,
      uid,
    );
    if (!instance.isCompleted) {
      await _activityRepo.missInstance(instance.id);
      await _activityRepo.resetStreak(activityId);
      await LocalCacheService.instance.invalidateTodayInstances();
    }
  }

  Future<void> signOut() async {
    await LocalCacheService.instance.clearAll();
    await _authController.signOut();
  }

  Future<CompletionResult?> _runCompletionAction({
    required String activityId,
    required HabitActionState actionState,
    required Future<void> Function(CompletionResult result) afterSuccess,
  }) async {
    final uid = _userId;
    if (uid == null || isActionBusy(activityId)) return null;

    actionStates[activityId] = actionState;

    try {
      final useCase = Get.find<CompleteHabitUseCase>();
      final result = await useCase(activityId: activityId, userId: uid);

      if (result != null) {
        _recalcStats();
        _notifyStreakMilestone(result);
        await afterSuccess(result);
      }

      return result;
    } catch (_) {
      Get.snackbar(
        'Completion failed',
        'Could not complete habit. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return null;
    } finally {
      actionStates.remove(activityId);
    }
  }

  void _notifyStreakMilestone(CompletionResult result) {
    if (!Get.isRegistered<StreakController>()) return;
    final activity = result.activity;
    if (activity == null) return;
    Get.find<StreakController>().onActivityCompleted(
      activity: activity,
      previousStreak: result.previousStreak,
      newStreak: result.newStreak,
    );
  }
}
