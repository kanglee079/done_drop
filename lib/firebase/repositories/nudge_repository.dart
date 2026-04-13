import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:done_drop/core/models/nudge.dart';
import 'package:done_drop/core/constants/app_constants.dart';

class NudgeRepository {
  final FirebaseFirestore _firestore;

  NudgeRepository({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _nudges =>
      _firestore.collection(AppConstants.colUsers); // We'll store under users subcollection

  Future<void> sendNudge(Nudge nudge) async {
    final doc = _nudges.doc(nudge.receiverId).collection('nudges').doc(nudge.id);
    await doc.set(nudge.toFirestore());
  }

  Stream<List<Nudge>> watchIncomingNudges(String userId) {
    return _nudges
        .doc(userId)
        .collection('nudges')
        .where('status', isEqualTo: 'unread')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Nudge.fromFirestore(doc.data(), doc.id)).toList());
  }

  Future<void> markNudgeAsRead(String userId, String nudgeId) async {
    await _nudges.doc(userId).collection('nudges').doc(nudgeId).update({'status': 'read'});
  }
}
