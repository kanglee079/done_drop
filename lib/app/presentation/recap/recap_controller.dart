import 'dart:async';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:done_drop/features/auth/presentation/controllers/auth_controller.dart';
import 'package:done_drop/firebase/repositories/moment_repository.dart';
import 'package:done_drop/firebase/repositories/activity_repository.dart';
import 'package:done_drop/core/models/moment.dart';
import 'package:done_drop/core/models/activity.dart';
import 'package:done_drop/core/services/analytics_service.dart';

/// Data class for a recap day group.
class RecapDay {
  RecapDay({required this.date, required this.moments});
  final DateTime date;
  final List<Moment> moments;
}

/// Controller for the weekly recap screen.
/// Integrates discipline activity data with proof moments.
class RecapController extends GetxController {
  RecapController();

  MomentRepository get _momentRepo => Get.find<MomentRepository>();
  ActivityRepository get _activityRepo => Get.find<ActivityRepository>();
  AuthController get _authController => Get.find<AuthController>();

  String? get _userId => _authController.firebaseUser?.uid;

  final RxList<RecapDay> days = <RecapDay>[].obs;
  final RxList<Activity> activities = <Activity>[].obs;
  final RxBool isLoading = true.obs;
  final RxInt weekCompletions = 0.obs;
  final RxInt bestStreak = 0.obs;
  StreamSubscription<List<Moment>>? _momentsSubscription;
  StreamSubscription<List<Activity>>? _activitiesSubscription;

  @override
  void onInit() {
    super.onInit();
    _loadRecap();
    _watchActivities();
  }

  void _loadRecap() {
    final uid = _userId;
    if (uid == null) {
      isLoading.value = false;
      return;
    }

    _momentsSubscription?.cancel();
    _momentsSubscription = _momentRepo
        .watchPersonalMoments(uid, limit: 200)
        .listen((moments) {
          final now = DateTime.now();
          final weekStart = now.subtract(Duration(days: now.weekday - 1));
          final startOfWeek = DateTime(
            weekStart.year,
            weekStart.month,
            weekStart.day,
          );

          final thisWeek = moments.where((m) {
            return m.createdAt.isAfter(startOfWeek) ||
                m.createdAt.isAtSameMomentAs(startOfWeek);
          }).toList();

          final grouped = <String, List<Moment>>{};
          for (final m in thisWeek) {
            final key = _dateKey(m.createdAt);
            grouped.putIfAbsent(key, () => []).add(m);
          }

          final sortedKeys = grouped.keys.toList()
            ..sort((a, b) => b.compareTo(a));
          days.value = sortedKeys.map((key) {
            final date = DateTime.parse(key);
            return RecapDay(date: date, moments: grouped[key]!);
          }).toList();

          weekCompletions.value = thisWeek.length;
          isLoading.value = false;

          AnalyticsService.instance.recapViewed(_weekKey());
        });
  }

  void _watchActivities() {
    final uid = _userId;
    if (uid == null) return;

    _activitiesSubscription?.cancel();
    _activitiesSubscription = _activityRepo.watchActiveActivities(uid).listen((
      list,
    ) {
      activities.value = list;
      if (list.isNotEmpty) {
        bestStreak.value = list
            .map((a) => a.currentStreak)
            .reduce((a, b) => a > b ? a : b);
      }
    });
  }

  int get totalMoments => days.fold(0, (sum, d) => sum + d.moments.length);

  int get streakDays {
    if (days.isEmpty) return 0;
    final now = DateTime.now();
    int streak = 0;
    DateTime check = DateTime(now.year, now.month, now.day);
    for (final day in days) {
      final dayDate = DateTime(day.date.year, day.date.month, day.date.day);
      if (dayDate.isAtSameMomentAs(check)) {
        streak++;
        check = check.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  String get weekLabel {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    final locale = Get.locale?.toLanguageTag() ?? 'en';
    final startFormat = DateFormat.MMMd(locale);
    final endDayFormat = DateFormat.d(locale);
    final endFormat = DateFormat.MMMd(locale);
    if (weekStart.month == weekEnd.month) {
      return '${startFormat.format(weekStart)} — ${endDayFormat.format(weekEnd)}';
    }
    return '${startFormat.format(weekStart)} — ${endFormat.format(weekEnd)}';
  }

  String _dateKey(DateTime d) =>
      DateTime(d.year, d.month, d.day).toIso8601String().substring(0, 10);

  String _weekKey() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    return '${weekStart.year}-W${_weekNumber(weekStart)}';
  }

  int _weekNumber(DateTime date) {
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays;
    return ((dayOfYear - date.weekday + 10) / 7).floor();
  }

  @override
  void onClose() {
    _momentsSubscription?.cancel();
    _activitiesSubscription?.cancel();
    super.onClose();
  }
}
