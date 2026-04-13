import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a lightweight interaction sent to a buddy
class Nudge {
  const Nudge({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.nudgeType,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String senderId;
  final String receiverId;
  final String nudgeType; // e.g. "fire", "eyes", "wakeup"
  final String status; // "unread", "read", "ignored"
  final DateTime createdAt;

  Map<String, dynamic> toFirestore() => {
        'id': id,
        'senderId': senderId,
        'receiverId': receiverId,
        'nudgeType': nudgeType,
        'status': status,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  factory Nudge.fromFirestore(Map<String, dynamic> map, String id) => Nudge(
        id: id,
        senderId: map['senderId'] as String? ?? '',
        receiverId: map['receiverId'] as String? ?? '',
        nudgeType: map['nudgeType'] as String? ?? 'fire',
        status: map['status'] as String? ?? 'unread',
        createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
}
