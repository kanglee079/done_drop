/// Friend Request model — sent from one user to another
class FriendRequest {
  const FriendRequest({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.status,
    required this.createdAt,
    this.senderDisplayName,
    this.senderAvatarUrl,
    this.message,
  });

  final String id;
  final String senderId;
  final String receiverId;
  /// Status: pending | accepted | declined | cancelled
  final String status;
  final DateTime createdAt;
  final String? senderDisplayName;
  final String? senderAvatarUrl;
  final String? message;

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isDeclined => status == 'declined';
  bool get isCancelled => status == 'cancelled';

  FriendRequest copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? status,
    DateTime? createdAt,
    String? senderDisplayName,
    String? senderAvatarUrl,
    String? message,
  }) =>
      FriendRequest(
        id: id ?? this.id,
        senderId: senderId ?? this.senderId,
        receiverId: receiverId ?? this.receiverId,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
        senderDisplayName: senderDisplayName ?? this.senderDisplayName,
        senderAvatarUrl: senderAvatarUrl ?? this.senderAvatarUrl,
        message: message ?? this.message,
      );

  Map<String, dynamic> toFirestore() => {
        'id': id,
        'senderId': senderId,
        'receiverId': receiverId,
        'status': status,
        'createdAt': createdAt.toIso8601String(),
        if (senderDisplayName != null) 'senderDisplayName': senderDisplayName,
        if (senderAvatarUrl != null) 'senderAvatarUrl': senderAvatarUrl,
        if (message != null) 'message': message,
      };

  factory FriendRequest.fromFirestore(Map<String, dynamic> map) => FriendRequest(
        id: map['id'] as String,
        senderId: map['senderId'] as String,
        receiverId: map['receiverId'] as String,
        status: map['status'] as String,
        createdAt: DateTime.parse(map['createdAt'] as String),
        senderDisplayName: map['senderDisplayName'] as String?,
        senderAvatarUrl: map['senderAvatarUrl'] as String?,
        message: map['message'] as String?,
      );
}
