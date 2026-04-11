import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_constants.dart';
import '../../core/models/models.dart';

/// DoneDrop Firestore Repository — Moment operations
class MomentRepository {
  MomentRepository(this._db);
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection(AppConstants.colMoments);

  CollectionReference<Map<String, dynamic>> get _reactionCol =>
      _db.collection(AppConstants.colReactions);

  CollectionReference<Map<String, dynamic>> get _taskCol =>
      _db.collection(AppConstants.colTaskTemplates);

  // ── Moments ────────────────────────────────────────────────────────────
  Future<Moment?> getMoment(String momentId) async {
    final doc = await _col.doc(momentId).get();
    if (!doc.exists) return null;
    return Moment.fromFirestore(doc.data()!);
  }

  Future<void> createMoment(Moment moment) async {
    await _col.doc(moment.id).set(moment.toFirestore());
  }

  Future<void> updateMoment(Moment moment) async {
    await _col.doc(moment.id).update(moment.toFirestore());
  }

  Future<void> deleteMoment(String momentId) async {
    await _col.doc(momentId).update({
      'isDeleted': true,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  /// Personal wall: all personal-only moments by user
  Stream<List<Moment>> watchPersonalMoments(String userId, {int limit = 50}) {
    return _col
        .where('ownerId', isEqualTo: userId)
        .where('visibility', isEqualTo: 'personal_only')
        .where('isDeleted', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Moment.fromFirestore(d.data())).toList());
  }

  /// Circle feed: all circle moments visible to user
  Stream<List<Moment>> watchCircleMoments(
    String circleId, {
    int limit = 50,
  }) {
    return _col
        .where('circleId', isEqualTo: circleId)
        .where('visibility', isEqualTo: 'circle')
        .where('isDeleted', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Moment.fromFirestore(d.data())).toList());
  }

  // ── Reactions ─────────────────────────────────────────────────────────
  Future<void> addReaction(Reaction reaction) async {
    await _reactionCol.doc(reaction.id).set(reaction.toFirestore());
  }

  Future<void> removeReaction(String momentId, String userId) async {
    final snap = await _reactionCol
        .where('momentId', isEqualTo: momentId)
        .where('userId', isEqualTo: userId)
        .get();
    for (final doc in snap.docs) {
      await doc.reference.delete();
    }
  }

  Stream<List<Reaction>> watchReactions(String momentId) {
    return _reactionCol
        .where('momentId', isEqualTo: momentId)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Reaction.fromFirestore(d.data())).toList());
  }

  // ── Task Templates ────────────────────────────────────────────────────
  Future<void> createTaskTemplate(TaskTemplate task) async {
    await _taskCol.doc(task.id).set(task.toFirestore());
  }

  Future<void> updateTaskTemplate(TaskTemplate task) async {
    await _taskCol.doc(task.id).update(task.toFirestore());
  }

  Future<void> archiveTaskTemplate(String taskId) async {
    await _taskCol.doc(taskId).update({'isArchived': true});
  }

  Stream<List<TaskTemplate>> watchTaskTemplates(String userId) {
    return _taskCol
        .where('ownerId', isEqualTo: userId)
        .where('isArchived', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => TaskTemplate.fromFirestore(d.data())).toList());
  }
}
