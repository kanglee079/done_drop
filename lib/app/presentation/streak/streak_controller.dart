import 'package:get/get.dart';
import 'package:done_drop/core/models/streak.dart';
import 'package:done_drop/core/models/activity.dart';
import 'package:done_drop/core/services/streak_service.dart';

/// Manages streak state, milestone animations, and triggers celebration UI.
class StreakController extends GetxController {
  StreakController();

  late final StreakService _streakService;

  final Rx<StreakMilestone?> pendingMilestone = Rx<StreakMilestone?>(null);
  final RxBool isShowingMilestoneOverlay = false.obs;
  final RxList<StreakMilestone> pendingMultiMilestones = <StreakMilestone>[].obs;
  final RxInt streakCountBefore = 0.obs;
  final RxInt streakCountAfter = 0.obs;
  final RxString activityTitleForMilestone = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _streakService = Get.find<StreakService>();
  }

  /// Call after completing an activity. Detects milestone crossing and
  /// queues celebration if needed.
  void onActivityCompleted({
    required Activity activity,
    required int previousStreak,
    required int newStreak,
  }) {
    final crossed = _streakService.detectCrossedMilestones(previousStreak, newStreak);
    if (crossed.isEmpty) return;

    if (crossed.length == 1) {
      pendingMilestone.value = crossed.first;
      activityTitleForMilestone.value = activity.title;
      streakCountBefore.value = previousStreak;
      streakCountAfter.value = newStreak;
      pendingMultiMilestones.clear();
    } else {
      pendingMultiMilestones.value = crossed;
      activityTitleForMilestone.value = activity.title;
      streakCountBefore.value = previousStreak;
      streakCountAfter.value = newStreak;
      pendingMilestone.value = null;
    }

    isShowingMilestoneOverlay.value = true;
  }

  /// Dismiss the milestone overlay.
  void dismissMilestoneOverlay() {
    isShowingMilestoneOverlay.value = false;
    pendingMilestone.value = null;
    pendingMultiMilestones.clear();
  }

  /// Get StreakState for a single activity.
  StreakState getStreakState(Activity activity) {
    return _streakService.buildStreakState(activity);
  }

  /// Build StreakState from raw data (no full Activity needed).
  StreakState buildStreakState({
    required String activityId,
    required int currentStreak,
    required int longestStreak,
    DateTime? lastCompletedAt,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final last = lastCompletedAt != null
        ? DateTime(lastCompletedAt.year, lastCompletedAt.month, lastCompletedAt.day)
        : null;

    bool isAtRisk = false;
    int daysUntilRisk = 0;
    if (last != null && currentStreak > 0) {
      final diff = today.difference(last).inDays;
      if (diff >= 1) {
        isAtRisk = true;
        daysUntilRisk = 1 - diff;
      }
    }

    return StreakState(
      activityId: activityId,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      lastCompletedAt: lastCompletedAt,
      isAtRisk: isAtRisk,
      daysUntilRisk: daysUntilRisk,
    );
  }

  /// Calculate aggregate stats across all user activities.
  StreakAggregateStats calculateAggregateStats(List<Activity> activities) {
    return _streakService.calculateAggregateStats(activities);
  }
}
