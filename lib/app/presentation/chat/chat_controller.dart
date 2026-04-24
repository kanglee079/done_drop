import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:done_drop/core/models/chat_message.dart';
import 'package:done_drop/features/auth/presentation/controllers/auth_controller.dart';
import 'package:done_drop/firebase/repositories/chat_repository.dart';
import 'package:done_drop/firebase/repositories/friend_repository.dart';
import 'package:done_drop/l10n/l10n.dart';

class ChatController extends GetxController {
  ChatController(this._chatRepository, this._friendRepository);

  static const Duration _friendshipTimeout = Duration(seconds: 6);
  static const Duration _initialMessagesTimeout = Duration(seconds: 8);

  final ChatRepository _chatRepository;
  final FriendRepository _friendRepository;

  final messages = <ChatMessage>[].obs;
  final isLoading = true.obs;
  final isSending = false.obs;
  final draft = ''.obs;
  final isNotFriend = false.obs;
  final errorMessage = RxnString();

  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  StreamSubscription<List<ChatMessage>>? _messagesSub;
  Future<void>? _bootstrapFuture;

  String? get _currentUserId => Get.find<AuthController>().firebaseUser?.uid;

  late final String buddyId;
  late final String buddyName;
  String? buddyAvatarUrl;
  late final String threadId;

  String get currentUserId => _currentUserId ?? '';

  @override
  void onInit() {
    super.onInit();
    final args = (Get.arguments as Map?) ?? const {};
    buddyId = (args['buddyId'] as String?) ?? '';
    buddyName = (args['buddyName'] as String?) ?? '';
    buddyAvatarUrl = args['buddyAvatarUrl'] as String?;
    final uid = _currentUserId ?? '';
    threadId = ChatRepository.threadIdForUsers(uid, buddyId);

    // Prevent messaging self
    if (buddyId == uid) {
      isNotFriend.value = true;
      isLoading.value = false;
      return;
    }

    // Check if buddy is a friend
    _checkFriendship(uid);

    textController.addListener(() {
      draft.value = textController.text;
    });

    _bootstrapFuture = _bootstrapConversation();
  }

  Future<bool> _checkFriendship(String uid) async {
    if (uid.isEmpty || buddyId.isEmpty) return false;
    final friends = await _friendRepository.getFriends(uid);
    return friends.any((f) => f.userId1 == buddyId || f.userId2 == buddyId);
  }

  Future<void> reloadConversation() async {
    await _bootstrapConversation(force: true);
  }

  Future<void> _bootstrapConversation({bool force = false}) async {
    if (!force && _bootstrapFuture != null) {
      return _bootstrapFuture;
    }

    final future = _runBootstrap();
    _bootstrapFuture = future;
    try {
      await future;
    } finally {
      if (identical(_bootstrapFuture, future)) {
        _bootstrapFuture = null;
      }
    }
  }

  Future<void> _runBootstrap() async {
    final uid = _currentUserId ?? '';
    errorMessage.value = null;
    isLoading.value = true;
    isNotFriend.value = false;
    messages.clear();
    await _messagesSub?.cancel();
    _messagesSub = null;

    if (uid.isEmpty || buddyId.isEmpty) {
      _failLoad(currentL10n.chatLoadFailedSubtitle);
      return;
    }

    try {
      final isFriend = await _checkFriendship(uid).timeout(_friendshipTimeout);
      if (!isFriend) {
        isNotFriend.value = true;
        isLoading.value = false;
        return;
      }

      await _chatRepository.ensureThread(
        threadId: threadId,
        participantIds: [uid, buddyId],
      );

      final firstSnapshot = Completer<void>();
      _messagesSub = _chatRepository
          .watchMessages(threadId)
          .listen(
            (items) {
              messages.assignAll(items);
              errorMessage.value = null;
              isLoading.value = false;
              if (!firstSnapshot.isCompleted) {
                firstSnapshot.complete();
              }
              _scrollToBottom();
            },
            onError: (error, _) {
              _failLoad(currentL10n.chatLoadFailedSubtitle);
              if (!firstSnapshot.isCompleted) {
                firstSnapshot.completeError(error);
              }
            },
          );

      await firstSnapshot.future.timeout(_initialMessagesTimeout);
    } on TimeoutException {
      _failLoad(currentL10n.chatConnectionTimeoutMessage);
    } catch (_) {
      _failLoad(currentL10n.chatLoadFailedSubtitle);
    }
  }

  void _failLoad(String message) {
    errorMessage.value = message;
    isLoading.value = false;
  }

  @override
  void onClose() {
    _messagesSub?.cancel();
    textController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  bool get canSend =>
      draft.value.trim().isNotEmpty &&
      !isSending.value &&
      !isNotFriend.value &&
      !isLoading.value &&
      errorMessage.value == null;

  Future<void> sendCurrentMessage() async {
    if (isNotFriend.value) return;
    final text = textController.text.trim();
    if (text.isEmpty || isSending.value) return;

    isSending.value = true;
    try {
      await _chatRepository.sendTextMessage(
        threadId: threadId,
        senderId: currentUserId,
        participantIds: [currentUserId, buddyId],
        text: text,
      );
      textController.clear();
      _scrollToBottom();
    } catch (_) {
      Get.snackbar(
        currentL10n.genericErrorTitle,
        currentL10n.chatSendFailedMessage,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSending.value = false;
    }
  }

  String formatTimestamp(DateTime dateTime) {
    final now = DateTime.now();
    final sameDay =
        now.year == dateTime.year &&
        now.month == dateTime.month &&
        now.day == dateTime.day;
    return sameDay
        ? DateFormat.Hm().format(dateTime)
        : DateFormat('dd/MM HH:mm').format(dateTime);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;
      scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    });
  }
}
