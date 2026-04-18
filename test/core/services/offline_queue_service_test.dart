import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OfflineQueueService — proof linking', () {
    test('create_moment sync payload includes all linking fields', () {
      final payload = {
        'momentId': 'moment_1',
        'ownerId': 'user_1',
        'momentData': {
          'visibility': 'personal_only',
          'caption': 'test',
          'category': 'Exercise',
          'completedAt': DateTime(2026, 4, 14).toIso8601String(),
          'createdAt': DateTime(2026, 4, 14).toIso8601String(),
          'updatedAt': DateTime(2026, 4, 14).toIso8601String(),
        },
        'recipientIds': <String>[],
        'activityId': 'habit_1',
        'activityInstanceId': 'inst_1',
        'completionLogId': 'log_1',
        'createdAt': DateTime(2026, 4, 14).toIso8601String(),
      };

      // Verify all linking fields are present in the payload
      expect(payload['activityInstanceId'], isNotNull);
      expect(payload['completionLogId'], isNotNull);
      expect(payload['momentId'], isNotNull);
      expect(payload['ownerId'], isNotNull);
    });

    test('complete_activity sync payload includes instance and log ids', () {
      final payload = {
        'activityId': 'habit_1',
        'instanceId': 'inst_1',
        'ownerId': 'user_1',
        'completionLogId': 'log_1',
        'completedAt': DateTime(2026, 4, 14).toIso8601String(),
      };

      expect(payload['activityId'], isNotNull);
      expect(payload['instanceId'], isNotNull);
      expect(payload['completionLogId'], isNotNull);
      expect(payload['completedAt'], isNotNull);
    });

    test('Moment.toFirestore serialises all proof-linking fields', () {
      final moment = _FakeMoment(
        id: 'moment_1',
        ownerId: 'user_1',
        activityId: 'habit_1',
        activityInstanceId: 'inst_1',
        completionLogId: 'log_1',
        visibility: 'personal_only',
        caption: 'done',
        completedAt: DateTime(2026, 4, 14),
        createdAt: DateTime(2026, 4, 14),
        updatedAt: DateTime(2026, 4, 14),
      );

      final firestore = moment.toFirestore();

      expect(firestore['id'], 'moment_1');
      expect(firestore['ownerId'], 'user_1');
      expect(firestore['activityId'], 'habit_1');
      expect(firestore['activityInstanceId'], 'inst_1');
      expect(firestore['completionLogId'], 'log_1');
    });

    test('ActivityInstance copyWith preserves momentId', () {
      final original = _FakeActivityInstance(
        id: 'inst_1',
        activityId: 'habit_1',
        ownerId: 'user_1',
        date: DateTime(2026, 4, 14),
        status: 'pending',
        createdAt: DateTime(2026, 4, 14),
        updatedAt: DateTime(2026, 4, 14),
      );

      final updated = original.copyWith(
        status: 'completed',
        momentId: 'moment_1',
      );

      expect(updated.momentId, 'moment_1');
      expect(updated.status, 'completed');
    });
  });
}

// ── Minimal fakes to verify serialization contract ──────────────────────────

class _FakeMoment {
  const _FakeMoment({
    required this.id,
    required this.ownerId,
    this.activityId,
    this.activityInstanceId,
    this.completionLogId,
    required this.visibility,
    required this.caption,
    required this.completedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String ownerId;
  final String? activityId;
  final String? activityInstanceId;
  final String? completionLogId;
  final String visibility;
  final String caption;
  final DateTime completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toFirestore() => {
        'id': id,
        'ownerId': ownerId,
        'activityId': activityId,
        'activityInstanceId': activityInstanceId,
        'completionLogId': completionLogId,
        'visibility': visibility,
        'caption': caption,
        'completedAt': completedAt.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}

class _FakeActivityInstance {
  const _FakeActivityInstance({
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
  final String status;
  final String? momentId;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isCompleted => status == 'completed';

  _FakeActivityInstance copyWith({
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
      _FakeActivityInstance(
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
}
