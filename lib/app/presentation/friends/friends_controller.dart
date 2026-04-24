import 'dart:async';
import 'dart:math' as math;

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:done_drop/core/errors/failures.dart';
import 'package:done_drop/features/auth/presentation/controllers/auth_controller.dart';
import 'package:done_drop/firebase/repositories/friend_repository.dart';
import 'package:done_drop/core/models/friend_request.dart';
import 'package:done_drop/core/models/friendship.dart';
import 'package:done_drop/core/models/user_profile.dart';
import 'package:done_drop/core/errors/result.dart';
import 'package:done_drop/core/services/analytics_service.dart';
import 'package:done_drop/core/services/storage_service.dart';
import 'package:done_drop/core/theme/theme.dart';
import 'package:done_drop/l10n/l10n.dart';

/// Controller for friend management screens.
class FriendsController extends GetxController {
  FriendsController(this._friendRepo);
  final FriendRepository _friendRepo;

  /// Expose repository for screens that need direct access.
  FriendRepository get friendRepo => _friendRepo;

  String? get _userId => Get.find<AuthController>().firebaseUser?.uid;
  String? get currentUserId => _userId;

  /// Accepted friendships.
  final RxList<Friendship> friendships = <Friendship>[].obs;

  /// Incoming pending requests.
  final RxList<FriendRequest> incomingRequests = <FriendRequest>[].obs;

  /// Outgoing pending requests.
  final RxList<FriendRequest> outgoingRequests = <FriendRequest>[].obs;

  /// Pending request count (for badge).
  final RxInt pendingRequestCount = 0.obs;
  final RxMap<String, String> _requestActions = <String, String>{}.obs;

  /// Current friend count.
  final RxInt friendCount = 0.obs;
  final Map<String, Future<UserProfile?>> _profileFutures =
      <String, Future<UserProfile?>>{};
  final Map<String, Future<UserProfile?>> _requestProfileFutures =
      <String, Future<UserProfile?>>{};
  StreamSubscription<List<Friendship>>? _friendshipsSubscription;

  /// Whether the user has reached the friend cap.
  bool get isAtFriendCap =>
      !StorageService.instance.isPremium &&
      friendCount.value >= FriendRepository.maxFriendsFree;

  int get maxFriends => FriendRepository.maxFriendsFree;

  bool get hasPendingRequests => incomingRequests.isNotEmpty;
  bool isRequestBusy(String requestId) =>
      _requestActions.containsKey(requestId);
  bool isAccepting(String requestId) => _requestActions[requestId] == 'accept';
  bool isDeclining(String requestId) => _requestActions[requestId] == 'decline';
  bool isCancelling(String requestId) => _requestActions[requestId] == 'cancel';

  @override
  void onInit() {
    super.onInit();
    _watchFriendships();
    _watchIncomingRequests();
    _watchOutgoingRequests();
  }

  void _watchFriendships() {
    final uid = _userId;
    if (uid == null) return;
    _friendshipsSubscription?.cancel();
    _friendshipsSubscription = _friendRepo
        .watchFriendships(uid)
        .listen(
          (list) {
            friendships.value = list;
            friendCount.value = list.length;
          },
          onError: (error) {
            Get.log('[_watchFriendships] Error: $error');
          },
        );
  }

  void _watchIncomingRequests() {
    final uid = _userId;
    if (uid == null) return;
    incomingRequests.bindStream(_friendRepo.watchIncomingRequests(uid));
    pendingRequestCount.bindStream(_friendRepo.watchIncomingRequestCount(uid));
  }

  void _watchOutgoingRequests() {
    final uid = _userId;
    if (uid == null) return;
    outgoingRequests.bindStream(_friendRepo.watchOutgoingRequests(uid));
  }

