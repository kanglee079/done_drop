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

  CollectionReference<Map<String, dynamic>> get _userDirectoryCol =>
      _db.collection(AppConstants.colUserDirectory);

  CollectionReference<Map<String, dynamic>> get _userCodeLookupCol =>
      _db.collection(AppConstants.colUserCodeLookup);

  CollectionReference<Map<String, dynamic>> get _userUsernameLookupCol =>
      _db.collection(AppConstants.colUserUsernameLookup);

  CollectionReference<Map<String, dynamic>> get _userEmailLookupCol =>
      _db.collection(AppConstants.colUserEmailLookup);

  // ── Friendships ────────────────────────────────────────────────────────

  /// Watch all friendships for a user.
  Stream<List<Friendship>> watchFriendships(String userId) {
    late final StreamController<List<Friendship>> controller;
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? firstSub;
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? secondSub;
    List<Friendship> firstHalf = const <Friendship>[];
    List<Friendship> secondHalf = const <Friendship>[];

    void emitCombined() {
      if (controller.isClosed) return;
      final combined = <Friendship>[...firstHalf, ...secondHalf]
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      controller.add(combined);
    }

    controller = StreamController<List<Friendship>>(
      onListen: () {
        firstSub = _friendshipsCol
            .where('userId1', isEqualTo: userId)
            .snapshots()
            .listen((snap) {
              firstHalf = snap.docs
                  .map((doc) => Friendship.fromFirestore(doc.data()))
                  .toList(growable: false);
              emitCombined();
            }, onError: controller.addError);

        secondSub = _friendshipsCol
            .where('userId2', isEqualTo: userId)
            .snapshots()
            .listen((snap) {
              secondHalf = snap.docs
                  .map((doc) => Friendship.fromFirestore(doc.data()))
                  .toList(growable: false);
              emitCombined();
            }, onError: controller.addError);
      },
      onCancel: () async {
        await firstSub?.cancel();
        await secondSub?.cancel();
      },
    );

    return controller.stream;
  }

  /// Get count of accepted friends.
  Future<int> getFriendCount(String userId) async {
    final snap1 = await _friendshipsCol
        .where('userId1', isEqualTo: userId)
        .count()
        .get();
    final snap2 = await _friendshipsCol
        .where('userId2', isEqualTo: userId)
        .count()
        .get();
    return (snap1.count ?? 0) + (snap2.count ?? 0);
  }

  /// Get all accepted friendships for a user (one-shot, not a stream).
  Future<List<Friendship>> getFriends(String userId) async {
    final snap1 = await _friendshipsCol
        .where('userId1', isEqualTo: userId)
        .get();
    final snap2 = await _friendshipsCol
        .where('userId2', isEqualTo: userId)
        .get();
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
    final profileDoc = await _usersCol.doc(userId).get();
    final isPremium = profileDoc.data()?['premiumStatus'] == true;
    if (isPremium) {
      return true;
    }

    final count = await getFriendCount(userId);
    return count < maxFriendsFree;
  }

  /// Get a friend's user profile by friendship ID.
  Future<UserProfile?> getFriendProfile(String friendId) async {
    final doc = await _usersCol.doc(friendId).get();
    if (!doc.exists) return null;
    return UserProfile.fromFirestore(doc.data()!);
  }

  /// Get a lightweight public profile for pending friend requests.
  Future<UserProfile?> getRequestPreviewProfile(String userId) async {
    try {
      final doc = await _userDirectoryCol.doc(userId).get();
      if (!doc.exists || doc.data() == null) {
        return null;
      }
      return UserProfile.fromFirestore(doc.data()!);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return null;
      }
      rethrow;
    }
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
    try {
      if (senderId == receiverId) {
        return Result.failure(
          AppFailure.unexpected(
            'Cannot send friend request to yourself',
            'friend_request_self',
          ),
        );
      }

      final receiverDoc = await _userDirectoryCol.doc(receiverId).get();
      if (!receiverDoc.exists || receiverDoc.data() == null) {
        return Result.failure(
          AppFailure.notFound(
            'No user found with this ID',
            'friend_request_user_not_found',
          ),
        );
      }

      final friendship = Friendship.create(senderId, receiverId);
      final existingFriendship = await _friendshipsCol
          .where('userId1', isEqualTo: friendship.userId1)
          .where('userId2', isEqualTo: friendship.userId2)
          .limit(1)
          .get();
      if (existingFriendship.docs.isNotEmpty) {
        return Result.failure(
          AppFailure.conflict(
            'You are already friends',
            'friend_request_already_friends',
          ),
        );
      }

      // Enforce friend cap for sender
      final canAdd = await canAddFriend(senderId);
      if (!canAdd) {
        return Result.failure(
          AppFailure.forbidden(
            'You have reached the maximum of $maxFriendsFree friends on the free plan. Upgrade to add more.',
            'friend_cap_reached',
          ),
        );
      }

      // Check for existing request
      final existing = await _requestsCol
          .where('senderId', isEqualTo: senderId)
          .where('receiverId', isEqualTo: receiverId)
          .where('status', whereIn: ['pending', 'accepted'])
          .get();

      if (existing.docs.isNotEmpty) {
        return Result.failure(
          AppFailure.conflict(
            'Friend request already exists',
            'friend_request_exists',
          ),
        );
      }

      final reverse = await _requestsCol
          .where('senderId', isEqualTo: receiverId)
          .where('receiverId', isEqualTo: senderId)
          .where('status', whereIn: ['pending', 'accepted'])
          .get();

      if (reverse.docs.isNotEmpty) {
        return Result.failure(
          AppFailure.conflict(
            'Friend request already exists',
            'friend_request_exists',
          ),
        );
      }

      var resolvedSenderDisplayName = senderDisplayName.trim();
      if (resolvedSenderDisplayName.isEmpty) {
        final senderDoc = await _usersCol.doc(senderId).get();
        final senderData = senderDoc.data();
        final profileName =
            (senderData?['displayName'] as String?)?.trim() ?? '';
        if (profileName.isNotEmpty) {
          resolvedSenderDisplayName = profileName;
        }
      }

      final id = _requestsCol.doc().id;
      final request = FriendRequest(
        id: id,
        senderId: senderId,
        receiverId: receiverId,
        status: 'pending',
        createdAt: DateTime.now(),
        senderDisplayName: resolvedSenderDisplayName.isEmpty
            ? null
            : resolvedSenderDisplayName,
        senderAvatarUrl: senderAvatarUrl,
        message: message,
      );

      await _requestsCol.doc(id).set(request.toFirestore());
      return Result.success(request);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return Result.failure(
          AppFailure.forbidden(
            e.message ?? 'Permission denied.',
            'friend_request_permission_denied',
          ),
        );
      }
      return Result.failure(
        AppFailure.unexpected(
          e.message ?? e.toString(),
          'friend_request_unexpected',
        ),
      );
    } catch (e) {
      return Result.failure(
        AppFailure.unexpected(e.toString(), 'friend_request_unexpected'),
      );
    }
  }

  /// Accept a pending friend request. Creates a Friendship document.
  Future<Result<FriendRequest>> acceptRequest(String requestId) async {
    try {
      final requestRef = _requestsCol.doc(requestId);
      final doc = await requestRef.get();
      if (!doc.exists || doc.data() == null) {
        return Result.failure(
          AppFailure.notFound('Request not found', 'friend_request_not_found'),
        );
      }

      final request = FriendRequest.fromFirestore(doc.data()!);
      if (request.isAccepted) {
        return Result.success(request);
      }
      if (!request.isPending) {
        return Result.failure(
          AppFailure.conflict(
            'Request is no longer pending.',
            'friend_request_not_pending',
          ),
        );
      }

      final friendship = Friendship.create(
        request.senderId,
        request.receiverId,
      );
      final friendshipRef = _friendshipsCol.doc(friendship.id);
      final existingFriendship = await _friendshipsCol
          .where('userId1', isEqualTo: friendship.userId1)
          .where('userId2', isEqualTo: friendship.userId2)
          .limit(1)
          .get();
      final friendshipExists = existingFriendship.docs.isNotEmpty;
      if (friendshipExists) {
        await requestRef.update({'status': 'accepted'});
        return Result.success(request.copyWith(status: 'accepted'));
      }

      final receiverCanAdd = await canAddFriend(request.receiverId);
      if (!receiverCanAdd) {
        return Result.failure(
          AppFailure.forbidden(
            'You have reached the maximum of $maxFriendsFree friends. Remove a friend to accept new ones.',
            'friend_cap_reached',
          ),
        );
      }

      final batch = _db.batch();
      batch.update(requestRef, {'status': 'accepted'});
      batch.set(friendshipRef, friendship.toFirestore());
      await batch.commit();

      return Result.success(request.copyWith(status: 'accepted'));
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return Result.failure(
          AppFailure.forbidden(
            e.message ?? 'Permission denied.',
            'friend_accept_permission_denied',
          ),
        );
      }
      return Result.failure(
        AppFailure.unexpected(
          e.message ?? e.toString(),
          'friend_accept_unexpected',
        ),
      );
    } catch (e) {
      return Result.failure(
        AppFailure.unexpected(e.toString(), 'friend_accept_unexpected'),
      );
    }
  }

  /// Decline a pending friend request.
  Future<Result<void>> declineRequest(String requestId) async {
    try {
      await _requestsCol.doc(requestId).update({'status': 'declined'});
      return Result.success(null);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return Result.failure(
          AppFailure.forbidden(
            e.message ?? 'Permission denied.',
            'friend_decline_permission_denied',
          ),
        );
      }
      return Result.failure(
        AppFailure.unexpected(
          e.message ?? e.toString(),
          'friend_decline_unexpected',
        ),
      );
    } catch (e) {
      return Result.failure(
        AppFailure.unexpected(e.toString(), 'friend_decline_unexpected'),
      );
    }
  }

  /// Cancel an outgoing friend request.
  Future<Result<void>> cancelRequest(String requestId) async {
    try {
      await _requestsCol.doc(requestId).update({'status': 'cancelled'});
      return Result.success(null);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return Result.failure(
          AppFailure.forbidden(
            e.message ?? 'Permission denied.',
            'friend_cancel_permission_denied',
          ),
        );
      }
      return Result.failure(
        AppFailure.unexpected(
          e.message ?? e.toString(),
          'friend_cancel_unexpected',
        ),
      );
    } catch (e) {
      return Result.failure(
        AppFailure.unexpected(e.toString(), 'friend_cancel_unexpected'),
      );
    }
  }

  /// Remove a friendship and cancel related requests.
  Future<Result<void>> removeFriend(
    String friendshipId,
    String currentUserId,
  ) async {
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

  /// Search by userCode (6-char unique ID for QR/ID sharing).
  Future<Result<UserProfile>> findUserByCode(String code) async {
    try {
      final normalizedCode = code.toUpperCase().trim();
      final lookup = await _userCodeLookupCol.doc(normalizedCode).get();
      final userId = lookup.data()?['userId'] as String?;
      if (!lookup.exists || userId == null || userId.isEmpty) {
        return Result.failure(
          AppFailure.notFound(
            'No user found with this code',
            'friend_code_not_found',
          ),
        );
      }
      return _findDirectoryUserById(
        userId,
        notFoundMessage: 'No user found with this code',
      );
    } catch (e) {
      return Result.failure(AppFailure.unexpected(e.toString()));
    }
  }

  /// Search by the document ID / canonical user ID.
  Future<Result<UserProfile>> findUserById(String userId) async {
    try {
      final trimmedUserId = userId.trim();
      if (trimmedUserId.isEmpty) {
        return Result.failure(
          AppFailure.notFound(
            'No user found with this ID',
            'friend_id_not_found',
          ),
        );
      }
      return _findDirectoryUserById(
        trimmedUserId,
        notFoundMessage: 'No user found with this ID',
      );
    } catch (e) {
      return Result.failure(AppFailure.unexpected(e.toString()));
    }
  }

  /// Search by username (preferred over email for privacy).
  Future<Result<UserProfile>> findUserByUsername(String username) async {
    try {
      final normalizedUsername = username.toLowerCase().trim();
      final lookup = await _userUsernameLookupCol.doc(normalizedUsername).get();
      final userId = lookup.data()?['userId'] as String?;
      if (!lookup.exists || userId == null || userId.isEmpty) {
        return Result.failure(
          AppFailure.notFound(
            'No user found with this username',
            'friend_username_not_found',
          ),
        );
      }
      return _findDirectoryUserById(
        userId,
        notFoundMessage: 'No user found with this username',
      );
    } catch (e) {
      return Result.failure(AppFailure.unexpected(e.toString()));
    }
  }

  /// Search by email (still available but less preferred).
  Future<Result<UserProfile>> findUserByEmail(String email) async {
    try {
      final normalizedEmail = email.toLowerCase().trim();
      final lookup = await _userEmailLookupCol.doc(normalizedEmail).get();
      final userId = lookup.data()?['userId'] as String?;
      if (!lookup.exists || userId == null || userId.isEmpty) {
        return Result.failure(
          AppFailure.notFound(
            'No user found with this email',
            'friend_email_not_found',
          ),
        );
      }
      return _findDirectoryUserById(
        userId,
        notFoundMessage: 'No user found with this email',
      );
    } catch (e) {
      return Result.failure(AppFailure.unexpected(e.toString()));
    }
  }

  Future<Result<UserProfile>> _findDirectoryUserById(
    String userId, {
    required String notFoundMessage,
  }) async {
    final doc = await _userDirectoryCol.doc(userId).get();
    if (!doc.exists || doc.data() == null) {
      final code = switch (notFoundMessage) {
        'No user found with this code' => 'friend_code_not_found',
        'No user found with this ID' => 'friend_id_not_found',
        'No user found with this username' => 'friend_username_not_found',
        'No user found with this email' => 'friend_email_not_found',
        _ => null,
      };
      return Result.failure(AppFailure.notFound(notFoundMessage, code));
    }
    return Result.success(UserProfile.fromFirestore(doc.data()!));
  }
}
