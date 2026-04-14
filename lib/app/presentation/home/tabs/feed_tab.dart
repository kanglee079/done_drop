part of '../home_screen.dart';

// ── FEED TAB ─────────────────────────────────────────────────────────────────

class _FeedTab extends StatelessWidget {
  const _FeedTab();

  @override
  Widget build(BuildContext context) {
    // Obx alone handles reactivity — no GetBuilder wrapper to avoid double rebuild.
    return Obx(() {
      final ctrl = Get.find<FeedController>();
      if (ctrl.isLoading.value) {
        return _FeedShimmer();
      }
      if (ctrl.moments.isEmpty) {
        return _EmptyFeedState(ctrl: ctrl);
      }
      return ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.space12),
        itemCount: ctrl.moments.length,
        itemBuilder: (_, i) => _FeedMomentCard(
          moment: ctrl.moments[i],
          ownerName: ctrl.getOwnerName(ctrl.moments[i].ownerId),
          ownerAvatar: ctrl.getOwnerAvatar(ctrl.moments[i].ownerId),
        ),
      );
    });
  }
}

class _FeedShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.space16),
      itemCount: 3,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSizes.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(width: 32, height: 32, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(height: 12, width: 100, color: Colors.white),
                    Container(height: 10, width: 60, color: Colors.white),
                  ]),
                ],
              ),
              const SizedBox(height: 12),
              Container(height: 200, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12))),
              const SizedBox(height: 12),
              Container(height: 14, width: double.infinity, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyFeedState extends StatelessWidget {
  const _EmptyFeedState({required this.ctrl});
  final FeedController ctrl;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.space32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.group_outlined, size: 56, color: AppColors.outlineVariant),
            const SizedBox(height: AppSizes.space16),
            const Text(
              'Buddy Feed', style: TextStyle(
                fontFamily: AppTypography.serifFamily, fontSize: 24, fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Private proofs from your\nbuddy crew will appear here.',
              textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: AppSizes.space24),
            Obx(() => ctrl.unreadCount.value > 0
                ? DDSecondaryButton(label: 'Mark All Read', icon: Icons.done_all, onPressed: ctrl.markAllRead, isExpanded: false)
                : const SizedBox.shrink()),
            const SizedBox(height: AppSizes.space12),
            Obx(() => DDSecondaryButton(
              label: 'Buddy Crew (${ctrl.friendCount.value})',
              icon: Icons.group_outlined,
              onPressed: () => Get.toNamed(AppRoutes.friends),
              isExpanded: false,
            )),
            const SizedBox(height: AppSizes.space12),
            DDPrimaryButton(label: 'Invite Buddy', icon: Icons.person_add, onPressed: () => Get.toNamed(AppRoutes.addFriend), isExpanded: false),
          ],
        ),
      ),
    );
  }
}

class _FeedMomentCard extends StatelessWidget {
  const _FeedMomentCard({required this.moment, required this.ownerName, required this.ownerAvatar});

  final Moment moment;
  final String ownerName;
  final String? ownerAvatar;

  @override
  Widget build(BuildContext context) {
    final reactionCtrl = Get.find<ReactionController>();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.space16, vertical: AppSizes.space8),
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
                  backgroundImage: ownerAvatar != null ? NetworkImage(ownerAvatar!) : null,
                  child: ownerAvatar == null
                      ? const Icon(Icons.person, size: 16, color: AppColors.primary) : null,
                ),
                const SizedBox(width: AppSizes.space8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ownerName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
                      Text(_timeAgo(moment.createdAt), style: const TextStyle(fontSize: 11, color: AppColors.outline)),
                    ],
                  ),
                ),
                _FeedVisibilityBadge(visibility: moment.visibility),
              ],
            ),
          ),

          // Image
          AspectRatio(
            aspectRatio: 1,
            child: CachedNetworkImage(
              imageUrl: moment.media.thumbnail.downloadUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(color: AppColors.surfaceContainerHighest),
              errorWidget: (_, __, ___) => Container(
                color: AppColors.surfaceContainerHighest,
                child: const Icon(Icons.broken_image, color: AppColors.outline),
              ),
            ),
          ),

          // Caption + Reactions
          Padding(
            padding: const EdgeInsets.all(AppSizes.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (moment.caption.isNotEmpty) ...[
                  Text(moment.caption, style: const TextStyle(fontSize: 14, color: AppColors.onSurface, height: 1.4)),
                  const SizedBox(height: AppSizes.space12),
                ],
                Row(
                  children: [
                    ...reactionCtrl.reactionTypes.map((type) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          reactionCtrl.toggleReaction(momentId: moment.id, reactionType: type);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHighest,
                            borderRadius: AppSizes.borderRadiusFull,
                          ),
                          child: Text(reactionCtrl.reactionIcon(type), style: const TextStyle(fontSize: 16)),
                        ),
                      ),
                    )),
                    const Spacer(),
                    if (moment.category != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          moment.category!,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
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

class _FeedVisibilityBadge extends StatelessWidget {
  const _FeedVisibilityBadge({required this.visibility});
  final String visibility;

  @override
  Widget build(BuildContext context) {
    final (icon, label) = switch (visibility) {
      'all_friends' => (Icons.groups, 'Crew'),
      'selected_friends' => (Icons.person_outline, 'Buddy'),
      _ => (Icons.lock_outline, 'Personal'),
    };
    return Row(
      children: [
        Icon(icon, size: 12, color: AppColors.outline),
        const SizedBox(width: 2),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.outline)),
      ],
    );
  }
}
