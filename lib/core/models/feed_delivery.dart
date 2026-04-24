/// Feed delivery — denormalized entry in a recipient's private feed.
/// Created when a moment is shared with all_friends or selected_friends.
class FeedDelivery {
  const FeedDelivery({
    required this.id,
    required this.recipientId,
    required this.momentId,
    required this.ownerId,
    required this.ownerDisplayName,
    this.ownerAvatarUrl,
    required this.visibility,
    required this.caption,
    this.category,
    this.activityTitle,
    required this.originalUrl,
    required this.thumbnailUrl,
    required this.completedAt,
    required this.createdAt,
    this.isRead = false,
  });

  final String id;
  final String recipientId;
  final String momentId;
  final String ownerId;
  final String ownerDisplayName;
  final String? ownerAvatarUrl;
  final String visibility; // all_friends | selected_friends
  final String caption;
  final String? category;
  final String? activityTitle;
  final String originalUrl;
  final String thumbnailUrl;
  final DateTime completedAt;
  final DateTime createdAt;
  final bool isRead;

  String get previewUrl => thumbnailUrl.isNotEmpty ? thumbnailUrl : originalUrl;

  Map<String, dynamic> toFirestore() => {
        'id': id,
        'recipientId': recipientId,
        'momentId': momentId,
        'ownerId': ownerId,
        'ownerDisplayName': ownerDisplayName,
        'ownerAvatarUrl': ownerAvatarUrl,
        'visibility': visibility,
        'caption': caption,
        'category': category,
        'activityTitle': activityTitle,
        'originalUrl': originalUrl,
        'thumbnailUrl': thumbnailUrl,
        'completedAt': completedAt.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'isRead': isRead,
      };

  factory FeedDelivery.fromFirestore(Map<String, dynamic> map) => FeedDelivery(
        id: map['id'] as String,
        recipientId: map['recipientId'] as String,
        momentId: map['momentId'] as String,
        ownerId: map['ownerId'] as String,
        ownerDisplayName: map['ownerDisplayName'] as String? ?? 'Friend',
        ownerAvatarUrl: map['ownerAvatarUrl'] as String?,
        visibility: map['visibility'] as String,
        caption: map['caption'] as String? ?? '',
        category: map['category'] as String?,
        activityTitle: map['activityTitle'] as String?,
        originalUrl: map['originalUrl'] as String? ?? '',
        thumbnailUrl: map['thumbnailUrl'] as String? ?? '',
        completedAt: map['completedAt'] != null
            ? DateTime.parse(map['completedAt'] as String)
            : DateTime.parse(map['createdAt'] as String),
        createdAt: DateTime.parse(map['createdAt'] as String),
        isRead: map['isRead'] as bool? ?? false,
      );

  /// Parse from a raw Firestore document map, also accepting keys from
  /// the denormalized feed delivery structure.
  factory FeedDelivery.fromMap(Map<String, dynamic> map) =>
      FeedDelivery.fromFirestore(map);
}
