import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:done_drop/core/theme/theme.dart';
import 'package:done_drop/app/core/widgets/widgets.dart';
import 'package:done_drop/app/presentation/feed/feed_controller.dart';
import 'package:done_drop/app/presentation/feed/reaction_controller.dart';
import 'package:done_drop/app/routes/app_routes.dart';
import 'package:done_drop/firebase/repositories/activity_repository.dart';

/// DoneDrop Feed Screen — Private friend feed view
class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FeedController>(
      init: FeedController(Get.find<ActivityRepository>()),
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
              'Friend Feed',
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
                        tooltip: 'Mark all as read',
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
                      'No moments yet',
                      style: TextStyle(
                        fontFamily: AppTypography.serifFamily,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Moments shared by your friends\nwill appear here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSizes.space24),
                    DDSecondaryButton(
                      label: 'Add Friends',
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
                final ownerName = ctrl.getOwnerName(moment.ownerId);
                final ownerAvatar = ctrl.getOwnerAvatar(moment.ownerId);
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

  final dynamic moment;
  final String ownerName;
  final String? ownerAvatar;

  @override
  Widget build(BuildContext context) {
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
            child: CachedNetworkImage(
              imageUrl: moment.media.thumbnail.downloadUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) =>
                  Container(color: AppColors.surfaceContainerHighest),
              errorWidget: (_, __, ___) => Container(
                color: AppColors.surfaceContainerHighest,
                child: const Icon(Icons.broken_image, color: AppColors.outline),
              ),
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
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

class _VisibilityBadge extends StatelessWidget {
  const _VisibilityBadge({required this.visibility});

  final String visibility;

  @override
  Widget build(BuildContext context) {
    final (icon, label) = switch (visibility) {
      'all_friends' => (Icons.people, 'Friends'),
      'selected_friends' => (Icons.group, 'Selected'),
      _ => (Icons.lock_outline, 'Personal'),
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
