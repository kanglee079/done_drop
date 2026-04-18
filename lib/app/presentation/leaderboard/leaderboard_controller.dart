import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:done_drop/core/models/leaderboard_entry.dart';
import 'package:done_drop/core/models/user_profile.dart';
import 'package:done_drop/core/errors/result.dart';
import 'package:done_drop/firebase/repositories/friend_repository.dart';
import 'package:done_drop/firebase/repositories/activity_repository.dart';
import 'package:done_drop/features/auth/presentation/controllers/auth_controller.dart';
import 'package:done_drop/features/auth/repositories/user_profile_repository.dart';
import 'package:done_drop/l10n/l10n.dart';

/// Leaderboard controller — fetches friend activity rankings.
///
/// Period logic:
/// - today: activities completed today
/// - thisWeek: activities completed in the last 7 days
/// - thisMonth: last 30 days
/// - allTime: all completion logs (sorted by longestStreak)
class LeaderboardController extends GetxController {
  LeaderboardController(this._friendRepo, this._activityRepo);

  final FriendRepository _friendRepo;
  // ignore: unused_field
  final ActivityRepository _activityRepo;

  AuthController get _authCtrl => Get.find<AuthController>();
  UserProfileRepository get _profileRepo => Get.find<UserProfileRepository>();
  String? get _userId => _authCtrl.firebaseUser?.uid;

  final RxList<LeaderboardEntry> entries = <LeaderboardEntry>[].obs;
  final Rx<LeaderboardPeriod> selectedPeriod = LeaderboardPeriod.thisWeek.obs;
  final RxBool isLoading = true.obs;
  final RxBool isStale = false.obs;

  @override
  void onInit() {
    super.onInit();
    ever(selectedPeriod, (_) => _loadLeaderboard());
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    final uid = _userId;
    if (uid == null) return;

    isLoading.value = true;
    isStale.value = true;

    try {
      final friends = await _friendRepo.getFriends(uid);
      if (friends.isEmpty) {
        entries.clear();
        isLoading.value = false;
        isStale.value = false;
        return;
      }

      final friendIds = friends.map((f) => f.otherUserId(uid)).toList();
      final allIds = [uid, ...friendIds];

      // Batch-fetch profiles for all participants
      final profiles = <String, UserProfile>{};
      for (final id in allIds) {
        final result = await _profileRepo.getUserProfile(id);
        result.fold(
          onSuccess: (data) => profiles[id] = data,
          onFailure: (_) {},
        );
      }

      // Gather data per period
      final periodStart = _periodStart(selectedPeriod.value);
      final stats = await _fetchStats(allIds, periodStart);

      // Build sorted list
      final ranked = <LeaderboardEntry>[];
      for (final id in allIds) {
        final stat = stats[id] ?? {'count': 0, 'streak': 0, 'longest': 0};
        final profile = profiles[id];
        ranked.add(LeaderboardEntry(
          userId: id,
          displayName: profile?.displayName ?? currentL10n.memberFallbackName,
          avatarUrl: profile?.avatarUrl,
          completedCount: stat['count'] as int,
          currentStreak: stat['streak'] as int,
          longestStreak: stat['longest'] as int,
          rank: 0,
          period: selectedPeriod.value,
        ));
      }

      // Sort by completed count desc, then by streak desc
      ranked.sort((a, b) {
        final cmp = b.completedCount.compareTo(a.completedCount);
        if (cmp != 0) return cmp;
        return b.currentStreak.compareTo(a.currentStreak);
      });

      // Assign ranks
      for (var i = 0; i < ranked.length; i++) {
        ranked[i] = LeaderboardEntry(
          userId: ranked[i].userId,
          displayName: ranked[i].displayName,
          avatarUrl: ranked[i].avatarUrl,
          completedCount: ranked[i].completedCount,
          currentStreak: ranked[i].currentStreak,
          longestStreak: ranked[i].longestStreak,
          rank: i + 1,
          period: ranked[i].period,
        );
      }

      entries.value = ranked;
    } catch (_) {
      // Keep stale data if available
    } finally {
      isLoading.value = false;
      isStale.value = false;
    }
  }

  DateTime _periodStart(LeaderboardPeriod period) {
    final now = DateTime.now();
    return switch (period) {
      LeaderboardPeriod.today => DateTime(now.year, now.month, now.day),
      LeaderboardPeriod.thisWeek => now.subtract(const Duration(days: 7)),
      LeaderboardPeriod.thisMonth => now.subtract(const Duration(days: 30)),
      LeaderboardPeriod.allTime => DateTime(2020),
    };
  }

  Future<Map<String, Map<String, int>>> _fetchStats(
      List<String> userIds, DateTime since) async {
    final db = FirebaseFirestore.instance;
    final result = <String, Map<String, int>>{};

    // Fetch all activities for each user (to get streak info)
    final actsSnap = await db.collection('activities')
        .where('ownerId', whereIn: userIds)
        .where('isArchived', isEqualTo: false)
        .get();

    for (final doc in actsSnap.docs) {
      final ownerId = doc['ownerId'] as String;
      result[ownerId] ??= {'count': 0, 'streak': 0, 'longest': 0};
      result[ownerId]!['streak'] = doc['currentStreak'] as int? ?? 0;
      result[ownerId]!['longest'] = doc['longestStreak'] as int? ?? 0;
    }

    // Fetch completion logs in period for count
    final logsSnap = await db.collection('completion_logs')
        .where('ownerId', whereIn: userIds)
        .where('completedAt', isGreaterThan: since.toIso8601String())
        .get();

    for (final doc in logsSnap.docs) {
      final ownerId = doc['ownerId'] as String;
      result[ownerId] ??= {'count': 0, 'streak': 0, 'longest': 0};
      result[ownerId]!['count'] = (result[ownerId]!['count'] ?? 0) + 1;
    }

    return result;
  }

  LeaderboardEntry? get currentUserEntry {
    final uid = _userId;
    if (uid == null) return null;
    try {
      return entries.firstWhere((e) => e.userId == uid);
    } catch (_) {
      return null;
    }
  }

  int? get currentUserRank => currentUserEntry?.rank;

  void setPeriod(LeaderboardPeriod period) {
    selectedPeriod.value = period;
  }
}
