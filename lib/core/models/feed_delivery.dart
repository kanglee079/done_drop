/// Feed delivery — denormalized entry in a recipient's private feed.
/// Created when a moment is shared with all_friends or selected_friends.
class FeedDelivery {
  const FeedDelivery({
    required this.id,
    required this.recipientId,
    required this.momentId,
    required this.ownerId,
    required this.visibility,
    required this.createdAt,
    this.isRead = false,
  });

  final String id;
  final String recipientId;
  final String momentId;
  final String ownerId;
  final String visibility; // all_friends | selected_friends
  final DateTime createdAt;
  final bool isRead;

  Map<String, dynamic> toFirestore() => {
        'id': id,
        'recipientId': recipientId,
        'momentId': momentId,
        'ownerId': ownerId,
        'visibility': visibility,
        'createdAt': createdAt.toIso8601String(),
        'isRead': isRead,
      };

  factory FeedDelivery.fromFirestore(Map<String, dynamic> map) => FeedDelivery(
        id: map['id'] as String,
        recipientId: map['recipientId'] as String,
        momentId: map['momentId'] as String,
        ownerId: map['ownerId'] as String,
        visibility: map['visibility'] as String,
        createdAt: DateTime.parse(map['createdAt'] as String),
        isRead: map['isRead'] as bool? ?? false,
      );
}
