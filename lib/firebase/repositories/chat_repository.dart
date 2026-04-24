import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:done_drop/core/models/chat_message.dart';
import 'package:done_drop/core/models/friendship.dart';

class ChatRepository {
  ChatRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _chatCol =>
      _db.collection('chats');

  static String threadIdForUsers(String userId1, String userId2) =>
      Friendship.create(userId1, userId2).id;

  Stream<List<ChatMessage>> watchMessages(String threadId, {int limit = 80}) {
    return _chatCol
        .doc(threadId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots(includeMetadataChanges: true)
        .map((snap) {
          final items = snap.docs
              .map((doc) => ChatMessage.fromFirestore(doc.data()))
              .toList(growable: false);
          return items.reversed.toList(growable: false);
        });
  }

  Future<void> ensureThread({
    required String threadId,
    required List<String> participantIds,
  }) async {
    final sortedParticipants = [...participantIds]..sort();
    final now = DateTime.now();
    await _chatCol.doc(threadId).set({
      'id': threadId,
      'participantIds': sortedParticipants,
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
    }, SetOptions(merge: true));
  }

  Future<void> sendTextMessage({
    required String threadId,
    required String senderId,
    required List<String> participantIds,
    required String text,
  }) async {
    final trimmedText = text.trim();
    if (trimmedText.isEmpty) return;

    final sortedParticipants = [...participantIds]..sort();
    final now = DateTime.now();
    final threadRef = _chatCol.doc(threadId);
    await ensureThread(threadId: threadId, participantIds: sortedParticipants);

    await threadRef.set({
      'id': threadId,
      'participantIds': sortedParticipants,
      'updatedAt': now.toIso8601String(),
      'lastMessageText': trimmedText,
      'lastMessageAt': now.toIso8601String(),
      'lastSenderId': senderId,
    }, SetOptions(merge: true));

    final messageRef = threadRef.collection('messages').doc();
    final message = ChatMessage(
      id: messageRef.id,
      threadId: threadId,
      senderId: senderId,
      text: trimmedText,
      createdAt: now,
      updatedAt: now,
    );

    await messageRef.set(message.toFirestore());
  }
}
