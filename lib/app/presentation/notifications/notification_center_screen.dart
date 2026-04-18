import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:done_drop/core/models/feed_delivery.dart';
import 'package:done_drop/core/models/friend_request.dart';
import 'package:done_drop/core/theme/theme.dart';
import 'package:done_drop/l10n/l10n.dart';

import 'notification_center_controller.dart';

class NotificationCenterScreen extends StatelessWidget {
  const NotificationCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NotificationCenterController>();
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(l10n.notificationSettingsTitle),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSizes.space12),
            child: IconButton(
              onPressed: controller.openSettings,
              icon: const Icon(
                Icons.settings_outlined,
                color: AppColors.primary,
              ),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.surfaceContainerLowest,
                shape: RoundedRectangleBorder(
                  borderRadius: AppSizes.borderRadiusMd,
                ),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshPermissionState,
        child: Obx(() {
          final requests = controller.incomingRequests.toList(growable: false);
          final deliveries = controller.unreadDeliveries.toList(
            growable: false,
          );
          final hasItems = requests.isNotEmpty || deliveries.isNotEmpty;

          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              AppSizes.space20,
              AppSizes.space8,
              AppSizes.space20,
              AppSizes.space32,
            ),
            children: [
              _ReminderStatusCard(controller: controller),
              const SizedBox(height: AppSizes.space20),
              if (requests.isNotEmpty) ...[
                _NotificationSectionHeader(
                  title: l10n.requestsTabLabel,
                  count: controller.pendingRequestCount.value,
                ),
                const SizedBox(height: AppSizes.space12),
                ...requests.map(
                  (request) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.space12),
                    child: _RequestNotificationTile(
                      request: request,
                      onTap: controller.openFriendRequests,
                      subtitle: controller.requestSubtitle(request),
                    ),
                  ),
                ),
              ],
              if (requests.isNotEmpty && deliveries.isNotEmpty)
                const SizedBox(height: AppSizes.space12),
              if (deliveries.isNotEmpty) ...[
                _NotificationSectionHeader(
                  title: l10n.buddyTabTitle,
                  count: controller.unreadBuddyCount.value,
                ),
                const SizedBox(height: AppSizes.space12),
                ...deliveries.map(
                  (delivery) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.space12),
                    child: _BuddyNotificationTile(
                      delivery: delivery,
                      subtitle: controller.buddySubtitle(delivery),
                      onTap: () => controller.openBuddyUpdate(delivery),
                    ),
                  ),
                ),
              ],
              if (!hasItems)
                _EmptyNotificationsState(
                  title: l10n.notificationCenterEmptyTitle,
                  subtitle: l10n.notificationCenterEmptySubtitle,
                ),
            ],
          );
        }),
      ),
    );
  }
}

class _ReminderStatusCard extends StatelessWidget {
  const _ReminderStatusCard({required this.controller});

  final NotificationCenterController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final needsPermission = !controller.notificationsEnabled.value;
    final needsExactAlarm = !controller.exactAlarmEnabled.value;
    final buttonLabel = needsPermission || needsExactAlarm
        ? l10n.requestNotificationPermissionAction
        : l10n.notificationSettingsTitle;

    final subtitle = needsPermission
        ? l10n.notificationPermissionOffSubtitle
        : needsExactAlarm
        ? l10n.notificationExactAlarmOffSubtitle
        : l10n.habitRemindersSubtitle(controller.scheduledReminderCount.value);

