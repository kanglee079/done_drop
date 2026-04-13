import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_constants.dart';
import '../../core/models/friend_request.dart';
import '../../core/models/friendship.dart';
import '../../core/models/user_profile.dart';
import '../../core/errors/failures.dart';
import '../../core/errors/result.dart';

/// Repository for friend relationships and friend requests.
///
/// Friend graph:
/// - friend_requests: pending/accepted/declined requests
/// - friendships: accepted friend pairs (used for efficient lookups and cap enforcement)
///
/// Free plan: max 5 accepted friends.
class FriendRepository {
  FriendRepository(this._db);
  final FirebaseFirestore _db;

  static const int maxFriendsFree = 5;

  CollectionReference<Map<String, dynamic>> get _requestsCol =>
      _db.collection(AppConstants.colFriendRequests);

  CollectionReference<Map<String, dynamic>> get _friendshipsCol =>
      _db.collection(AppConstants.colFriendships);

  CollectionReference<Map<String, dynamic>> get _usersCol =>
      _db.collection(AppConstants.colUsers);

  // ── Friendships ────────────────────────────────────────────────────────

  /// Watch all friendships for a user.
  Stream<List<Friendship>> watchFriendships(String userId) {
    return _friendshipsCol
        .where('userId1', isEqualTo: userId)
        .snapshots()
        .asyncMap((snap1) async {
          final secondSnap = await _friendshipsCol
              .where('userId2', isEqualTo: userId)
              .get();
          final all = <Friendship>[];
          for (final d in snap1.docs) {
            all.add(Friendship.fromFirestore(d.data()));
          }
          for (final d in secondSnap.docs) {
            all.add(Friendship.fromFirestore(d.data()));
          }
          all.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return all;
        });
  }

  /// Get count of accepted friends.
  Future<int> getFriendCount(String userId) async {
    final snap1 = await _friendshipsCol.where('userId1', isEqualTo: userId).count().get();
    final snap2 = await _friendshipsCol.where('userId2', isEqualTo: userId).count().get();
    return (snap1.count ?? 0) + (snap2.count ?? 0);
  }

  /// Get all accepted friendships for a user (one-shot, not a stream).
  Future<List<Friendship>> getFriends(String userId) async {
    final snap1 = await _friendshipsCol.where('userId1', isEqualTo: userId).get();
    final snap2 = await _friendshipsCol.where('userId2', isEqualTo: userId).get();
    final all = <Friendship>[];
    for (final d in snap1.docs) {
      all.add(Friendship.fromFirestore(d.data()));
    }
    for (final d in snap2.docs) {
      all.add(Friendship.fromFirestore(d.data()));
    }
    all.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return all;
  }

  /// Check if user can add more friends (under cap).
  Future<bool> canAddFriend(String userId) async {
    final count = await getFriendCount(userId);
    return count < maxFriendsFree;
  }

  /// Get a friend's user profile by friendship ID.
  Future<UserProfile?> getFriendProfile(String friendId) async {
    final doc = await _usersCol.doc(friendId).get();
    if (!doc.exists) return null;
    return UserProfile.fromFirestore(doc.data()!);
  }

  // ── Friend Requests ──────────────────────────────────────────────────

  /// Send a friend request. Enforces cap=5.
  Future<Result<FriendRequest>> sendFriendRequest({
    required String senderId,
    required String receiverId,
    required String senderDisplayName,
    String? senderAvatarUrl,
    String? message,
  }) async {
    if (senderId == receiverId) {
      return Result.failure(AppFailure.unexpected('Cannot send friend request to yourself'));
    }

    // Enforce friend cap for sender
    final canAdd = await canAddFriend(senderId);
    if (!canAdd) {
      return Result.failure(AppFailure.forbidden(
          'You have reached the maximum of $maxFriendsFree friends on the free plan. Upgrade to add more.'));
    }

    // Check for existing request
    final existing = await _requestsCol
        .where('senderId', isEqualTo: senderId)
        .where('receiverId', isEqualTo: receiverId)
        .where('status', whereIn: ['pending', 'accepted'])
        .get();

    if (existing.docs.isNotEmpty) {
      return Result.failure(AppFailure.conflict('Friend request already exists'));
    }

    final reverse = await _requestsCol
        .where('senderId', isEqualTo: receiverId)
        .where('receiverId', isEqualTo: senderId)
        .where('status', whereIn: ['pending', 'accepted'])
        .get();

    if (reverse.docs.isNotEmpty) {
      return Result.failure(AppFailure.conflict('Friend request already exists'));
    }

    final id = _requestsCol.doc().id;
    final request = FriendRequest(
      id: id,
      senderId: senderId,
      receiverId: receiverId,
      status: 'pending',
      createdAt: DateTime.now(),
      senderDisplayName: senderDisplayName,
      senderAvatarUrl: senderAvatarUrl,
      message: message,
    );

    await _requestsCol.doc(id).set(request.toFirestore());
    return Result.success(request);
  }

