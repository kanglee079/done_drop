/// Weekly recap model
class WeeklyRecap {
  const WeeklyRecap({
    required this.id,
    required this.ownerId,
    required this.weekKey,
    required this.totalMoments,
    required this.streakDays,
    this.topCategory,
    this.highlightMomentIds = const [],
    required this.createdAt,
  });

  final String id;
  final String ownerId;
  final String weekKey; // "2024-W42"
  final int totalMoments;
  final int streakDays;
  final String? topCategory;
  final List<String> highlightMomentIds;
  final DateTime createdAt;

  Map<String, dynamic> toFirestore() => {
        'id': id,
        'ownerId': ownerId,
        'weekKey': weekKey,
        'totalMoments': totalMoments,
        'streakDays': streakDays,
        'topCategory': topCategory,
        'highlightMomentIds': highlightMomentIds,
        'createdAt': createdAt.toIso8601String(),
      };

  factory WeeklyRecap.fromFirestore(Map<String, dynamic> map) => WeeklyRecap(
        id: map['id'] as String,
        ownerId: map['ownerId'] as String,
        weekKey: map['weekKey'] as String,
        totalMoments: map['totalMoments'] as int,
        streakDays: map['streakDays'] as int,
        topCategory: map['topCategory'] as String?,
        highlightMomentIds:
            (map['highlightMomentIds'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
        createdAt: DateTime.parse(map['createdAt'] as String),
      );
}

/// Report model
class Report {
  const Report({
    required this.id,
    required this.reporterId,
    required this.targetType,
    required this.targetId,
    required this.reason,
    required this.createdAt,
    this.status = 'pending',
  });

  final String id;
  final String reporterId;
  /// Target type: moment | user (circle deprecated in V1)
  final String targetType;
  final String targetId;
  final String reason;
  final DateTime createdAt;
  final String status;

  Map<String, dynamic> toFirestore() => {
        'id': id,
        'reporterId': reporterId,
        'targetType': targetType,
        'targetId': targetId,
        'reason': reason,
        'createdAt': createdAt.toIso8601String(),
        'status': status,
      };

  factory Report.fromFirestore(Map<String, dynamic> map) => Report(
        id: map['id'] as String,
        reporterId: map['reporterId'] as String,
        targetType: map['targetType'] as String,
        targetId: map['targetId'] as String,
        reason: map['reason'] as String,
        createdAt: DateTime.parse(map['createdAt'] as String),
        status: map['status'] as String? ?? 'pending',
      );
}
