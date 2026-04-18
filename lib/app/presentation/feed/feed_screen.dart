import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:done_drop/core/theme/theme.dart';
import 'package:done_drop/app/core/widgets/widgets.dart';
import 'package:done_drop/app/presentation/feed/feed_controller.dart';
import 'package:done_drop/app/presentation/feed/reaction_controller.dart';
import 'package:done_drop/app/routes/app_routes.dart';
import 'package:done_drop/core/models/moment.dart';
import 'package:done_drop/l10n/l10n.dart';

/// DoneDrop Feed Screen — Private friend feed view
class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return GetBuilder<FeedController>(
      init: FeedController(),
      builder: (ctrl) {
        return Scaffold(
          backgroundColor: AppColors.surface,
          appBar: AppBar(
            backgroundColor: AppColors.surface.withValues(alpha: 0.85),
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: CircleAvatar(
                backgroundColor: AppColors.surfaceContainerHigh,
                child: const Icon(Icons.person, color: AppColors.primary),
              ),
            ),
            title: Text(
              l10n.friendFeedTitle,
              style: TextStyle(
                fontFamily: AppTypography.serifFamily,
                fontSize: 20,
                fontStyle: FontStyle.italic,
                color: AppColors.primary,
              ),
            ),
            centerTitle: true,
            actions: [
              Obx(
                () => ctrl.unreadCount.value > 0
                    ? IconButton(
                        icon: const Icon(
                          Icons.done_all,
                          color: AppColors.primary,
                        ),
                        onPressed: ctrl.markAllRead,
                        tooltip: l10n.markAllReadTooltip,
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
          body: Obx(() {
            if (ctrl.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }
            if (ctrl.moments.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 56,
                      color: AppColors.outlineVariant,
                    ),
                    const SizedBox(height: AppSizes.space16),
                    Text(
                      l10n.feedEmptyTitle,
                      style: TextStyle(
                        fontFamily: AppTypography.serifFamily,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.feedEmptySubtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSizes.space24),
                    DDSecondaryButton(
                      label: l10n.addFriendsAction,
                      icon: Icons.person_add,
                      onPressed: () => Get.toNamed(AppRoutes.friends),
                      isExpanded: false,
                    ),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.space12),
              itemCount: ctrl.moments.length,
              itemBuilder: (ctx, i) {
                final moment = ctrl.moments[i];
                final ownerName = ctrl.getOwnerName(moment);
                final ownerAvatar = ctrl.getOwnerAvatar(moment);
                return _MomentTile(
                  moment: moment,
                  ownerName: ownerName,
                  ownerAvatar: ownerAvatar,
                );
              },
            );
          }),
        );
      },
    );
  }
}

class _MomentTile extends StatelessWidget {
  const _MomentTile({
    required this.moment,
    required this.ownerName,
    required this.ownerAvatar,
  });

  final Moment moment;
  final String ownerName;
  final String? ownerAvatar;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final reactionCtrl = Get.find<ReactionController>();

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSizes.space16,
        vertical: AppSizes.space8,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: AppSizes.borderRadiusLg,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Owner header
          Container(
            padding: const EdgeInsets.all(AppSizes.space12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primaryFixed,
                  backgroundImage: ownerAvatar != null
                      ? NetworkImage(ownerAvatar!)
                      : null,
                  child: ownerAvatar == null
                      ? Icon(Icons.person, size: 16, color: AppColors.primary)
                      : null,
                ),
                const SizedBox(width: AppSizes.space8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ownerName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                      ),
                      Text(
                        _timeAgo(moment.createdAt),
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                // Visibility badge
                _VisibilityBadge(visibility: moment.visibility),
              ],
            ),
          ),

          // Image
          AspectRatio(
            aspectRatio: 1,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (moment.localPreviewPath != null &&
                    moment.localPreviewPath!.isNotEmpty)
                  Image.file(File(moment.localPreviewPath!), fit: BoxFit.cover)
                else
                  CachedNetworkImage(
                    imageUrl: moment.media.bestThumbnailUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        Container(color: AppColors.surfaceContainerHighest),
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.surfaceContainerHighest,
                      child: const Icon(
                        Icons.broken_image,
                        color: AppColors.outline,
                      ),
                    ),
                  ),
                if (moment.isPendingSync)
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 12,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: moment.syncStatus == MomentSyncStatus.queued
                            ? null
                            : moment.uploadProgress.clamp(0, 1),
                        minHeight: 6,
                        backgroundColor: Colors.white.withValues(alpha: 0.28),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.onPrimary,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(AppSizes.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (moment.caption.isNotEmpty) ...[
                  Text(
                    moment.caption,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.onSurface,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: AppSizes.space12),
                ],
                if (moment.isPendingSync) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      switch (moment.syncStatus) {
                        MomentSyncStatus.queued => l10n.statusQueued,
                        MomentSyncStatus.processing => l10n.statusPreparing,
                        MomentSyncStatus.uploading =>
                          l10n.statusUploading(
                            (moment.uploadProgress * 100).round(),
                          ),
                        MomentSyncStatus.finalizing => l10n.statusSyncing,
                        MomentSyncStatus.failed => l10n.statusFailed,
                        MomentSyncStatus.synced => l10n.statusPosted,
                      },
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.space12),
                ],
                // Reaction bar
                Row(
                  children: [
                    ...reactionCtrl.reactionTypes.map(
                      (type) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => reactionCtrl.toggleReaction(
                            momentId: moment.id,
                            reactionType: type,
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerHighest,
                              borderRadius: AppSizes.borderRadiusFull,
                            ),
                            child: Text(
                              reactionCtrl.reactionIcon(type),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (moment.category != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          moment.category!,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    final l10n = currentL10n;
    if (diff.inMinutes < 1) return l10n.timeJustNow;
    if (diff.inMinutes < 60) return l10n.timeMinutesAgo(diff.inMinutes);
    if (diff.inHours < 24) return l10n.timeHoursAgo(diff.inHours);
    if (diff.inDays < 7) return l10n.timeDaysAgo(diff.inDays);
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

class _VisibilityBadge extends StatelessWidget {
  const _VisibilityBadge({required this.visibility});

  final String visibility;

  @override
  Widget build(BuildContext context) {
    final (icon, label) = switch (visibility) {
      'all_friends' => (Icons.people, context.l10n.visibilityFriends),
      'selected_friends' => (Icons.group, context.l10n.visibilitySelected),
      _ => (Icons.lock_outline, context.l10n.visibilityPersonal),
    };

    return Row(
      children: [
        Icon(icon, size: 12, color: AppColors.outline),
        const SizedBox(width: 2),
        Text(label, style: TextStyle(fontSize: 10, color: AppColors.outline)),
      ],
    );
  }
}
