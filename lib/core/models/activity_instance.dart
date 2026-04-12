import 'package:cloud_firestore/cloud_firestore.dart';

/// Instance of an Activity for a specific date.
class ActivityInstance {
  const ActivityInstance({
    required this.id,
    required this.activityId,
    required this.ownerId,
    required this.date,
    required this.status,
    this.momentId,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String activityId;
  final String ownerId;
  final DateTime date;
  /// pending | completed | missed
  final String status;
  /// Linked moment if completed with proof
  final String? momentId;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isPending => status == 'pending';
  bool get isCompleted => status == 'completed';
  bool get isMissed => status == 'missed';

  /// Whether this instance is overdue (past end of day and still pending)
  bool get isOverdue {
    if (isCompleted || isMissed) return false;
    final now = DateTime.now();
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    return now.isAfter(endOfDay);
  }

  /// Whether this instance is for today
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  ActivityInstance copyWith({
    String? id,
    String? activityId,
    String? ownerId,
    DateTime? date,
    String? status,
    String? momentId,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      ActivityInstance(
        id: id ?? this.id,
        activityId: activityId ?? this.activityId,
        ownerId: ownerId ?? this.ownerId,
        date: date ?? this.date,
        status: status ?? this.status,
        momentId: momentId ?? this.momentId,
        completedAt: completedAt ?? this.completedAt,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  Map<String, dynamic> toFirestore() => {
        'id': id,
        'activityId': activityId,
        'ownerId': ownerId,
        'date': _dateToString(date),
        'status': status,
        'momentId': momentId,
        'completedAt': completedAt?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory ActivityInstance.fromFirestore(Map<String, dynamic> map) =>
      ActivityInstance(
        id: map['id'] as String,
        activityId: map['activityId'] as String,
        ownerId: map['ownerId'] as String,
        date: _parseDate(map['date']),
        status: map['status'] as String,
        momentId: map['momentId'] as String?,
        completedAt: map['completedAt'] != null
            ? DateTime.parse(map['completedAt'] as String)
            : null,
        createdAt: DateTime.parse(map['createdAt'] as String),
        updatedAt: DateTime.parse(map['updatedAt'] as String),
      );

  static String _dateToString(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static DateTime _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.parse(value);
    return DateTime.now();
  }
}
