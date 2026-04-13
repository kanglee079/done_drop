import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a streak freeze used to recover a broken streak.
class StreakFreeze {
  const StreakFreeze({
    required this.id,
    required this.userId,
    required this.activityId,
    required this.frozenDate,
    required this.usedAt,
  });

  final String id;
  final String userId;
  final String activityId;
  final DateTime frozenDate;
  final DateTime usedAt;

  factory StreakFreeze.fromJson(Map<String, dynamic> json, String id) {
    return StreakFreeze(
      id: id,
      userId: json['userId'] as String? ?? '',
      activityId: json['activityId'] as String? ?? '',
      frozenDate: (json['frozenDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      usedAt: (json['usedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'activityId': activityId,
      'frozenDate': Timestamp.fromDate(frozenDate),
      'usedAt': Timestamp.fromDate(usedAt),
    };
  }
}

/// Holds the streak recovery state for a user.
class StreakRecoveryState {
  const StreakRecoveryState({
    required this.userId,
    this.availableFreezes = 0,
    this.totalFreezesUsed = 0,
  });

  final String userId;
  final int availableFreezes;
  final int totalFreezesUsed;

  bool get canRecover => availableFreezes > 0;

  factory StreakRecoveryState.fromJson(Map<String, dynamic> json, String userId) {
    return StreakRecoveryState(
      userId: userId,
      availableFreezes: json['availableFreezes'] as int? ?? 0,
      totalFreezesUsed: json['totalFreezesUsed'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'availableFreezes': availableFreezes,
      'totalFreezesUsed': totalFreezesUsed,
    };
  }
}
