import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/failures.dart';
import '../../core/errors/result.dart';
import '../../core/models/models.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';

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

  /// Create circle + owner membership atomically.
  /// Uses a batched write so if one fails, both fail.
  Future<Result<void>> createCircleWithMembership(
    Circle circle,
    CircleMembership membership,
  ) async {
    try {
      final batch = _db.batch();
      batch.set(_col.doc(circle.id), circle.toFirestore());
      batch.set(_membershipCol.doc(membership.id), membership.toFirestore());
      await batch.commit();
      return Result.success(null);
    } catch (e) {
      return Result.failure(AppFailure.unexpected(e.toString()));
    }
  }

  Future<void> updateCircle(Circle circle) async {
    await _col.doc(circle.id).update(circle.toFirestore());
  }

  /// Watch all circles the user is a member of (active only).
  ///
  /// FIX (Phase 1): Replaced N+1 query pattern (get each circle individually
  /// with Future.wait) with a single batch read using Firestore In query.
  ///
  /// Query plan:
  ///   1. Get active membership docs for user → list of circleIds (1 read)
  ///   2. Batch-read all circle docs in one call using whereIn (1 read)
  Stream<List<Circle>> watchUserCircles(String userId) {
    return _membershipCol
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'active')
        .snapshots()
        .asyncMap((snap) async {
      final circleIds = snap.docs
          .map((d) => d['circleId'] as String)
          .where((id) => id.isNotEmpty)
          .toList();
      if (circleIds.isEmpty) return <Circle>[];

      // Single batch read — one Firestore call instead of N
      if (circleIds.length == 1) {
        final doc = await _col.doc(circleIds.first).get();
        if (!doc.exists) return <Circle>[];
        final circle = Circle.fromFirestore(doc.data()!);
        return circle.archived ? <Circle>[] : [circle];
      }

      // For multiple circles: batch read (Firestore In query, max 30 items)
      // Firestore limits whereIn to 30 items; chunk if needed
      final List<Circle> result = [];
      const chunkSize = 30;
      for (var i = 0; i < circleIds.length; i += chunkSize) {
        final chunk = circleIds.sublist(
          i,
          i + chunkSize > circleIds.length ? circleIds.length : i + chunkSize,
        );
        final snap = await _col.where('__name__', whereIn: chunk).get();
        for (final doc in snap.docs) {
          final circle = Circle.fromFirestore(doc.data());
          if (!circle.archived) result.add(circle);
        }
      }
      return result;
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

  Future<Result<Invite>> createInvite(String circleId) async {
    try {
      final now = DateTime.now();
      final invite = Invite(
        id: _inviteCol.doc().id,
        circleId: circleId,
        createdBy: Get.find<AuthController>().firebaseUser?.uid ?? '',
        inviteCode: _generateCode(),
        expiresAt: now.add(const Duration(days: 30)),
        createdAt: now,
        maxUses: 5,
        currentUses: 0,
        status: 'active',
      );
      await _inviteCol.doc(invite.id).set(invite.toFirestore());
      return Result.success(invite);
    } catch (e) {
      return Result.failure(AppFailure.unexpected(e.toString()));
    }
  }

  String _generateCode() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    return List.generate(8, (i) => chars[(random >> (i * 3)) % chars.length]).join();
  }

  /// Join a circle via invite code: adds membership + updates memberIds + increments invite uses.
  Future<Result<void>> joinCircleWithMembership(
    Circle circle,
    CircleMembership membership,
    Invite invite,
  ) async {
    try {
      final batch = _db.batch();
      batch.update(_col.doc(circle.id), {'memberIds': circle.memberIds, 'updatedAt': circle.updatedAt.toIso8601String()});
      batch.set(_membershipCol.doc(membership.id), membership.toFirestore());
      batch.update(_inviteCol.doc(invite.id), {
        'currentUses': invite.currentUses + 1,
        if (invite.currentUses + 1 >= invite.maxUses) 'status': 'expired',
      });
      await batch.commit();
      return Result.success(null);
    } catch (e) {
      return Result.failure(AppFailure.unexpected(e.toString()));
    }
  }

  Future<Invite?> getInviteByCode(String code) async {
    final snap = await _inviteCol
        .where('inviteCode', isEqualTo: code)
        .where('status', isEqualTo: 'active')
        .get();
    if (snap.docs.isEmpty) return null;
    return Invite.fromFirestore(snap.docs.first.data());
  }

  Future<Invite?> getInviteForCircle(String circleId) async {
    final snap = await _inviteCol
        .where('circleId', isEqualTo: circleId)
        .where('status', isEqualTo: 'active')
        .get();
    if (snap.docs.isEmpty) return null;
    // Sort in-memory - requires index for server-side ordering
    final invites = snap.docs.map((d) => Invite.fromFirestore(d.data())).toList();
    invites.sort((a, b) {
      final aTime = a.createdAt ?? DateTime(1970);
      final bTime = b.createdAt ?? DateTime(1970);
      return bTime.compareTo(aTime);
    });
    return invites.first;
  }

  /// Watch a single circle document.
  Stream<Circle?> watchCircle(String circleId) {
    return _col.doc(circleId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return Circle.fromFirestore(doc.data()!);
    });
  }

  Future<Result<void>> leaveCircle(String circleId) async {
    try {
      final uid = Get.find<AuthController>().firebaseUser?.uid;
      if (uid == null) return Result.failure(AppFailure.unexpected('Not authenticated'));
      // Find and update membership
      final snap = await _membershipCol
          .where('circleId', isEqualTo: circleId)
          .where('userId', isEqualTo: uid)
          .where('status', isEqualTo: 'active')
          .limit(1)
          .get();
      if (snap.docs.isNotEmpty) {
        await snap.docs.first.reference.update({'status': 'removed'});
      }
      return Result.success(null);
    } catch (e) {
      return Result.failure(AppFailure.unexpected(e.toString()));
    }
  }
}
