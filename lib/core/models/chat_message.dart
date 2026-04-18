class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.threadId,
    required this.senderId,
    required this.text,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String threadId;
  final String senderId;
  final String text;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toFirestore() => {
        'id': id,
        'threadId': threadId,
        'senderId': senderId,
        'text': text,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory ChatMessage.fromFirestore(Map<String, dynamic> map) => ChatMessage(
        id: map['id'] as String? ?? '',
        threadId: map['threadId'] as String? ?? '',
        senderId: map['senderId'] as String? ?? '',
        text: map['text'] as String? ?? '',
        createdAt: _parseDateTime(map['createdAt']),
        updatedAt: _parseDateTime(map['updatedAt']),
      );

  static DateTime _parseDateTime(dynamic value) {
    if (value is String && value.isNotEmpty) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }
}
