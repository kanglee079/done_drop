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
  static const String _legacyTaskTemplatesCollection = 'task_templates';

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection(AppConstants.colMoments);

  CollectionReference<Map<String, dynamic>> get _reactionCol =>
      _db.collection(AppConstants.colReactions);

  CollectionReference<Map<String, dynamic>> get _taskCol =>
      _db.collection(_legacyTaskTemplatesCollection);

  CollectionReference<Map<String, dynamic>> get _feedDeliveryCol =>
      _db.collection(AppConstants.colFeedDeliveries);

  static String reactionDocumentId(String momentId, String userId) =>
      'reaction_${momentId}_$userId';

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

  Future<void> updateMomentThumbnail(
    String momentId,
    MediaMetadata thumbnail,
  ) async {
    await _col.doc(momentId).update({
      'media.thumbnail': thumbnail.toFirestore(),
      'updatedAt': DateTime.now().toIso8601String(),
    });
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
    try {
      await FirebaseStorage.instance
          .ref()
          .child('moments/$ownerId/$momentId/original_280x420.jpg')
          .delete();
    } catch (_) {}
  }

  /// Personal-only moments by user.
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

  /// Owner archive moments include all moments the user created, regardless of visibility.
  Stream<List<Moment>> watchOwnerArchiveMoments(
    String userId, {
    int limit = 50,
  }) {
    return _col
        .where('ownerId', isEqualTo: userId)
        .where('isDeleted', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots(includeMetadataChanges: true)
        .map(
          (snap) =>
              snap.docs.map((d) => Moment.fromFirestore(d.data())).toList(),
        );
  }

  // ── Private Friend Feed ──────────────────────────────────────────────

  /// Create feed delivery entries for each recipient of a moment.
  /// Called after a moment is saved with visibility all_friends or selected_friends.
  Future<void> createFeedDeliveries({
    required Moment moment,
    required List<String> recipientIds,
  }) async {
    final deliveries = _deliveryPlanner.buildDeliveries(
      moment: moment,
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
        .snapshots(includeMetadataChanges: true)
        .map(
          (snap) => snap.docs
              .map((d) => FeedDelivery.fromFirestore(d.data()))
              .toList(),
        );
  }

  Stream<List<Moment>> watchVisibleBuddyMoments({
    required List<String> ownerIds,
    required String viewerId,
    int limit = 50,
  }) {
    final uniqueOwnerIds =
        ownerIds.where((id) => id.isNotEmpty).toSet().toList()..sort();
    if (uniqueOwnerIds.isEmpty) {
      return Stream<List<Moment>>.value(const <Moment>[]);
    }

    final effectiveOwnerIds = uniqueOwnerIds.take(10).toList(growable: false);

    return _col
        .where('ownerId', whereIn: effectiveOwnerIds)
        .where(
          'visibility',
          whereIn: const [
            AppConstants.visibilityAllFriends,
            AppConstants.visibilitySelectedFriends,
          ],
        )
        .where('isDeleted', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots(includeMetadataChanges: true)
        .map(
          (snap) => snap.docs
              .map((doc) => Moment.fromFirestore(doc.data()))
              .where(
                (moment) => _isMomentVisibleToViewer(
                  moment: moment,
                  viewerId: viewerId,
                ),
              )
              .toList(growable: false),
        );
  }

  Future<List<FeedDelivery>> fetchFeedDeliveriesPage(
    String userId, {
    DateTime? startAfterCreatedAt,
    int limit = 20,
  }) async {
    Query<Map<String, dynamic>> query = _feedDeliveryCol
        .where('recipientId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (startAfterCreatedAt != null) {
      query = query.startAfter([startAfterCreatedAt.toIso8601String()]);
    }

    final snap = await query.get();
    return snap.docs
        .map((doc) => FeedDelivery.fromFirestore(doc.data()))
        .toList(growable: false);
  }

  /// Mark a feed delivery as read.
  Future<void> markDeliveryRead(String deliveryId) async {
    await _feedDeliveryCol.doc(deliveryId).update({'isRead': true});
  }

  Future<void> updateFeedDeliveryThumbnail(
    String momentId,
    String thumbnailUrl,
  ) async {
    final snap = await _feedDeliveryCol
        .where('momentId', isEqualTo: momentId)
        .get();
    if (snap.docs.isEmpty) return;

    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'thumbnailUrl': thumbnailUrl});
    }
    await batch.commit();
  }

  /// Get unread feed delivery count for a user.
  Stream<int> watchUnreadFeedCount(String userId) {
    return _feedDeliveryCol
        .where('recipientId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snap) => snap.docs.length);
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

  bool _isMomentVisibleToViewer({
    required Moment moment,
    required String viewerId,
  }) {
    switch (moment.visibility) {
      case AppConstants.visibilityAllFriends:
        return true;
      case AppConstants.visibilitySelectedFriends:
        return moment.selectedFriendIds.contains(viewerId);
      default:
        return false;
    }
  }

  // ── Reactions ─────────────────────────────────────────────────────────
  Future<void> addReaction(Reaction reaction) async {
    await _reactionCol.doc(reaction.id).set(reaction.toFirestore());
  }

  Future<void> removeReaction(String momentId, String userId) async {
    try {
      await _reactionCol.doc(reactionDocumentId(momentId, userId)).delete();
    } on FirebaseException catch (error) {
      if (error.code != 'not-found') {
        rethrow;
      }
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

  Stream<MomentReactionSummary> watchReactionSummary(
    String momentId, {
    required String currentUserId,
  }) {
    return watchReactions(momentId).map((reactions) {
      final counts = <String, int>{};
      String? currentUserReaction;

      for (final reaction in reactions) {
        counts.update(
          reaction.reactionType,
          (value) => value + 1,
          ifAbsent: () => 1,
        );
        if (reaction.userId == currentUserId) {
          currentUserReaction = reaction.reactionType;
        }
      }

      return MomentReactionSummary(
        counts: counts,
        currentUserReaction: currentUserReaction,
      );
    });
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