    return Container(
      padding: const EdgeInsets.all(AppSizes.space16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppSizes.borderRadiusLg,
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primaryFixed,
                  borderRadius: AppSizes.borderRadiusMd,
                ),
                child: const Icon(
                  Icons.notifications_active_outlined,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSizes.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.habitRemindersTitle,
                      style: AppTypography.labelLarge(
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppSizes.space2),
                    Text(
                      subtitle,
                      style: AppTypography.bodySmall(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.space16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonalIcon(
              onPressed: needsPermission || needsExactAlarm
                  ? controller.requestPermissions
                  : controller.openSettings,
              icon: Icon(
                needsPermission || needsExactAlarm
                    ? Icons.notifications_outlined
                    : Icons.settings_outlined,
              ),
              label: Text(buttonLabel),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationSectionHeader extends StatelessWidget {
  const _NotificationSectionHeader({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTypography.titleMedium(color: AppColors.onSurface),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.space8,
            vertical: AppSizes.space4,
          ),
          decoration: BoxDecoration(
            color: AppColors.primaryFixed,
            borderRadius: AppSizes.borderRadiusFull,
          ),
          child: Text(
            '$count',
            style: AppTypography.labelMedium(color: AppColors.primary),
          ),
        ),
      ],
    );
  }
}

class _RequestNotificationTile extends StatelessWidget {
  const _RequestNotificationTile({
    required this.request,
    required this.subtitle,
    required this.onTap,
  });

  final FriendRequest request;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final name = request.senderDisplayName ?? context.l10n.memberFallbackName;
    return _NotificationCard(
      leading: CircleAvatar(
        radius: 22,
        backgroundColor: AppColors.primaryFixed,
        backgroundImage: request.senderAvatarUrl != null
            ? NetworkImage(request.senderAvatarUrl!)
            : null,
        child: request.senderAvatarUrl == null
            ? Text(
                name.characters.first.toUpperCase(),
                style: AppTypography.labelLarge(color: AppColors.primary),
              )
            : null,
      ),
      title: name,
      subtitle: subtitle,
      timeLabel: _relativeTime(context, request.createdAt),
      onTap: onTap,
    );
  }
}

class _BuddyNotificationTile extends StatelessWidget {
  const _BuddyNotificationTile({
    required this.delivery,
    required this.subtitle,
    required this.onTap,
  });

  final FeedDelivery delivery;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _NotificationCard(
      leading: CircleAvatar(
        radius: 22,
        backgroundColor: AppColors.primaryFixed,
        backgroundImage: delivery.ownerAvatarUrl != null
            ? NetworkImage(delivery.ownerAvatarUrl!)
            : null,
        child: delivery.ownerAvatarUrl == null
            ? Text(
                delivery.ownerDisplayName.characters.first.toUpperCase(),
                style: AppTypography.labelLarge(color: AppColors.primary),
              )
            : null,
      ),
      title: delivery.ownerDisplayName,
      subtitle: subtitle,
      timeLabel: _relativeTime(context, delivery.createdAt),
      onTap: onTap,
      trailing: delivery.previewUrl.isEmpty
          ? null
          : ClipRRect(
              borderRadius: AppSizes.borderRadiusMd,
              child: Image.network(
                delivery.previewUrl,
                width: 52,
                height: 52,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 52,
                  height: 52,
                  color: AppColors.surfaceContainerLow,
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.image_not_supported_outlined,
                    color: AppColors.outline,
                  ),
                ),
              ),
            ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.timeLabel,
    required this.onTap,
    this.trailing,
  });

  final Widget leading;
  final String title;
  final String subtitle;
  final String timeLabel;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppSizes.borderRadiusLg,
        child: Ink(
          padding: const EdgeInsets.all(AppSizes.space16),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: AppSizes.borderRadiusLg,
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: Row(
            children: [
              leading,
              const SizedBox(width: AppSizes.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.labelLarge(
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppSizes.space4),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySmall(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSizes.space6),
                    Text(
                      timeLabel,
                      style: AppTypography.bodySmall(color: AppColors.outline),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSizes.space12),
              trailing ??
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: AppColors.outline,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyNotificationsState extends StatelessWidget {
  const _EmptyNotificationsState({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: AppSizes.space8),
      padding: const EdgeInsets.all(AppSizes.space24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppSizes.borderRadiusLg,
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primaryFixed,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: AppColors.primary,
              size: 30,
            ),
          ),
          const SizedBox(height: AppSizes.space16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTypography.titleMedium(color: AppColors.onSurface),
          ),
          const SizedBox(height: AppSizes.space8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

String _relativeTime(BuildContext context, DateTime createdAt) {
  final difference = DateTime.now().difference(createdAt);
  final l10n = context.l10n;
  if (difference.inMinutes < 1) return l10n.timeJustNow;
  if (difference.inHours < 1) return l10n.timeMinutesAgo(difference.inMinutes);
  if (difference.inDays < 1) return l10n.timeHoursAgo(difference.inHours);
  return DateFormat(
    'MMM d',
    resolveSupportedLocale(null).languageCode,
  ).format(createdAt);
}
