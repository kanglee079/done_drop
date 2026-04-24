import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:done_drop/core/models/friendship.dart';
import 'package:done_drop/core/errors/failures.dart';
import 'package:done_drop/features/auth/presentation/controllers/auth_controller.dart';
import 'package:done_drop/firebase/repositories/friend_repository.dart';
import 'package:done_drop/core/models/user_profile.dart';
import 'package:done_drop/core/errors/result.dart';
import 'package:done_drop/core/services/analytics_service.dart';
import 'package:done_drop/core/services/storage_service.dart';
import 'package:done_drop/l10n/l10n.dart';

/// Controller for Add Friend screen.
class AddFriendController extends GetxController {
  AddFriendController(this._friendRepo);
  final FriendRepository _friendRepo;
  static const Duration _operationTimeout = Duration(seconds: 10);
  String? _handledPrefillCode;
  String? _handledPrefillUid;
  bool _shouldAutoSendPrefill = false;
  StreamSubscription<List<Friendship>>? _friendshipsSubscription;

  final searchController = TextEditingController();

  final isSearching = false.obs;
  final isSendingRequest = false.obs;
  final RxnString errorMessage = RxnString();
  final Rx<UserProfile?> foundUser = Rx<UserProfile?>(null);
  final RxBool requestSent = false.obs;
  final RxBool isAtCap = false.obs;

  String? get _currentUserId => Get.find<AuthController>().firebaseUser?.uid;
  String? get _currentUserName =>
      Get.find<AuthController>().firebaseUser?.displayName;
  String? get _currentUserPhoto =>
      Get.find<AuthController>().firebaseUser?.photoURL;

  int get maxFriends => FriendRepository.maxFriendsFree;

  @override
  void onInit() {
    super.onInit();
    _checkCap();
    _watchFriendCap();
  }

  @override
  void onReady() {
    super.onReady();
    final args = Get.arguments as Map<String, dynamic>?;
    applyNavigationPrefill(
      prefillCode: args?['prefillCode'] as String?,
      prefillUid: args?['prefillUid'] as String?,
      prefillName: args?['prefillName'] as String?,
      autoSend: args?['autoSend'] == true,
    );
  }

  @visibleForTesting
  Future<void> applyNavigationPrefill({
    String? prefillCode,
    String? prefillUid,
    String? prefillName,
    bool autoSend = false,
  }) async {
    _shouldAutoSendPrefill = autoSend;

    if (prefillCode != null && prefillCode.isNotEmpty) {
      await applyPrefillCode(
        prefillCode,
        fallbackUid: prefillUid,
        fallbackDisplayName: prefillName,
      );
      return;
    }

    if (prefillUid != null && prefillUid.isNotEmpty) {
      await applyPrefillUid(prefillUid, displayName: prefillName);
    }
  }

  Future<void> _checkCap() async {
    final uid = _currentUserId;
    if (uid == null) return;
    isAtCap.value = !(await _friendRepo.canAddFriend(uid));
  }

