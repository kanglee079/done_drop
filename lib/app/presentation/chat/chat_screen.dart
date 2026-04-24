import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:done_drop/app/core/widgets/widgets.dart';
import 'package:done_drop/app/presentation/chat/chat_controller.dart';
import 'package:done_drop/core/theme/theme.dart';
import 'package:done_drop/l10n/l10n.dart';

class ChatScreen extends GetView<ChatController> {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DismissKeyboard(
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          backgroundColor: AppColors.surface.withValues(alpha: 0.92),
          surfaceTintColor: Colors.transparent,
          titleSpacing: 0,
          title: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primaryFixed,
                backgroundImage: controller.buddyAvatarUrl != null
                    ? NetworkImage(controller.buddyAvatarUrl!)
                    : null,
                child: controller.buddyAvatarUrl == null
                    ? Text(
                        _initialFor(
                          controller.buddyName.isEmpty
                              ? context.l10n.memberFallbackName
                              : controller.buddyName,
                        ),
                        style: AppTypography.labelLarge(
                          color: AppColors.primary,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: AppSizes.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      controller.buddyName.isEmpty
                          ? context.l10n.memberFallbackName
                          : controller.buddyName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.titleMedium(
                        color: AppColors.onSurface,
                      ),
                    ),
                    Text(
                      context.l10n.chatScreenSubtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySmall(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.space24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 36,
                            height: 36,
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: AppSizes.space16),
                          Text(
                            context.l10n.chatConnectingTitle,
                            textAlign: TextAlign.center,
                            style: AppTypography.headlineSmall(
                              color: AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(height: AppSizes.space8),
                          Text(
                            context.l10n.chatConnectingSubtitle,
                            textAlign: TextAlign.center,
                            style: AppTypography.bodyMedium(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (controller.errorMessage.value != null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.space24),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 360),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSizes.space20),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLowest,
                            borderRadius: AppSizes.borderRadiusLg,
                            border: Border.all(color: AppColors.outlineVariant),
                            boxShadow: AppColors.cardShadow,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: AppColors.errorContainer,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  color: AppColors.error,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(height: AppSizes.space16),
                              Text(
                                context.l10n.chatLoadFailedTitle,
                                textAlign: TextAlign.center,
                                style: AppTypography.headlineSmall(
                                  color: AppColors.onSurface,
                                ),
                              ),
                              const SizedBox(height: AppSizes.space8),
                              Text(
                                controller.errorMessage.value!,
                                textAlign: TextAlign.center,
                                style: AppTypography.bodyMedium(
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: AppSizes.space20),
                              FilledButton.icon(
                                onPressed: controller.reloadConversation,
                                icon: const Icon(Icons.refresh_rounded),
                                label: Text(context.l10n.retryAction),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }

                if (controller.isNotFriend.value) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.space24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: AppColors.errorContainer,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Icon(
                              Icons.person_off_outlined,
                              color: AppColors.error,
                              size: 30,
                            ),
                          ),
                          const SizedBox(height: AppSizes.space16),
                          Text(
                            context.l10n.onlyFriendsCanChatError,
                            textAlign: TextAlign.center,
                            style: AppTypography.headlineSmall(
                              color: AppColors.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (controller.messages.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.space24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: AppColors.primaryFixed,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: const Icon(
                              Icons.chat_bubble_outline_rounded,
                              color: AppColors.primary,
                              size: 30,
                            ),
                          ),
                          const SizedBox(height: AppSizes.space16),
                          Text(
                            context.l10n.chatEmptyTitle,
                            textAlign: TextAlign.center,
                            style: AppTypography.headlineSmall(
                              color: AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(height: AppSizes.space8),
                          Text(
                            context.l10n.chatEmptySubtitle,
                            textAlign: TextAlign.center,
                            style: AppTypography.bodyMedium(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final messages = controller.messages;
                return ListView.builder(
                  controller: controller.scrollController,
                  reverse: true,
                  padding: const EdgeInsets.fromLTRB(
                    AppSizes.space16,
                    AppSizes.space16,
                    AppSizes.space16,
                    AppSizes.space12,
                  ),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[messages.length - 1 - index];
                    final isMine = message.senderId == controller.currentUserId;
                    return _ChatBubble(
                      text: message.text,
                      timestamp: controller.formatTimestamp(message.createdAt),
                      isMine: isMine,
                    );
                  },
                );
              }),
            ),
            SafeArea(
              top: false,
              child: Obx(
                () => Container(
                  padding: const EdgeInsets.fromLTRB(
                    AppSizes.space12,
                    AppSizes.space10,
                    AppSizes.space12,
                    AppSizes.space12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    border: Border(
                      top: BorderSide(color: AppColors.outlineVariant),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller.textController,
                          enabled:
                              !controller.isLoading.value &&
                              controller.errorMessage.value == null &&
                              !controller.isNotFriend.value,
                          minLines: 1,
                          maxLines: 4,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration(
                            hintText: controller.isLoading.value
                                ? context.l10n.chatConnectingSubtitle
                                : controller.errorMessage.value != null
                                ? context.l10n.chatLoadFailedSubtitle
                                : context.l10n.chatInputHint,
                            filled: true,
                            fillColor: AppColors.surface,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.space12,
                              vertical: AppSizes.space12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide(
                                color: AppColors.outlineVariant,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide(
                                color: AppColors.outlineVariant,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: const BorderSide(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          onSubmitted: (_) => controller.sendCurrentMessage(),
                        ),
                      ),
                      const SizedBox(width: AppSizes.space10),
                      SizedBox(
                        height: 48,
                        child: FilledButton(
                          onPressed: controller.canSend
                              ? controller.sendCurrentMessage
                              : null,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.space16,
                            ),
                          ),
                          child: controller.isSending.value
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.onPrimary,
                                  ),
                                )
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.send_rounded, size: 18),
                                    const SizedBox(width: 6),
                                    Text(context.l10n.chatSendAction),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _initialFor(String value) {
  if (value.isEmpty) return '?';
  return value.trim().characters.first.toUpperCase();
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({
    required this.text,
    required this.timestamp,
    required this.isMine,
  });

  final String text;
  final String timestamp;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final alignment = isMine ? Alignment.centerRight : Alignment.centerLeft;
    final bubbleColor = isMine
        ? AppColors.primary
        : AppColors.surfaceContainerHigh;
    final textColor = isMine ? AppColors.onPrimary : AppColors.onSurface;
    final timeColor = isMine
        ? AppColors.onPrimary.withValues(alpha: 0.82)
        : AppColors.onSurfaceVariant;

    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 280),
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSizes.space10),
          padding: const EdgeInsets.fromLTRB(
            AppSizes.space12,
            AppSizes.space12,
            AppSizes.space12,
            AppSizes.space10,
          ),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(text, style: AppTypography.bodyMedium(color: textColor)),
              const SizedBox(height: AppSizes.space6),
              Text(timestamp, style: AppTypography.bodySmall(color: timeColor)),
            ],
          ),
        ),
      ),
    );
  }
}
