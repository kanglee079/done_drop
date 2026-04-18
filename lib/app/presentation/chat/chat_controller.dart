import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:done_drop/core/models/chat_message.dart';
import 'package:done_drop/features/auth/presentation/controllers/auth_controller.dart';
import 'package:done_drop/firebase/repositories/chat_repository.dart';

class ChatController extends GetxController {
  ChatController(this._chatRepository);

  final ChatRepository _chatRepository;

  final messages = <ChatMessage>[].obs;
  final isLoading = true.obs;
  final isSending = false.obs;
  final draft = ''.obs;

  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  StreamSubscription<List<ChatMessage>>? _messagesSub;

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

    textController.addListener(() {
      draft.value = textController.text;
    });

    _messagesSub = _chatRepository.watchMessages(threadId).listen((items) {
      messages.assignAll(items);
      isLoading.value = false;
      _scrollToBottom();
    });
  }

  @override
  void onClose() {
    _messagesSub?.cancel();
    textController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  bool get canSend => draft.value.trim().isNotEmpty && !isSending.value;

  Future<void> sendCurrentMessage() async {
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