  /// Accept a pending friend request. Creates a Friendship document.
  Future<Result<FriendRequest>> acceptRequest(String requestId) async {
    final doc = await _requestsCol.doc(requestId).get();
    if (!doc.exists) {
      return Result.failure(AppFailure.notFound('Request not found'));
    }

    final request = FriendRequest.fromFirestore(doc.data()!);
    if (!request.isPending) {
      return Result.failure(AppFailure.unexpected('Request is not pending'));
    }

    // Enforce cap on both sides: sender (who gets a new friend) and receiver (who also gets a new friend)
    final senderId = request.senderId;
    final receiverId = request.receiverId;

    final senderCanAdd = await canAddFriend(senderId);
    if (!senderCanAdd) {
      return Result.failure(AppFailure.forbidden(
          '${request.senderDisplayName ?? 'This user'} has reached the maximum of $maxFriendsFree friends.'));
    }

    final receiverCanAdd = await canAddFriend(receiverId);
    if (!receiverCanAdd) {
      return Result.failure(AppFailure.forbidden(
          'You have reached the maximum of $maxFriendsFree friends. Remove a friend to accept new ones.'));
    }

    // Update request to accepted
    await _requestsCol.doc(requestId).update({'status': 'accepted'});

    // Create friendship document (idempotent: sender and receiver both use same doc)
    final friendship = Friendship.create(request.senderId, request.receiverId);
    await _friendshipsCol.doc(friendship.id).set(friendship.toFirestore());

    return Result.success(request.copyWith(status: 'accepted'));
  }

  /// Decline a pending friend request.
  Future<Result<void>> declineRequest(String requestId) async {
    try {
      await _requestsCol.doc(requestId).update({'status': 'declined'});
      return Result.success(null);
    } catch (e) {
      return Result.failure(AppFailure.unexpected(e.toString()));
    }
  }

  /// Cancel an outgoing friend request.
  Future<Result<void>> cancelRequest(String requestId) async {
    try {
      await _requestsCol.doc(requestId).update({'status': 'cancelled'});
      return Result.success(null);
    } catch (e) {
      return Result.failure(AppFailure.unexpected(e.toString()));
    }
  }

  /// Remove a friendship and cancel related requests.
  Future<Result<void>> removeFriend(String friendshipId, String currentUserId) async {
    final friendshipDoc = await _friendshipsCol.doc(friendshipId).get();
    if (!friendshipDoc.exists) {
      return Result.failure(AppFailure.notFound('Friendship not found'));
    }

    final friendship = Friendship.fromFirestore(friendshipDoc.data()!);
    final otherId = friendship.otherUserId(currentUserId);

    final batch = _db.batch();

    // Delete friendship
    batch.delete(_friendshipsCol.doc(friendshipId));

    // Cancel pending requests in both directions
    final reqSnap1 = await _requestsCol
        .where('senderId', isEqualTo: currentUserId)
        .where('receiverId', isEqualTo: otherId)
        .where('status', isEqualTo: 'pending')
        .get();
    for (final d in reqSnap1.docs) {
      batch.update(d.reference, {'status': 'cancelled'});
    }

    final reqSnap2 = await _requestsCol
        .where('senderId', isEqualTo: otherId)
        .where('receiverId', isEqualTo: currentUserId)
        .where('status', isEqualTo: 'pending')
        .get();
    for (final d in reqSnap2.docs) {
      batch.update(d.reference, {'status': 'cancelled'});
    }

    await batch.commit();
    return Result.success(null);
  }

  // ── Watch streams ──────────────────────────────────────────────────

  Stream<List<FriendRequest>> watchIncomingRequests(String userId) {
    return _requestsCol
        .where('receiverId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snap) {
          final list = snap.docs
              .map((d) => FriendRequest.fromFirestore(d.data()))
              .toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }

  Stream<List<FriendRequest>> watchOutgoingRequests(String userId) {
    return _requestsCol
        .where('senderId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snap) {
          final list = snap.docs
              .map((d) => FriendRequest.fromFirestore(d.data()))
              .toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }

  Stream<int> watchIncomingRequestCount(String userId) {
    return _requestsCol
        .where('receiverId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  // ── User Search ──────────────────────────────────────────────────

  /// Search by username (preferred over email for privacy).
  Future<Result<UserProfile>> findUserByUsername(String username) async {
    try {
      final snap = await _usersCol
          .where('username', isEqualTo: username.toLowerCase().trim())
          .limit(1)
          .get();
      if (snap.docs.isEmpty) {
        return Result.failure(AppFailure.notFound('No user found with this username'));
      }
      return Result.success(UserProfile.fromFirestore(snap.docs.first.data()));
    } catch (e) {
      return Result.failure(AppFailure.unexpected(e.toString()));
    }
  }

  /// Search by email (still available but less preferred).
  Future<Result<UserProfile>> findUserByEmail(String email) async {
    try {
      final snap = await _usersCol
          .where('email', isEqualTo: email.toLowerCase().trim())
          .limit(1)
          .get();
      if (snap.docs.isEmpty) {
        return Result.failure(AppFailure.notFound('No user found with this email'));
      }
      return Result.success(UserProfile.fromFirestore(snap.docs.first.data()));
    } catch (e) {
      return Result.failure(AppFailure.unexpected(e.toString()));
    }
  }
}
