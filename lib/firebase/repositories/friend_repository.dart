import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_constants.dart';
import '../../core/models/friend_request.dart';
import '../../core/models/user_profile.dart';
import '../../core/errors/failures.dart';
import '../../core/errors/result.dart';

/// Repository for friend request operations and friend list management.
///
/// Friend graph model:
/// - friend_requests collection: sent requests between two users
/// - Accepted requests define the friendship
/// - Pending requests show outgoing/incoming requests
///
/// To find all friends of a user:
///   Query friend_requests where (senderId == uid OR receiverId == uid) AND status == 'accepted'
///   The friend is the other user in each accepted pair.
class FriendRepository {
  FriendRepository(this._db);
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _requestsCol =>
      _db.collection(AppConstants.colFriendRequests);

  CollectionReference<Map<String, dynamic>> get _usersCol =>
      _db.collection(AppConstants.colUsers);

  // ── Friend Requests ───────────────────────────────────────────────────────

  /// Send a friend request from senderId to receiverId.
  /// Fails if a request already exists (pending or accepted).
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

    try {
      // Check if there's already an active request between these two users
      final existing = await _requestsCol
          .where('senderId', isEqualTo: senderId)
          .where('receiverId', isEqualTo: receiverId)
          .where('status', whereIn: ['pending', 'accepted'])
          .get();

      if (existing.docs.isNotEmpty) {
        return Result.failure(AppFailure.conflict('Friend request already exists'));
      }

      // Also check reverse direction
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
    } catch (e) {
      return Result.failure(AppFailure.unexpected(e.toString()));
    }
  }

  /// Accept a pending friend request.
  Future<Result<FriendRequest>> acceptRequest(String requestId) async {
    try {
      final doc = await _requestsCol.doc(requestId).get();
      if (!doc.exists) {
        return Result.failure(AppFailure.notFound('Request not found'));
      }
      final request = FriendRequest.fromFirestore(doc.data()!);
      if (!request.isPending) {
        return Result.failure(AppFailure.unexpected('Request is not pending'));
      }
      final updated = request.copyWith(status: 'accepted');
      await _requestsCol.doc(requestId).update({'status': 'accepted'});
      return Result.success(updated);
    } catch (e) {
      return Result.failure(AppFailure.unexpected(e.toString()));
    }
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

  /// Watch incoming friend requests (requests sent TO the current user).
  Stream<List<FriendRequest>> watchIncomingRequests(String userId) {
    return _requestsCol
        .where('receiverId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snap) {
          final list = snap.docs
              .map((d) => FriendRequest.fromFirestore(d.data()))
              .toList();
          // Sort in-memory - requires index for server-side ordering
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }

  /// Watch outgoing friend requests (requests sent BY the current user).
  Stream<List<FriendRequest>> watchOutgoingRequests(String userId) {
    return _requestsCol
        .where('senderId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snap) {
          final list = snap.docs
              .map((d) => FriendRequest.fromFirestore(d.data()))
              .toList();
          // Sort in-memory - requires index for server-side ordering
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }

  // ── Friend List ──────────────────────────────────────────────────────────

  /// Watch all accepted friends of a user.
  /// Each FriendRequest in the stream represents one friendship.
  Stream<List<FriendRequest>> watchFriends(String userId) {
    final senderStream = _requestsCol
        .where('senderId', isEqualTo: userId)
        .where('status', isEqualTo: 'accepted')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => FriendRequest.fromFirestore(d.data()))
            .toList());

    final receiverStream = _requestsCol
        .where('receiverId', isEqualTo: userId)
        .where('status', isEqualTo: 'accepted')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => FriendRequest.fromFirestore(d.data()))
            .toList());

    final controller = StreamController<List<FriendRequest>>();
    senderStream.listen((sender) {
      receiverStream.first.then((receiver) {
        final Map<String, FriendRequest> seen = {};
        for (final r in sender) seen[r.id] = r;
        for (final r in receiver) seen[r.id] = r;
        final list = seen.values.toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        controller.add(list);
      });
    });

    return controller.stream;
  }

  /// Watch the count of pending incoming requests (for badge).
  Stream<int> watchIncomingRequestCount(String userId) {
    return _requestsCol
        .where('receiverId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  // ── User Search ─────────────────────────────────────────────────────────

  /// Search for users by email address.
  Future<Result<UserProfile>> findUserByEmail(String email) async {
    try {
      final snap = await _usersCol
          .where('email', isEqualTo: email.toLowerCase().trim())
          .limit(1)
          .get();
      if (snap.docs.isEmpty) {
        return Result.failure(AppFailure.notFound('No user found with this email'));
      }
      final profile = UserProfile.fromFirestore(snap.docs.first.data());
      return Result.success(profile);
    } catch (e) {
      return Result.failure(AppFailure.unexpected(e.toString()));
    }
  }

  // ── Remove Friend ─────────────────────────────────────────────────────

  /// Remove a friendship (decline/accept/cancel pairs).
  Future<Result<void>> removeFriend(String friendshipId) async {
    try {
      await _requestsCol.doc(friendshipId).delete();
      return Result.success(null);
    } catch (e) {
      return Result.failure(AppFailure.unexpected(e.toString()));
    }
  }
}
