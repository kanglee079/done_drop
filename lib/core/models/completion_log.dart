/// Completion log — a record of finishing an activity instance.
/// Used for streak calculation and proof linkage.
class CompletionLog {
  const CompletionLog({
    required this.id,
    required this.activityId,
    required this.activityInstanceId,
    required this.ownerId,
    required this.completedAt,
    this.momentId,
    this.note,
    required this.createdAt,
  });

  final String id;
  final String activityId;
  final String activityInstanceId;
  final String ownerId;
  final DateTime completedAt;
  final String? momentId;
  final String? note;
  final DateTime createdAt;

  Map<String, dynamic> toFirestore() => {
        'id': id,
        'activityId': activityId,
        'activityInstanceId': activityInstanceId,
        'ownerId': ownerId,
        'completedAt': completedAt.toIso8601String(),
        'momentId': momentId,
        'note': note,
        'createdAt': createdAt.toIso8601String(),
      };

  factory CompletionLog.fromFirestore(Map<String, dynamic> map) =>
      CompletionLog(
        id: map['id'] as String,
        activityId: map['activityId'] as String,
        activityInstanceId: map['activityInstanceId'] as String,
        ownerId: map['ownerId'] as String,
        completedAt: DateTime.parse(map['completedAt'] as String),
        momentId: map['momentId'] as String?,
        note: map['note'] as String?,
        createdAt: DateTime.parse(map['createdAt'] as String),
      );
}
