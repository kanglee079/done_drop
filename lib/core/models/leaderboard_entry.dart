/// A single entry in the friend leaderboard.
class LeaderboardEntry {
  const LeaderboardEntry({
    required this.userId,
    required this.displayName,
    this.avatarUrl,
    required this.completedCount,
    required this.currentStreak,
    required this.longestStreak,
    required this.rank,
    required this.period,
  });

  final String userId;
  final String displayName;
  final String? avatarUrl;
  final int completedCount;
  final int currentStreak;
  final int longestStreak;
  final int rank;
  final LeaderboardPeriod period;

  bool get isTop3 => rank <= 3;
  bool get isCurrentUser => false; // set by controller
}

enum LeaderboardPeriod { today, thisWeek, thisMonth, allTime }
