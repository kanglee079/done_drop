import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:done_drop/core/constants/app_constants.dart';
import 'package:done_drop/core/models/models.dart';
import 'package:done_drop/core/models/feed_delivery.dart';
import 'package:done_drop/core/services/feed_delivery_planner.dart';

/// DoneDrop Firestore Repository — Moment operations
class MomentRepository {
  MomentRepository(this._db);
  final FirebaseFirestore _db;
  final FeedDeliveryPlanner _deliveryPlanner = const FeedDeliveryPlanner();

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection(AppConstants.colMoments);

  CollectionReference<Map<String, dynamic>> get _reactionCol =>
      _db.collection(AppConstants.colReactions);

  CollectionReference<Map<String, dynamic>> get _taskCol =>
      _db.collection(AppConstants.colTaskTemplates);

  CollectionReference<Map<String, dynamic>> get _feedDeliveryCol =>
      _db.collection(AppConstants.colFeedDeliveries);

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

  /// Delete Storage files for a moment (original + thumbnail).
  Future<void> deleteMomentStorage(String ownerId, String momentId) async {
    try {
      await FirebaseStorage.instance
          .ref()
          .child('moments/$ownerId/$momentId/original.jpg')
          .delete();
    } catch (_) {}
    try {
      await FirebaseStorage.instance
          .ref()
          .child('moments/$ownerId/$momentId/thumb.jpg')
          .delete();
    } catch (_) {}
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
        .map(
          (snap) =>
              snap.docs.map((d) => Moment.fromFirestore(d.data())).toList(),
        );
  }

  // ── Private Friend Feed ──────────────────────────────────────────────

  /// Create feed delivery entries for each recipient of a moment.
  /// Called after a moment is saved with visibility all_friends or selected_friends.
  Future<void> createFeedDeliveries({
    required String momentId,
    required String ownerId,
    required String visibility,
    required List<String> recipientIds,
  }) async {
    final deliveries = _deliveryPlanner.buildDeliveries(
      momentId: momentId,
      ownerId: ownerId,
      visibility: visibility,
      createdAt: DateTime.now(),
      recipientIds: recipientIds,
    );
    if (deliveries.isEmpty) return;

    final batch = _db.batch();

    for (final delivery in deliveries) {
      batch.set(_feedDeliveryCol.doc(delivery.id), delivery.toFirestore());
    }

    await batch.commit();
  }

  /// Watch feed deliveries for a user (private friend feed).
  Stream<List<FeedDelivery>> watchFeedDeliveries(
    String userId, {
    int limit = 50,
  }) {
    return _feedDeliveryCol
        .where('recipientId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => FeedDelivery.fromFirestore(d.data()))
              .toList(),
        );
  }

  /// Mark a feed delivery as read.
  Future<void> markDeliveryRead(String deliveryId) async {
    await _feedDeliveryCol.doc(deliveryId).update({'isRead': true});
  }

  /// Get unread feed delivery count for a user.
  Stream<int> watchUnreadFeedCount(String userId) {
    return _feedDeliveryCol
        .where('recipientId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  /// Fetch moments for feed deliveries.
  Future<List<Moment>> getMomentsForFeed(List<String> momentIds) async {
    if (momentIds.isEmpty) return [];
    final List<Moment> moments = [];
    for (final id in momentIds) {
      final m = await getMoment(id);
      if (m != null && !m.isDeleted) moments.add(m);
    }
    return moments;
  }

  /// Delete feed deliveries when a moment is deleted.
  Future<void> deleteFeedDeliveriesForMoment(String momentId) async {
    final snap = await _feedDeliveryCol
        .where('momentId', isEqualTo: momentId)
        .get();
    final batch = _db.batch();
    for (final d in snap.docs) {
      batch.delete(d.reference);
    }
    await batch.commit();
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
        .map(
          (snap) =>
              snap.docs.map((d) => Reaction.fromFirestore(d.data())).toList(),
        );
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
        .snapshots()
        .map((snap) {
          final list = snap.docs
              .map((d) => TaskTemplate.fromFirestore(d.data()))
              .toList();
          // Sort in-memory - requires index for server-side ordering
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }
}