  /// Accept an incoming friend request.
  Future<bool> acceptRequest(FriendRequest request) async {
    if (isRequestBusy(request.id)) return false;
    _requestActions[request.id] = 'accept';

    try {
      final result = await _friendRepo.acceptRequest(request.id);
      return result.fold(
        onSuccess: (_) {
          incomingRequests.removeWhere((item) => item.id == request.id);
          pendingRequestCount.value = math.max(
            0,
            pendingRequestCount.value - 1,
          );
          final friendship = Friendship.create(
            request.senderId,
            request.receiverId,
          );
          if (!friendships.any((item) => item.id == friendship.id)) {
            friendships.insert(0, friendship);
            friendCount.value = friendships.length;
          }
          AnalyticsService.instance.inviteAccepted();
          Get.snackbar(
            currentL10n.friendAddedTitle,
            currentL10n.friendAddedMessage(
              request.senderDisplayName ?? currentL10n.memberFallbackName,
            ),
            snackPosition: SnackPosition.BOTTOM,
          );
          return true;
        },
        onFailure: (failure) {
          final message = failure is AppFailure
              ? failure.message
              : currentL10n.actionFailed;
          Get.snackbar(
            currentL10n.genericErrorTitle,
            message,
            snackPosition: SnackPosition.BOTTOM,
          );
          return false;
        },
      );
    } catch (e) {
      Get.snackbar(
        currentL10n.genericErrorTitle,
        currentL10n.actionFailed,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      _requestActions.remove(request.id);
    }
  }

  /// Decline an incoming friend request.
  Future<void> declineRequest(FriendRequest request) async {
    if (isRequestBusy(request.id)) return;

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text(currentL10n.declineRequestTitle),
        content: Text(currentL10n.declineRequestMessage),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(currentL10n.cancelAction),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              currentL10n.declineRequestTitle,
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    _requestActions[request.id] = 'decline';
    try {
      final result = await _friendRepo.declineRequest(request.id);
      result.fold(
        onSuccess: (_) {
          Get.snackbar(
            currentL10n.removedSuccessfully,
            currentL10n.declineRequestTitle,
            snackPosition: SnackPosition.BOTTOM,
          );
        },
        onFailure: (failure) {
          final message = failure is AppFailure
              ? failure.message
              : currentL10n.actionFailed;
          Get.snackbar(
            currentL10n.actionFailed,
            message,
            snackPosition: SnackPosition.BOTTOM,
          );
        },
      );
    } finally {
      _requestActions.remove(request.id);
    }
  }

  /// Cancel an outgoing friend request.
  Future<void> cancelRequest(FriendRequest request) async {
    if (isRequestBusy(request.id)) return;

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text(currentL10n.cancelRequestTitle),
        content: Text(currentL10n.cancelRequestMessage),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(currentL10n.cancelAction),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              currentL10n.cancelAction,
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    _requestActions[request.id] = 'cancel';
    try {
      final result = await _friendRepo.cancelRequest(request.id);
      result.fold(
        onSuccess: (_) {
          Get.snackbar(
            currentL10n.removedSuccessfully,
            currentL10n.cancelRequestTitle,
            snackPosition: SnackPosition.BOTTOM,
          );
        },
        onFailure: (failure) {
          final message = failure is AppFailure
              ? failure.message
              : currentL10n.actionFailed;
          Get.snackbar(
            currentL10n.actionFailed,
            message,
            snackPosition: SnackPosition.BOTTOM,
          );
        },
      );
    } finally {
      _requestActions.remove(request.id);
    }
  }

  /// Remove an existing friendship.
  Future<void> removeFriend(Friendship friendship) async {
    final uid = _userId;
    if (uid == null) return;

    final result = await _friendRepo.removeFriend(friendship.id, uid);
    result.fold(
      onSuccess: (_) {
        Get.snackbar(
          currentL10n.friendRemovedTitle,
          currentL10n.friendRemovedMessage,
          snackPosition: SnackPosition.BOTTOM,
        );
      },
      onFailure: (failure) {
        Get.snackbar(
          currentL10n.genericErrorTitle,
          failure.message,
          snackPosition: SnackPosition.BOTTOM,
        );
      },
    );
  }

  /// Check if a user can add more friends (under cap).
  Future<bool> canAddMoreFriends() async {
    final uid = _userId;
    if (uid == null) return false;
    return _friendRepo.canAddFriend(uid);
  }

  Future<UserProfile?> profileFutureFor(String userId) {
    return _profileFutures.putIfAbsent(
      userId,
      () => _friendRepo.getFriendProfile(userId),
    );
  }

  Future<UserProfile?> requestProfileFutureFor(String userId) {
    return _requestProfileFutures.putIfAbsent(
      userId,
      () => _friendRepo.getRequestPreviewProfile(userId),
    );
  }

  @override
  void onClose() {
    _friendshipsSubscription?.cancel();
    super.onClose();
  }
}
