import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
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
import 'package:done_drop/core/services/notification_service.dart';
import 'package:done_drop/core/theme/theme.dart';
import 'package:done_drop/app/presentation/streak/streak_controller.dart';
import 'package:done_drop/core/utils/activity_utils.dart';
import 'package:done_drop/l10n/l10n.dart';

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

  StreamSubscription<User?>? _authStateSubscription;
  StreamSubscription<UserProfile?>? _profileSubscription;
  StreamSubscription<List<Activity>>? _activeActivitiesSubscription;
  StreamSubscription<List<CompletionLog>>? _completionLogsSubscription;
  StreamSubscription<List<Activity>>? _archivedActivitiesSubscription;
  StreamSubscription<List<ActivityInstance>>? _todayInstancesSubscription;
  StreamSubscription<dynamic>? _friendCountSubscription;
  String? _boundUserId;

  @override
  void onInit() {
    super.onInit();
    _bindCompletionService();
    _handleAuthUserChanged(_authController.firebaseUser);
    _authStateSubscription = _authController.authStateStream.listen(
      _handleAuthUserChanged,
    );
  }

  @override
  void onClose() {
    _authStateSubscription?.cancel();
    _cancelUserSubscriptions();
    super.onClose();
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

  void _handleAuthUserChanged(User? user) {
    final uid = user?.uid;
    if (_boundUserId == uid) return;

    _boundUserId = uid;
    _cancelUserSubscriptions();
    _resetState(isLoading: uid != null);

    if (uid == null) return;

    _preloadCache(uid);
    _watchProfile(uid);
    _watchActivities(uid);
    _watchTodayInstances(uid);
    _watchFriendCount(uid);
    unawaited(_ensureUpcomingInstances(uid));
  }

  void _cancelUserSubscriptions() {
    _profileSubscription?.cancel();
    _activeActivitiesSubscription?.cancel();
    _completionLogsSubscription?.cancel();
    _archivedActivitiesSubscription?.cancel();
    _todayInstancesSubscription?.cancel();
    _friendCountSubscription?.cancel();

    _profileSubscription = null;
    _activeActivitiesSubscription = null;
    _completionLogsSubscription = null;
    _archivedActivitiesSubscription = null;
    _todayInstancesSubscription = null;
    _friendCountSubscription = null;
  }

  void _resetState({required bool isLoading}) {
    profile.value = null;
    activities.clear();
    archivedActivities.clear();
    todayInstances.clear();
    weekLogs.clear();
    actionStates.clear();
    completedToday.value = 0;
    pendingToday.value = 0;
    overdueToday.value = 0;
    currentBestStreak.value = 0;
    friendCount.value = 0;
    this.isLoading.value = isLoading;
  }

  /// Load from local cache first for the current user, then let Firestore
  /// streams replace it with live state.
  void _preloadCache(String userId) {
    final cache = LocalCacheService.instance;
    final cachedActs = cache.loadCachedActivities(userId);
    final cachedInsts = cache.loadCachedTodayInstances(userId);

    if (cachedActs.isNotEmpty) {
      activities.assignAll(
        sortActivitiesBySchedule(
          cachedActs.map((item) => Activity.fromFirestore(item)),
        ),
      );
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
  }

  /// Pre-generate activity instances for today + next 7 days at app startup.
  Future<void> _ensureUpcomingInstances(String userId) async {
    try {
      await _activityRepo.ensureUpcomingInstances(userId, daysAhead: 7);
    } catch (error, stackTrace) {
      debugPrint('[_ensureUpcomingInstances] Error: $error');
      debugPrintStack(stackTrace: stackTrace);
      // Non-critical: instances are created on-demand when accessed anyway
    }
  }

  void _watchFriendCount(String userId) {
    _friendCountSubscription = _friendRepo.watchFriendships(userId).listen(
      (list) {
        friendCount.value = list.length;
      },
      onError: (error) {
        // Non-critical: silently ignore permission errors on first load
        debugPrint('[_watchFriendCount] Error: $error');
      },
    );
  }

  void _watchProfile(String userId) {
    _profileSubscription = _userProfileRepo.watchUserProfile(userId).listen(
      (p) {
        profile.value = p;
      },
      onError: (error) {
        debugPrint('[_watchProfile] Error: $error');
      },
    );
  }

  void _watchActivities(String userId) {
    _activeActivitiesSubscription = _activityRepo.watchActiveActivities(userId).listen(
      (list) async {
        activities.assignAll(sortActivitiesBySchedule(list));
        _recalcStats();
        isLoading.value = false;
        unawaited(
          NotificationService.instance.syncActivityReminders(activities),
        );
        await LocalCacheService.instance.cacheActivities(
          userId,
          activities.map((activity) => activity.toFirestore()).toList(),
        );
      },
      onError: (error) {
        debugPrint('[_watchActivities] Error: $error');
        isLoading.value = false;
      },
    );

    _completionLogsSubscription = _activityRepo.watchCompletionLogs(
      userId,
      limit: 100,
    ).listen(
      (logs) {
        weekLogs.value = logs;
      },
      onError: (error) {
        debugPrint('[_watchCompletionLogs] Error: $error');
      },
    );

    _archivedActivitiesSubscription = _activityRepo.watchArchivedActivities(
      userId,
    ).listen(
      (list) {
        archivedActivities.value = list;
      },
      onError: (error) {
        debugPrint('[_watchArchivedActivities] Error: $error');
      },
    );
  }

  void _watchTodayInstances(String userId) {
    _todayInstancesSubscription = _activityRepo.watchTodayInstances(userId).listen(
      (instances) async {
        todayInstances.clear();
        for (final inst in instances) {
          todayInstances[inst.activityId] = inst;
        }
        _recalcStats();
        await LocalCacheService.instance.cacheTodayInstances(
          userId,
          instances.map((i) => i.toFirestore()).toList(),
        );
      },
      onError: (error) {
        debugPrint('[_watchTodayInstances] Error: $error');
      },
    );
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
      return currentL10n.greetingFallbackName;
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
    final today = DateTime(now.year, now.month, now.day);
    final optimisticInstance = ActivityInstance(
      id: 'inst_${activity.id}_${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}',
      activityId: activity.id,
      ownerId: uid,
      date: today,
      status: 'pending',
      createdAt: now,
      updatedAt: now,
    );

    final previousActivities = List<Activity>.from(activities);
    final previousInstances = Map<String, ActivityInstance>.from(
      todayInstances,
    );

    activities.assignAll(
      sortActivitiesBySchedule(<Activity>[...activities, activity]),
    );
    await NotificationService.instance.syncActivityReminders(activities);
    todayInstances[activity.id] = optimisticInstance;
    _recalcStats();
    await LocalCacheService.instance.cacheActivities(
      uid,
      activities.map((item) => item.toFirestore()).toList(),
    );
    await LocalCacheService.instance.cacheTodayInstances(
      uid,
      todayInstances.values.map((item) => item.toFirestore()).toList(),
    );

    try {
      await _activityRepo.createActivity(activity);
      await _activityRepo.getOrCreateTodayInstance(activity.id, uid);
    } catch (_) {
      activities.assignAll(previousActivities);
      await NotificationService.instance.syncActivityReminders(activities);
      todayInstances
        ..clear()
        ..addAll(previousInstances);
      _recalcStats();
      await LocalCacheService.instance.cacheActivities(
        uid,
        previousActivities.map((item) => item.toFirestore()).toList(),
      );
      await LocalCacheService.instance.cacheTodayInstances(
        uid,
        previousInstances.values.map((item) => item.toFirestore()).toList(),
      );
      rethrow;
    }
  }

  /// Proof is mandatory, so both actions route into the capture flow first.
  Future<void> completeActivity(String activityId) async {
    await _openProofCapture(
      activityId: activityId,
      actionState: HabitActionState.quickComplete,
    );
  }

  /// Open camera flow for proof-first completion.
  Future<void> completeAndOpenCapture(String activityId) async {
    await _openProofCapture(
      activityId: activityId,
      actionState: HabitActionState.completeWithProof,
    );
  }

  /// Archive an activity.
  Future<void> archiveActivity(String activityId) async {
    await _activityRepo.archiveActivity(activityId);
  }

  /// Restore a previously archived activity.
  Future<void> restoreActivity(String activityId) async {
    await _activityRepo.unarchiveActivity(activityId);
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
      await LocalCacheService.instance.invalidateTodayInstances(uid);
    }
  }

  Future<void> signOut() async {
    await LocalCacheService.instance.clearAll();
    await _authController.signOut();
  }

  Future<void> _openProofCapture({
    required String activityId,
    required HabitActionState actionState,
  }) async {
    final uid = _userId;
    if (uid == null || isActionBusy(activityId)) return;

    actionStates[activityId] = actionState;

    try {
      await Get.toNamed(
        AppRoutes.capture,
        arguments: {'activityId': activityId},
      );
    } catch (error, stackTrace) {
      debugPrint('[_openProofCapture] Error: $error');
      debugPrintStack(stackTrace: stackTrace);
      Get.snackbar(
        currentL10n.captureUnavailableTitle,
        currentL10n.captureUnavailableMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      actionStates.remove(activityId);
    }
  }

  void handleCompletionResult(CompletionResult result) {
    _recalcStats();
    _notifyStreakMilestone(result);
    Future<void>.microtask(() async {
      final uid = _userId;
      if (uid == null) return;
      await LocalCacheService.instance.cacheActivities(
        uid,
        activities.map((activity) => activity.toFirestore()).toList(),
      );
      await LocalCacheService.instance.cacheTodayInstances(
        uid,
        todayInstances.values.map((instance) => instance.toFirestore()).toList(),
      );
    });
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