  void _watchFriendCap() {
    final uid = _currentUserId;
    if (uid == null) return;

    _friendshipsSubscription?.cancel();
    _friendshipsSubscription = _friendRepo.watchFriendships(uid).listen((
      friendships,
    ) {
      if (StorageService.instance.isPremium) {
        isAtCap.value = false;
        return;
      }
      _checkCap();
    }, onError: (_) => _checkCap());
  }

  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return currentL10n.enterUsernameError;
    }
    if (value.length < 3) {
      return currentL10n.usernameTooShort;
    }
    return null;
  }

  /// Search by username.
  Future<void> searchByUsername() async {
    final username = searchController.text.trim();
    if (username.isEmpty) return;

    await _searchUser(() async {
      return await _friendRepo.findUserByUsername(username);
    });
  }

  /// Search by user code (from QR).
  Future<void> searchByCode(String code) async {
    final raw = code.trim();
    if (_looksLikeUid(raw)) {
      await _findUserById(raw);
      return;
    }

    final normalizedCode = normalizeUserCode(code);
    if (normalizedCode.isEmpty || isSearching.value || isSendingRequest.value) {
      return;
    }

    isSearching.value = true;
    errorMessage.value = null;
    foundUser.value = null;
    requestSent.value = false;

    try {
      final result = await _awaitResult(
        _friendRepo.findUserByCode(normalizedCode),
        timeoutCode: 'buddy_search_timeout',
        timeoutMessage: 'Buddy search timed out.',
      );

      result.fold(
        onSuccess: (user) {
          if (user.id == _currentUserId) {
            errorMessage.value = currentL10n.ownAccountSearchError;
            return;
          }
          foundUser.value = user;
        },
        onFailure: (failure) {
          errorMessage.value = _messageForFailure(failure);
        },
      );
    } finally {
      isSearching.value = false;
    }
  }

  String normalizeUserCode(String value) {
    return value.replaceAll(RegExp(r'[^A-Za-z0-9]'), '').toUpperCase().trim();
  }

  bool _looksLikeUid(String value) {
    final trimmed = value.trim();
    return RegExp(r'^[A-Za-z0-9]{20,}$').hasMatch(trimmed);
  }

  Future<void> applyPrefillCode(
    String code, {
    String? fallbackUid,
    String? fallbackDisplayName,
  }) async {
    final normalizedCode = normalizeUserCode(code);
    if (normalizedCode.isEmpty || normalizedCode == _handledPrefillCode) {
      return;
    }
    _handledPrefillCode = normalizedCode;
    searchController.text = normalizedCode;
    await searchByCode(normalizedCode);
    if (foundUser.value == null &&
        fallbackUid != null &&
        fallbackUid.trim().isNotEmpty) {
      await applyPrefillUid(fallbackUid, displayName: fallbackDisplayName);
      return;
    }
    await _sendPrefilledRequestIfNeeded();
  }

  Future<void> applyPrefillUid(String uid, {String? displayName}) async {
    final trimmedUid = uid.trim();
    if (trimmedUid.isEmpty || trimmedUid == _handledPrefillUid) {
      return;
    }

    _handledPrefillUid = trimmedUid;
    searchController.text = trimmedUid;
    await _findUserById(trimmedUid, fallbackDisplayName: displayName);
    await _sendPrefilledRequestIfNeeded();
  }

  /// Search by email.
  Future<void> searchByEmail() async {
    final email = searchController.text.trim();
    if (email.isEmpty) return;

    await _searchUser(() async {
      return await _friendRepo.findUserByEmail(email);
    });
  }

  Future<void> _searchUser(
    Future<Result<UserProfile>> Function() searchFn,
  ) async {
    if (isSearching.value || isSendingRequest.value) return;

    isSearching.value = true;
    errorMessage.value = null;
    foundUser.value = null;
    requestSent.value = false;

    try {
      final result = await _awaitResult(
        searchFn(),
        timeoutCode: 'buddy_search_timeout',
        timeoutMessage: 'Buddy search timed out.',
      );

      result.fold(
        onSuccess: (user) {
          if (user.id == _currentUserId) {
            errorMessage.value = currentL10n.ownAccountSearchError;
            return;
          }
          foundUser.value = user;
        },
        onFailure: (failure) {
          errorMessage.value = _messageForFailure(failure);
        },
      );
    } finally {
      isSearching.value = false;
    }
  }

  Future<void> _findUserById(
    String userId, {
    String? fallbackDisplayName,
  }) async {
    final trimmedUserId = userId.trim();
    if (trimmedUserId.isEmpty || isSearching.value || isSendingRequest.value) {
      return;
    }

    isSearching.value = true;
    errorMessage.value = null;
    foundUser.value = null;
    requestSent.value = false;

    try {
      final result = await _awaitResult(
        _friendRepo.findUserById(trimmedUserId),
        timeoutCode: 'buddy_search_timeout',
        timeoutMessage: 'Buddy search timed out.',
      );

      result.fold(
        onSuccess: (user) {
          if (user.id == _currentUserId) {
            errorMessage.value = currentL10n.ownAccountSearchError;
            return;
          }

          final fallbackName = fallbackDisplayName?.trim();
          foundUser.value =
              user.displayName.trim().isEmpty &&
                  fallbackName != null &&
                  fallbackName.isNotEmpty
              ? user.copyWith(displayName: fallbackName)
              : user;
        },
        onFailure: (failure) {
          errorMessage.value = _messageForFailure(failure);
        },
      );
    } finally {
      isSearching.value = false;
    }
  }

  Future<void> sendRequest() async {
    final user = foundUser.value;
    if (user == null || isSearching.value || isSendingRequest.value) return;

    // Final cap check on sender side
    final uid = _currentUserId;
    if (uid == null) return;

    isSendingRequest.value = true;
    errorMessage.value = null;

    try {
      final canAdd = await Future<bool>(
        () => _friendRepo.canAddFriend(uid),
      ).timeout(_operationTimeout);
      if (!canAdd) {
        errorMessage.value = currentL10n.friendCapReachedError(maxFriends);
        return;
      }

      final result = await _awaitResult(
        _friendRepo.sendFriendRequest(
          senderId: _currentUserId!,
          receiverId: user.id,
          senderDisplayName: _currentUserName ?? currentL10n.memberFallbackName,
          senderAvatarUrl: _currentUserPhoto,
        ),
        timeoutCode: 'buddy_request_timeout',
        timeoutMessage: 'Buddy request timed out.',
      );

      result.fold(
        onSuccess: (_) {
          requestSent.value = true;
          AnalyticsService.instance.inviteSent();
          Get.snackbar(
            currentL10n.requestSentTitle,
            currentL10n.requestSentMessage(user.displayName),
            snackPosition: SnackPosition.BOTTOM,
          );
          _checkCap();
        },
        onFailure: (failure) {
          errorMessage.value = _messageForFailure(
            failure,
            fallback: currentL10n.buddyRequestGenericError,
          );
        },
      );
    } on TimeoutException {
      errorMessage.value = currentL10n.buddyRequestTimeoutError;
    } finally {
      isSendingRequest.value = false;
    }
  }

  Future<void> _sendPrefilledRequestIfNeeded() async {
    if (!_shouldAutoSendPrefill) return;
    if (foundUser.value == null ||
        requestSent.value ||
        isSearching.value ||
        isSendingRequest.value ||
        errorMessage.value != null) {
      return;
    }
    await sendRequest();
  }

  String _messageForFailure(dynamic failure, {String? fallback}) {
    final resolvedFallback = fallback ?? currentL10n.buddySearchGenericError;

    if (failure is AppFailure) {
      switch (failure.code) {
        case 'friend_code_not_found':
        case 'friend_id_not_found':
          return currentL10n.buddySearchIdNotFoundError;
        case 'friend_email_not_found':
          return currentL10n.buddySearchEmailNotFoundError;
        case 'friend_username_not_found':
          return currentL10n.buddySearchUsernameNotFoundError;
        case 'friend_request_self':
          return currentL10n.ownAccountSearchError;
        case 'friend_request_user_not_found':
          return currentL10n.buddySearchIdNotFoundError;
        case 'friend_cap_reached':
          return currentL10n.friendCapReachedError(maxFriends);
        case 'friend_request_already_friends':
          return currentL10n.alreadyBuddyError;
        case 'friend_request_exists':
          return currentL10n.buddyRequestAlreadySentError;
        case 'buddy_search_timeout':
          return currentL10n.buddySearchTimeoutError;
        case 'buddy_request_timeout':
          return currentL10n.buddyRequestTimeoutError;
        case 'friend_request_permission_denied':
        case 'friend_request_unexpected':
          return currentL10n.buddyRequestGenericError;
      }

      if (failure.message.trim().isNotEmpty) {
        return failure.message;
      }
    }

    return resolvedFallback;
  }

  Future<Result<T>> _awaitResult<T>(
    Future<Result<T>> future, {
    required String timeoutCode,
    required String timeoutMessage,
  }) async {
    return future.timeout(
      _operationTimeout,
      onTimeout: () =>
          Result.failure(AppFailure.network(timeoutMessage, timeoutCode)),
    );
  }

  void reset() {
    searchController.clear();
    foundUser.value = null;
    requestSent.value = false;
    errorMessage.value = null;
    isSearching.value = false;
    isSendingRequest.value = false;
    _handledPrefillCode = null;
    _handledPrefillUid = null;
    _shouldAutoSendPrefill = false;
  }

  @override
  void onClose() {
    _friendshipsSubscription?.cancel();
    searchController.dispose();
    super.onClose();
  }
}
