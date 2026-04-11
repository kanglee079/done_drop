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
  }

  /// Unblock a user.
  Future<void> unblockUser(String targetUserId) async {
    if (_userId == null) return;
    await _blockCol.doc(targetUserId).delete();
  }

  /// Remove bidirectional friend relationship between two users.
  Future<void> _removeFriendRelation(String uid1, String uid2) async {
    final batch = _db.batch();

    // Find and delete friend request from uid1 -> uid2
    final req1 = await _db
        .collection('friend_requests')
        .where('senderId', isEqualTo: uid1)
        .where('receiverId', isEqualTo: uid2)
        .limit(1)
        .get();
    for (final d in req1.docs) batch.delete(d.reference);

    // Find and delete friend request from uid2 -> uid1
    final req2 = await _db
        .collection('friend_requests')
        .where('senderId', isEqualTo: uid2)
        .where('receiverId', isEqualTo: uid1)
        .limit(1)
        .get();
    for (final d in req2.docs) batch.delete(d.reference);

    // Remove from friends collection (both directions)
    final friendDoc1 = _db.collection('friends').doc('${uid1}_$uid2');
    final friendDoc2 = _db.collection('friends').doc('${uid2}_$uid1');
    batch.delete(friendDoc1);
    batch.delete(friendDoc2);

    await batch.commit();
  }
}
