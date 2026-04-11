import 'package:get/get.dart';
import 'package:done_drop/features/auth/presentation/controllers/auth_controller.dart';
import 'package:done_drop/firebase/repositories/moment_repository.dart';
import 'package:done_drop/core/models/moment.dart';
import 'package:done_drop/core/services/analytics_service.dart';

/// Data class for a recap day group.
class RecapDay {
  RecapDay({required this.date, required this.moments});
  final DateTime date;
  final List<Moment> moments;
}

/// Controller for the weekly recap screen.
class RecapController extends GetxController {
  RecapController();

  MomentRepository get _momentRepo => Get.find<MomentRepository>();
  AuthController get _authController => Get.find<AuthController>();

  String? get _userId => _authController.firebaseUser?.uid;

  final RxList<RecapDay> days = <RecapDay>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadRecap();
  }

  void _loadRecap() {
    final uid = _userId;
    if (uid == null) {
      isLoading.value = false;
      return;
    }

    // Subscribe to personal moments and compute weekly recap
    _momentRepo.watchPersonalMoments(uid, limit: 200).listen((moments) {
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final startOfWeek = DateTime(weekStart.year, weekStart.month, weekStart.day);

      // Filter to this week only
      final thisWeek = moments.where((m) {
        return m.createdAt.isAfter(startOfWeek) ||
            m.createdAt.isAtSameMomentAs(startOfWeek);
      }).toList();

      // Group by day
      final grouped = <String, List<Moment>>{};
      for (final m in thisWeek) {
        final key = _dateKey(m.createdAt);
        grouped.putIfAbsent(key, () => []).add(m);
      }

      // Build sorted list of RecapDay
      final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
      days.value = sortedKeys.map((key) {
        final date = DateTime.parse(key);
        return RecapDay(date: date, moments: grouped[key]!);
      }).toList();

      isLoading.value = false;

      // Log recap viewed
      AnalyticsService.instance.recapViewed(_weekKey());
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
    final months = ['Jan','Feb','Mar','Apr','May','Jun',
                    'Jul','Aug','Sep','Oct','Nov','Dec'];
    if (weekStart.month == weekEnd.month) {
      return '${months[weekStart.month - 1]} ${weekStart.day} — ${weekEnd.day}';
    }
    return '${months[weekStart.month - 1]} ${weekStart.day} — ${months[weekEnd.month - 1]} ${weekEnd.day}';
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
}
