import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_constants.dart';
import '../../core/models/models.dart';

/// DoneDrop Firestore Repository — Circle operations
class CircleRepository {
  CircleRepository(this._db);
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection(AppConstants.colCircles);

  CollectionReference<Map<String, dynamic>> get _membershipCol =>
      _db.collection(AppConstants.colCircleMemberships);

  CollectionReference<Map<String, dynamic>> get _inviteCol =>
      _db.collection(AppConstants.colInvites);

  Future<Circle?> getCircle(String circleId) async {
    final doc = await _col.doc(circleId).get();
    if (!doc.exists) return null;
    return Circle.fromFirestore(doc.data()!);
  }

  Future<void> createCircle(Circle circle) async {
    await _col.doc(circle.id).set(circle.toFirestore());
  }

  Future<void> updateCircle(Circle circle) async {
    await _col.doc(circle.id).update(circle.toFirestore());
  }

  Stream<List<Circle>> watchUserCircles(String userId) {
    return _membershipCol
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'active')
        .snapshots()
        .asyncMap((snap) async {
      final circleIds = snap.docs.map((d) => d['circleId'] as String).toList();
      if (circleIds.isEmpty) return <Circle>[];
      final futures = circleIds.map((id) => getCircle(id));
      final circles = await Future.wait(futures);
      return circles.whereType<Circle>().where((c) => !c.archived).toList();
    });
  }

  Future<List<CircleMembership>> getMemberships(String circleId) async {
    final snap = await _membershipCol
        .where('circleId', isEqualTo: circleId)
        .where('status', isEqualTo: 'active')
        .get();
    return snap.docs
        .map((d) => CircleMembership.fromFirestore(d.data()))
        .toList();
  }

  Future<void> addMembership(CircleMembership membership) async {
    await _membershipCol.doc(membership.id).set(membership.toFirestore());
  }

  Future<void> removeMembership(String membershipId) async {
    await _membershipCol.doc(membershipId).update({'status': 'removed'});
  }

  Future<void> createInvite(Invite invite) async {
    await _inviteCol.doc(invite.id).set(invite.toFirestore());
  }

  Future<Invite?> getInviteByCode(String code) async {
    final snap = await _inviteCol
        .where('inviteCode', isEqualTo: code)
        .where('status', isEqualTo: 'active')
        .get();
    if (snap.docs.isEmpty) return null;
    return Invite.fromFirestore(snap.docs.first.data());
  }
}
