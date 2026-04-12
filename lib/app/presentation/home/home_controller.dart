import 'package:get/get.dart';
import 'package:done_drop/features/auth/presentation/controllers/auth_controller.dart';
import 'package:done_drop/features/auth/repositories/user_profile_repository.dart';
import 'package:done_drop/core/models/user_profile.dart';
import 'package:done_drop/core/models/activity.dart';
import 'package:done_drop/core/models/activity_instance.dart';
import 'package:done_drop/firebase/repositories/activity_repository.dart';
import 'package:done_drop/core/models/completion_log.dart';

/// Home controller — manages bottom nav state and provides data to HomeScreen tabs.
class HomeController extends GetxController {
  HomeController();

  late final ActivityRepository _activityRepo;
  AuthController get _authController => Get.find<AuthController>();
  UserProfileRepository get _userProfileRepo => Get.find<UserProfileRepository>();

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

  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _activityRepo = ActivityRepository(Get.find());
    _watchProfile();
    _watchActivities();
    _watchTodayInstances();
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

    _activityRepo.watchActiveActivities(uid).listen((list) {
      activities.value = list;
      _recalcStats();
      isLoading.value = false;
    });

    _activityRepo.watchCompletionLogs(uid, limit: 100).listen((logs) {
      weekLogs.value = logs;
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
      _recalcStats();
    });
  }

  void _recalcStats() {
    final instances = todayInstances.values.toList();
    completedToday.value = instances.where((i) => i.isCompleted).length;
    pendingToday.value = instances.where((i) => i.isPending && !i.isOverdue).length;
    overdueToday.value = instances.where((i) => i.isOverdue).length;

    if (activities.isNotEmpty) {
      currentBestStreak.value = activities
          .map((a) => a.currentStreak)
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
  Future<void> completeActivity(String activityId) async {
    final uid = _userId;
    if (uid == null) return;

    final instance = await _activityRepo.getOrCreateTodayInstance(activityId, uid);
    if (!instance.isCompleted) {
      await _activityRepo.completeInstance(instance.id);
      await _activityRepo.incrementStreak(activityId);
    }
  }

  /// Archive an activity.
  Future<void> archiveActivity(String activityId) async {
    await _activityRepo.archiveActivity(activityId);
  }

  void onNavTap(int index) {
    navIndex.value = index;
  }

  Future<void> signOut() async {
    await _authController.signOut();
  }
}
