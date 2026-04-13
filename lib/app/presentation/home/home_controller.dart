import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:done_drop/features/auth/presentation/controllers/auth_controller.dart';
import 'package:done_drop/features/auth/repositories/user_profile_repository.dart';
import 'package:done_drop/core/models/user_profile.dart';
import 'package:done_drop/core/models/activity.dart';
import 'package:done_drop/core/models/activity_instance.dart';
import 'package:done_drop/firebase/repositories/activity_repository.dart';
import 'package:done_drop/firebase/repositories/friend_repository.dart';
import 'package:done_drop/core/models/completion_log.dart';
import 'package:done_drop/app/routes/app_routes.dart';
import 'package:done_drop/core/services/connectivity_service.dart';
import 'package:done_drop/core/services/offline_queue_service.dart';
import 'package:done_drop/core/services/local_cache_service.dart';
import 'package:done_drop/app/presentation/streak/streak_controller.dart';

/// Home controller — manages bottom nav state and provides data to HomeScreen tabs.
/// Uses LocalCacheService for instant startup: loads cached data synchronously,
/// then streams Firestore data in the background for live updates.
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

  /// Bottom navigation index. 0=Today, 1=Feed, 2=FAB, 3=Wall, 4=Settings.
  final navIndex = 0.obs;

  /// User profile for display
  final Rx<UserProfile?> profile = Rx<UserProfile?>(null);

  /// Active activities
  final RxList<Activity> activities = <Activity>[].obs;

  /// Today's instances mapped by activityId
  final RxMap<String, ActivityInstance> todayInstances = <String, ActivityInstance>{}.obs;

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

  @override
  void onInit() {
    super.onInit();
    _preloadCache();
  }

  /// Load from local cache first — synchronous, no loading spinner.
  /// Then stream Firestore data for live updates.
  Future<void> _preloadCache() async {
    final cache = LocalCacheService.instance;
    final cachedActs = cache.loadCachedActivities();
    final cachedInsts = cache.loadCachedTodayInstances();

    if (cachedActs.isNotEmpty) {
      activities.value = cachedActs.map((m) => Activity.fromFirestore(m)).toList();
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
    pendingToday.value = instances.where((i) => i.isPending && !i.isOverdue).length;
    overdueToday.value = instances.where((i) => i.isOverdue).length;

    if (activities.isNotEmpty) {
      currentBestStreak.value = activities
          .map((a) => a.longestStreak)
          .reduce((a, b) => a > b ? a : b);
    }
  }

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
  Future<CompletionLog?> completeActivity(String activityId) async {
    final uid = _userId;
    if (uid == null) return null;

    final instance = await _activityRepo.getOrCreateTodayInstance(activityId, uid);
    if (instance.isCompleted) return null;

    final activity = activities.firstWhereOrNull((a) => a.id == activityId);
    if (activity == null) return null;
    final previousStreak = activity.currentStreak;

    final now = DateTime.now();
    final logId = 'log_${now.millisecondsSinceEpoch}';
    final log = CompletionLog(
      id: logId,
      activityId: activityId,
      activityInstanceId: instance.id,
      ownerId: uid,
      completedAt: now,
      createdAt: now,
    );

    final connectivity = Get.find<ConnectivityService>();
    if (!connectivity.isOnline.value) {
      final queue = Get.find<OfflineQueueService>();
      await queue.queueCompleteActivity(
        activityId: activityId,
        instanceId: instance.id,
        ownerId: uid,
        completionLogId: logId,
      );
      return log;
    }

    await _activityRepo.completeInstance(instance.id);
    await _activityRepo.createCompletionLog(log);
    await _activityRepo.incrementStreak(activityId);
    await LocalCacheService.instance.invalidateTodayInstances();

    final newStreak = previousStreak + 1;
    _triggerMilestoneCelebration(activity, previousStreak, newStreak);
    
    _showCompletionRewardSheet(activityId, logId);

    return log;
  }

  void _showCompletionRewardSheet(String activityId, String logId) {
    if (Get.isBottomSheetOpen == true) return;
    
    HapticFeedback.mediumImpact();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Great job! 🎉', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Habit completed. What would you like to do next?', style: TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.check_circle_outline, color: Colors.green),
              title: const Text('Save only', style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () => Get.back(),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              tileColor: Colors.grey.withValues(alpha: 0.05),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined, color: Colors.blue),
              title: const Text('Add proof photo', style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () {
                Get.back();
                Get.toNamed(
                  AppRoutes.capture,
                  arguments: {
                    'activityId': activityId,
                    'completionLogId': logId,
                  },
                );
              },
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              tileColor: Colors.blue.withValues(alpha: 0.05),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.group_outlined, color: Colors.purple),
              title: const Text('Share to buddy', style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () {
                Get.back();
                // To be implemented in Social Layer Phase
                Get.snackbar('Coming Soon', 'Buddy delivery is under construction.');
              },
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              tileColor: Colors.purple.withValues(alpha: 0.05),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  /// Complete an activity and immediately open camera to capture proof moment.
  Future<String?> completeAndOpenCapture(String activityId) async {
    final uid = _userId;
    if (uid == null) return null;

    final instance = await _activityRepo.getOrCreateTodayInstance(activityId, uid);
    if (instance.isCompleted) return null;

    final activity = activities.firstWhereOrNull((a) => a.id == activityId);
    final previousStreak = activity?.currentStreak ?? 0;

    await _activityRepo.completeInstance(instance.id);

    final now = DateTime.now();
    final logId = 'log_${now.millisecondsSinceEpoch}';
    final log = CompletionLog(
      id: logId,
      activityId: activityId,
      activityInstanceId: instance.id,
      ownerId: uid,
      completedAt: now,
      createdAt: now,
    );
    await _activityRepo.createCompletionLog(log);
    await _activityRepo.incrementStreak(activityId);
    await LocalCacheService.instance.invalidateTodayInstances();

    if (activity != null) {
      _triggerMilestoneCelebration(activity, previousStreak, previousStreak + 1);
    }

    Get.toNamed(
      AppRoutes.capture,
      arguments: {
        'activityId': activityId,
        'completionLogId': logId,
      },
    );

    return logId;
  }

  void _triggerMilestoneCelebration(Activity activity, int before, int after) {
    if (!Get.isRegistered<StreakController>()) return;
    final streakCtrl = Get.find<StreakController>();
    streakCtrl.onActivityCompleted(
      activity: activity,
      previousStreak: before,
      newStreak: after,
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
    final instance = await _activityRepo.getOrCreateTodayInstance(activityId, uid);
    if (!instance.isCompleted) {
      await _activityRepo.missInstance(instance.id);
      await _activityRepo.resetStreak(activityId);
      await LocalCacheService.instance.invalidateTodayInstances();
    }
  }

  void onNavTap(int index) {
    navIndex.value = index;
  }

  Future<void> signOut() async {
    await LocalCacheService.instance.clearAll();
    await _authController.signOut();
  }
}

