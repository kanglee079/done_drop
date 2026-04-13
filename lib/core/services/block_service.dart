import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:done_drop/features/auth/presentation/controllers/auth_controller.dart';
import 'package:get/get.dart';

/// Service for blocking/unblocking users.
/// Stores blocked user IDs in a subcollection under the user's document.
class BlockService extends GetxService {
  BlockService();

  FirebaseFirestore get _db => FirebaseFirestore.instance;

  String? get _userId => Get.find<AuthController>().firebaseUser?.uid;

  CollectionReference<Map<String, dynamic>> get _blockCol {
    if (_userId == null) throw StateError('Not authenticated');
    return _db
        .collection('users')
        .doc(_userId)
        .collection('blockedUsers');
  }

  /// Check if a user is blocked.
  Future<bool> isBlocked(String targetUserId) async {
    if (_userId == null) return false;
    final doc = await _blockCol.doc(targetUserId).get();
    return doc.exists;
  }

  /// Stream of blocked user IDs for the current user.
  Stream<List<String>> watchBlockedUserIds() {
    if (_userId == null) return Stream.value([]);
    return _blockCol.snapshots().map(
      (snap) => snap.docs.map((d) => d.id).toList(),
    );
  }

  /// Block a user.
  Future<void> blockUser(String targetUserId) async {
    if (_userId == null) return;
    await _blockCol.doc(targetUserId).set({
      'blockedAt': FieldValue.serverTimestamp(),
    });
    // Remove any friend relationship
    await _removeFriendRelation(_userId!, targetUserId);
    // Remove orphaned feed deliveries (moment was shared with this friend before block)
    await _removeFeedDeliveries(_userId!, targetUserId);
  }

  /// Unblock a user.
  Future<void> unblockUser(String targetUserId) async {
    if (_userId == null) return;
    await _blockCol.doc(targetUserId).delete();
  }

  /// Remove bidirectional friend relationship between two users.
  Future<void> _removeFriendRelation(String uid1, String uid2) async {
    final batch = _db.batch();

    // Cancel pending friend requests in both directions
    final req1 = await _db
        .collection('friend_requests')
        .where('senderId', isEqualTo: uid1)
        .where('receiverId', isEqualTo: uid2)
        .limit(1)
        .get();
    for (final d in req1.docs) {
      batch.delete(d.reference);
    }

    final req2 = await _db
        .collection('friend_requests')
        .where('senderId', isEqualTo: uid2)
        .where('receiverId', isEqualTo: uid1)
        .limit(1)
        .get();
    for (final d in req2.docs) {
      batch.delete(d.reference);
    }

    // Remove friendship document (sorted ID format)
    final sorted = [uid1, uid2]..sort();
    final friendshipDoc = _db.collection('friendships').doc('${sorted[0]}_${sorted[1]}');
    batch.delete(friendshipDoc);

    await batch.commit();
  }

  /// Remove feed deliveries where this user was a recipient (blocks orphaned deliveries).
  Future<void> _removeFeedDeliveries(String currentUserId, String targetUserId) async {
    // Feed deliveries where currentUser is recipient and targetUser is owner
    final snap1 = await _db
        .collection('feed_deliveries')
        .where('recipientId', isEqualTo: currentUserId)
        .where('ownerId', isEqualTo: targetUserId)
        .get();
    final batch1 = _db.batch();
    for (final d in snap1.docs) {
      batch1.delete(d.reference);
    }
    await batch1.commit();

    // Feed deliveries where currentUser is owner and targetUser is recipient
    final snap2 = await _db
        .collection('feed_deliveries')
        .where('ownerId', isEqualTo: currentUserId)
        .where('recipientId', isEqualTo: targetUserId)
        .get();
    final batch2 = _db.batch();
    for (final d in snap2.docs) {
      batch2.delete(d.reference);
    }
    await batch2.commit();
  }
}