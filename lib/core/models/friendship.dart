/// Accepted friendship between two users.
/// Created when a friend request is accepted.
class Friendship {
  const Friendship({
    required this.id,
    required this.userId1,
    required this.userId2,
    required this.createdAt,
  });

  /// ID format: "{userId1}_{userId2}" where userId1 < userId2 (lexicographically)
  final String id;
  final String userId1;
  final String userId2;
  final DateTime createdAt;

  /// Get the other user in this friendship.
  String otherUserId(String currentUserId) {
    return currentUserId == userId1 ? userId2 : userId1;
  }

  /// Check if this friendship involves a given user.
  bool involves(String uid) => uid == userId1 || uid == userId2;

  Map<String, dynamic> toFirestore() => {
        'id': id,
        'userId1': userId1,
        'userId2': userId2,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Friendship.fromFirestore(Map<String, dynamic> map) => Friendship(
        id: map['id'] as String,
        userId1: map['userId1'] as String,
        userId2: map['userId2'] as String,
        createdAt: DateTime.parse(map['createdAt'] as String),
      );

  factory Friendship.create(String uid1, String uid2) {
    // Sort lexicographically so the ID is deterministic
    final sorted = [uid1, uid2]..sort();
    return Friendship(
      id: '${sorted[0]}_${sorted[1]}',
      userId1: sorted[0],
      userId2: sorted[1],
      createdAt: DateTime.now(),
    );
  }
}
