part of '../home_screen.dart';

class _FeedTab extends StatelessWidget {
  const _FeedTab();

  @override
  Widget build(BuildContext context) {
    final spec = DDResponsiveSpec.of(context);

    return Obx(() {
      final controller = Get.find<FeedController>();
      if (controller.isLoading.value) {
        return const _FeedLoadingState();
      }
      if (controller.moments.isEmpty) {
        return _EmptyBuddyState(controller: controller);
      }

      return ListView.separated(
        padding: spec.pagePadding(top: AppSizes.space12, bottom: 120),
        itemBuilder: (context, index) {
          final moment = controller.moments[index];
          return _BuddyMomentCard(
            key: ValueKey('buddy-${moment.id}'),
            moment: moment,
            ownerName: controller.getOwnerName(moment),
            ownerAvatar: controller.getOwnerAvatar(moment),
            activityTitle: controller.activityTitleFor(moment),
          );
        },
        separatorBuilder: (context, index) =>
            const SizedBox(height: AppSizes.space20),
        itemCount: controller.moments.length,
      );
    });
  }
}

class _EmptyBuddyState extends StatelessWidget {
  const _EmptyBuddyState({required this.controller});

  final FeedController controller;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.space24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSizes.space24),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: AppSizes.borderRadiusLg,
          ),
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
                  Icons.group_outlined,
                  color: AppColors.primary,
                  size: 34,
                ),
              ),
              const SizedBox(height: AppSizes.space16),
              Text(
                'Your buddy feed is private by design.',
                textAlign: TextAlign.center,
                style: AppTypography.headlineSmall(color: AppColors.onSurface),
              ),
              const SizedBox(height: AppSizes.space8),
              Text(
                'Invite a few close people you trust to keep the proof loop intimate.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSizes.space20),
              FilledButton.icon(
                onPressed: () => Get.toNamed(AppRoutes.addFriend),
                icon: const Icon(Icons.person_add_alt_1_rounded),
                label: const Text('Invite buddy'),
              ),
              const SizedBox(height: AppSizes.space12),
              TextButton(
                onPressed: () => Get.toNamed(AppRoutes.friends),
                child: Text(
                  'Manage circle (${controller.friendCount.value})',
                  style: AppTypography.labelLarge(color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BuddyMomentCard extends StatelessWidget {
  const _BuddyMomentCard({
    super.key,
    required this.moment,
    required this.ownerName,
    required this.ownerAvatar,
    required this.activityTitle,
  });

  final Moment moment;
  final String ownerName;
  final String? ownerAvatar;
  final String? activityTitle;

  @override
  Widget build(BuildContext context) {
    final reactionController = Get.find<ReactionController>();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppSizes.borderRadiusLg,
        boxShadow: AppColors.cardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.space16,
              AppSizes.space16,
              AppSizes.space16,
              AppSizes.space12,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primaryFixed,
                  backgroundImage: ownerAvatar != null
                      ? NetworkImage(ownerAvatar!)
                      : null,
                  child: ownerAvatar == null
                      ? Text(
                          ownerName.characters.first.toUpperCase(),
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
                    children: [
                      Text(
                        ownerName,
                        style: AppTypography.labelLarge(
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: AppSizes.space2),
                      Text(
                        _formatTime(moment.createdAt),
                        style: AppTypography.bodySmall(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      if (moment.isPendingSync) ...[
                        const SizedBox(height: AppSizes.space4),
                        _MomentSyncPill(moment: moment),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          // ── Image ───────────────────────────────────────────────────────
          AspectRatio(
            aspectRatio: 4 / 5,
            child: _MomentImage(moment: moment),
          ),
          // ── Card Footer ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(AppSizes.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category + activity chips
                Wrap(
                  spacing: AppSizes.space8,
                  runSpacing: AppSizes.space8,
                  children: [
                    if (moment.isPendingSync)
                      _MetaChip(
                        icon: Icons.sync_outlined,
                        label: _syncLabel(moment),
                        color: AppColors.onSurface,
                        background: AppColors.surfaceContainerHigh,
                      ),
                    if (activityTitle != null)
                      _MetaChip(
                        icon: Icons.check_circle_outline,
                        label: activityTitle!,
                        color: AppColors.primary,
                        background: AppColors.primaryFixed,
                      ),
                    if ((moment.category ?? '').isNotEmpty)
                      _MetaChip(
                        icon: Icons.auto_awesome_outlined,
                        label: moment.category!,
                        color: AppColors.tertiary,
                        background: AppColors.tertiaryFixed,
                      ),
                  ],
                ),
                if (moment.caption.isNotEmpty) ...[
                  const SizedBox(height: AppSizes.space12),
                  Text(
                    moment.caption,
                    style: AppTypography.bodyMedium(color: AppColors.onSurface),
                  ),
                ],
                const SizedBox(height: AppSizes.space16),
                // Visibility + reactions row
                Row(
                  children: [
                    _VisibilityChip(visibility: moment.visibility),
                    const Spacer(),
                    ...reactionController.reactionTypes.map((reactionType) {
                      return Padding(
                        padding: const EdgeInsets.only(left: AppSizes.space8),
                        child: _ReactionPill(
                          label: reactionController.reactionIcon(reactionType),
                          onTap: () => reactionController.toggleReaction(
                            momentId: moment.id,
                            reactionType: reactionType,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime createdAt) {
    final difference = DateTime.now().difference(createdAt);
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    if (difference.inDays < 1) return '${difference.inHours}h ago';
    return DateFormat('MMM d').format(createdAt);
  }
}

class _MomentImage extends StatelessWidget {
  const _MomentImage({required this.moment});

  final Moment moment;

  @override
  Widget build(BuildContext context) {
    final localPreviewPath = moment.localPreviewPath;
    if (localPreviewPath != null && localPreviewPath.isNotEmpty) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.file(File(localPreviewPath), fit: BoxFit.cover),
          if (moment.isPendingSync)
            Positioned(
              left: AppSizes.space12,
              right: AppSizes.space12,
              bottom: AppSizes.space12,
              child: ClipRRect(
                borderRadius: AppSizes.borderRadiusFull,
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
      );
    }

    return CachedNetworkImage(
      imageUrl: moment.media.thumbnail.downloadUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) =>
          Container(color: AppColors.surfaceContainerHigh),
      errorWidget: (context, url, error) => Container(
        color: AppColors.surfaceContainerHigh,
        child: const Icon(
          Icons.broken_image_outlined,
          color: AppColors.outline,
        ),
      ),
    );
  }
}

class _MomentSyncPill extends StatelessWidget {
  const _MomentSyncPill({required this.moment});

  final Moment moment;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.space10,
        vertical: AppSizes.space6,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: AppSizes.borderRadiusFull,
      ),
      child: Text(
        _syncLabel(moment),
        style: AppTypography.bodySmall(color: AppColors.onSurface),
      ),
    );
  }
}

String _syncLabel(Moment moment) {
  switch (moment.syncStatus) {
    case MomentSyncStatus.queued:
      return 'Queued';
    case MomentSyncStatus.processing:
      return 'Preparing';
    case MomentSyncStatus.uploading:
      return 'Uploading ${(moment.uploadProgress * 100).round()}%';
    case MomentSyncStatus.finalizing:
      return 'Syncing';
    case MomentSyncStatus.failed:
      return 'Failed';
    case MomentSyncStatus.synced:
      return 'Posted';
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.background,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.space10,
        vertical: AppSizes.space8,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppSizes.borderRadiusFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: AppSizes.space6),
          Text(label, style: AppTypography.bodySmall(color: color)),
        ],
      ),
    );
  }
}

class _ReactionPill extends StatelessWidget {
  const _ReactionPill({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppSizes.borderRadiusFull,
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.space12,
            vertical: AppSizes.space10,
          ),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: AppSizes.borderRadiusFull,
          ),
          child: Text(label, style: const TextStyle(fontSize: 18)),
        ),
      ),
    );
  }
}

class _VisibilityChip extends StatelessWidget {
  const _VisibilityChip({required this.visibility});

  final String visibility;

  @override
  Widget build(BuildContext context) {
    final (icon, label) = switch (visibility) {
      AppConstants.visibilityAllFriends => (Icons.groups_outlined, 'Crew'),
      AppConstants.visibilitySelectedFriends => (Icons.person_outline, 'Buddy'),
      _ => (Icons.lock_outline, 'Private'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.space10,
        vertical: AppSizes.space8,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: AppSizes.borderRadiusFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.onSurfaceVariant),
          const SizedBox(width: AppSizes.space4),
          Text(
            label,
            style: AppTypography.bodySmall(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _FeedLoadingState extends StatelessWidget {
  const _FeedLoadingState();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSizes.space24),
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: AppColors.surfaceContainerHigh,
        highlightColor: AppColors.surfaceContainerLowest,
        child: Container(
          height: 360,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppSizes.borderRadiusLg,
          ),
        ),
      ),
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppSizes.space20),
      itemCount: 3,
    );
  }
}
