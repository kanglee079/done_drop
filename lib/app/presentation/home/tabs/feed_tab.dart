part of '../home_screen.dart';

class _FeedTab extends StatefulWidget {
  const _FeedTab();

  @override
  State<_FeedTab> createState() => _FeedTabState();
}

class _FeedTabState extends State<_FeedTab> {
  late final PageController _pageController;
  int _currentIndex = 0;
  String? _lastPrimedMomentId;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _primeWindow(List<Moment> moments) {
    if (!mounted || moments.isEmpty) return;
    if (_currentIndex >= moments.length) {
      _currentIndex = moments.length - 1;
      if (_pageController.hasClients) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _pageController.hasClients) {
            _pageController.jumpToPage(_currentIndex);
          }
        });
      }
    }
    final safeIndex = _currentIndex.clamp(0, moments.length - 1);
    final centerMomentId = moments[safeIndex].id;
    if (_lastPrimedMomentId == centerMomentId) return;
    _lastPrimedMomentId = centerMomentId;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final controller = Get.find<FeedController>();
      controller.markMomentRead(moments[safeIndex].id);
      controller.loadMoreIfNeeded(safeIndex);
      BuddyFeedCacheService.instance.precacheWindow(
        context: context,
        moments: moments,
        centerIndex: safeIndex,
      );
    });
  }

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

      final moments = controller.moments.toList(growable: false);
      _primeWindow(moments);

      return PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        allowImplicitScrolling: true,
        padEnds: false,
        itemCount: moments.length,
        onPageChanged: (index) {
          _currentIndex = index;
          controller.markMomentRead(moments[index].id);
          controller.loadMoreIfNeeded(index);
          BuddyFeedCacheService.instance.precacheWindow(
            context: context,
            moments: moments,
            centerIndex: index,
          );
        },
        itemBuilder: (context, index) {
          final moment = moments[index];
          return Padding(
            padding: spec.pagePadding(
              top: AppSizes.space12,
              bottom: spec.isShort ? AppSizes.space16 : AppSizes.space20,
            ),
            child: Align(
              alignment: Alignment.topCenter,
              child: Stack(
                children: [
                  _BuddyMomentCard(
                    key: ValueKey('buddy-page-${moment.id}'),
                    moment: moment,
                    ownerName: controller.getOwnerName(moment),
                    ownerAvatar: controller.getOwnerAvatar(moment),
                    activityTitle: controller.activityTitleFor(moment),
                  ),
                  if (index == moments.length - 1 &&
                      controller.isFetchingMore.value)
                    Positioned(
                      left: AppSizes.space16,
                      right: AppSizes.space16,
                      bottom: AppSizes.space16,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.space12,
                            vertical: AppSizes.space8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLowest.withValues(
                              alpha: 0.92,
                            ),
                            borderRadius: AppSizes.borderRadiusFull,
                            border: Border.all(color: AppColors.outlineVariant),
                          ),
                          child: const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      );
    });
  }
}

class _EmptyBuddyState extends StatelessWidget {
  const _EmptyBuddyState({required this.controller});

  final FeedController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
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
                l10n.buddyEmptyTitle,
                textAlign: TextAlign.center,
                style: AppTypography.headlineSmall(color: AppColors.onSurface),
              ),
              const SizedBox(height: AppSizes.space8),
              Text(
                l10n.buddyEmptySubtitle,
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSizes.space20),
              FilledButton.icon(
                onPressed: () => Get.toNamed(AppRoutes.addFriend),
                icon: const Icon(Icons.person_add_alt_1_rounded),
                label: Text(l10n.inviteBuddyAction),
              ),
              const SizedBox(height: AppSizes.space12),
              TextButton(
                onPressed: () => Get.toNamed(AppRoutes.friends),
                child: Text(
                  l10n.manageCircleAction(controller.friendCount.value),
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

  void openBuddyWall() {
    Get.toNamed(
      AppRoutes.buddyWall,
      arguments: {
        'ownerId': moment.ownerId,
        'ownerName': ownerName,
        'ownerAvatarUrl': ownerAvatar,
      },
    );
  }

  void openBuddyChat() {
    Get.toNamed(
      AppRoutes.chat,
      arguments: {
        'buddyId': moment.ownerId,
        'buddyName': ownerName,
        'buddyAvatarUrl': ownerAvatar,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final cardHeight = (screenHeight * 0.64).clamp(340.0, 500.0);
    final caption = moment.caption.trim();
    final category = moment.category?.trim() ?? '';

    return Container(
      height: cardHeight,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppSizes.borderRadiusLg,
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: AppColors.cardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _MomentImage(moment: moment),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.06),
                              Colors.black.withValues(alpha: 0.52),
                            ],
                            stops: const [0.0, 0.52, 1.0],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: AppSizes.space14,
                      bottom: AppSizes.space14,
                      child: GestureDetector(
                        onTap: openBuddyWall,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.space12,
                            vertical: AppSizes.space8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.42),
                            borderRadius: AppSizes.borderRadiusFull,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.12),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: AppColors.primaryFixed,
                                backgroundImage: ownerAvatar != null
                                    ? NetworkImage(ownerAvatar!)
                                    : null,
                                child: ownerAvatar == null
                                    ? Text(
                                        ownerName.characters.first
                                            .toUpperCase(),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primary,
                                        ),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: AppSizes.space8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    ownerName,
                                    style: AppTypography.labelMedium(
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    _formatTime(moment.createdAt),
                                    style: AppTypography.bodySmall(
                                      color: Colors.white.withValues(
                                        alpha: 0.72,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: AppSizes.space6),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 10,
                                color: Colors.white.withValues(alpha: 0.72),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (activityTitle != null)
                      Positioned(
                        right: AppSizes.space14,
                        top: AppSizes.space14,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.space10,
                            vertical: AppSizes.space6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: AppSizes.borderRadiusFull,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.check_circle,
                                size: 12,
                                color: AppColors.onPrimary,
                              ),
                              const SizedBox(width: AppSizes.space4),
                              Text(
                                activityTitle!,
                                style: AppTypography.labelMedium(
                                  color: AppColors.onPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (moment.isPendingSync)
                      Positioned(
                        left: AppSizes.space14,
                        right: AppSizes.space14,
                        bottom: AppSizes.space14,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ClipRRect(
                              borderRadius: AppSizes.borderRadiusFull,
                              child: LinearProgressIndicator(
                                value:
                                    moment.syncStatus == MomentSyncStatus.queued
                                    ? null
                                    : moment.uploadProgress.clamp(0, 1),
                                minHeight: 4,
                                backgroundColor: Colors.white.withValues(
                                  alpha: 0.28,
                                ),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppColors.onPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSizes.space6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSizes.space10,
                                vertical: AppSizes.space4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.52),
                                borderRadius: AppSizes.borderRadiusFull,
                              ),
                              child: Text(
                                _syncStatusLabel(context),
                                style: AppTypography.labelSmall(
                                  color: Colors.white.withValues(alpha: 0.88),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.space14,
                  AppSizes.space12,
                  AppSizes.space14,
                  AppSizes.space14,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  border: Border(
                    top: BorderSide(color: AppColors.outlineVariant),
                  ),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final useStackedFooter = constraints.maxWidth < 430;

                    Widget buildFooterChip({
                      required IconData icon,
                      required String label,
                      VoidCallback? onTap,
                    }) {
                      final chip = Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.space10,
                          vertical: AppSizes.space6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: AppSizes.borderRadiusFull,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              icon,
                              size: 12,
                              color: AppColors.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              label,
                              style: AppTypography.bodySmall(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      );

                      if (onTap == null) {
                        return chip;
                      }

                      return GestureDetector(onTap: onTap, child: chip);
                    }

                    final metaCluster = Wrap(
                      spacing: AppSizes.space6,
                      runSpacing: AppSizes.space6,
                      children: [
                        buildFooterChip(
                          icon: _visibilityIcon(moment.visibility),
                          label: _visibilityLabel(moment.visibility, context),
                        ),
                        if (category.isNotEmpty)
                          buildFooterChip(
                            icon: Icons.auto_awesome_outlined,
                            label: category,
                          ),
                      ],
                    );

                    final actionCluster = Wrap(
                      spacing: AppSizes.space6,
                      runSpacing: AppSizes.space6,
                      children: [
                        if (!moment.isPendingSync) ...[
                          buildFooterChip(
                            icon: Icons.chat_bubble_outline_rounded,
                            label: context.l10n.chatOpenAction,
                            onTap: openBuddyChat,
                          ),
                          buildFooterChip(
                            icon: Icons.photo_library_outlined,
                            label: context.l10n.buddyViewWallAction,
                            onTap: openBuddyWall,
                          ),
                        ] else
                          buildFooterChip(
                            icon: Icons.cloud_upload_outlined,
                            label: _syncStatusLabel(context),
                          ),
                      ],
                    );

                    final reactionBar = ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: useStackedFooter
                            ? constraints.maxWidth
                            : constraints.maxWidth * 0.38,
                      ),
                      child: Align(
                        alignment: useStackedFooter
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: useStackedFooter
                              ? Alignment.centerLeft
                              : Alignment.centerRight,
                          child: _BuddyReactionBar(
                            moment: moment,
                            compact: true,
                            showLabels: false,
                          ),
                        ),
                      ),
                    );

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (caption.isNotEmpty) ...[
                          Text(
                            caption,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodySmall(
                              color: AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(height: AppSizes.space12),
                        ],
                        metaCluster,
                        const SizedBox(height: AppSizes.space10),
                        if (useStackedFooter) ...[
                          actionCluster,
                          const SizedBox(height: AppSizes.space10),
                          reactionBar,
                        ] else
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(child: actionCluster),
                              const SizedBox(width: AppSizes.space12),
                              reactionBar,
                            ],
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  IconData _visibilityIcon(String visibility) {
    switch (visibility) {
      case 'all_friends':
        return Icons.groups_outlined;
      case 'selected_friends':
        return Icons.person_outline;
      default:
        return Icons.lock_outline;
    }
  }

  String _visibilityLabel(String visibility, BuildContext context) {
    switch (visibility) {
      case 'all_friends':
        return context.l10n.visibilityCrew;
      case 'selected_friends':
        return context.l10n.visibilityBuddy;
      default:
        return context.l10n.visibilityPrivate;
    }
  }

  String _syncStatusLabel(BuildContext context) {
    final l10n = context.l10n;
    switch (moment.syncStatus) {
      case MomentSyncStatus.queued:
        return l10n.statusQueued;
      case MomentSyncStatus.processing:
        return l10n.statusPreparing;
      case MomentSyncStatus.uploading:
        return l10n.statusUploading((moment.uploadProgress * 100).round());
      case MomentSyncStatus.finalizing:
        return l10n.statusSyncing;
      case MomentSyncStatus.failed:
        return l10n.statusFailed;
      case MomentSyncStatus.synced:
        return l10n.statusPosted;
    }
  }

  String _formatTime(DateTime createdAt) {
    final difference = DateTime.now().difference(createdAt);
    final l10n = currentL10n;
    if (difference.inMinutes < 1) return l10n.timeJustNow;
    if (difference.inHours < 1) {
      return l10n.timeMinutesAgo(difference.inMinutes);
    }
    if (difference.inDays < 1) return l10n.timeHoursAgo(difference.inHours);
    return DateFormat(
      'MMM d',
      resolveSupportedLocale(null).languageCode,
    ).format(createdAt);
  }
}

class _MomentImage extends StatelessWidget {
  const _MomentImage({required this.moment});

  final Moment moment;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
        final cacheWidth = (constraints.maxWidth * devicePixelRatio).round();
        final localPreviewPath = moment.localPreviewPath;
        final image = localPreviewPath != null && localPreviewPath.isNotEmpty
            ? Image.file(
                File(localPreviewPath),
                fit: BoxFit.cover,
                cacheWidth: cacheWidth,
                filterQuality: FilterQuality.low,
              )
            : CachedNetworkImage(
                imageUrl: moment.media.bestThumbnailUrl,
                fit: BoxFit.cover,
                memCacheWidth: cacheWidth,
                maxWidthDiskCache: cacheWidth,
                fadeInDuration: const Duration(milliseconds: 120),
                fadeOutDuration: Duration.zero,
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

        return Stack(
          fit: StackFit.expand,
          children: [
            image,
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.06),
                      Colors.black.withValues(alpha: 0.28),
                    ],
                    stops: const [0.48, 0.74, 1],
                  ),
                ),
              ),
            ),
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
      },
    );
  }
}

class _BuddyReactionBar extends StatefulWidget {
  const _BuddyReactionBar({
    required this.moment,
    required this.compact,
    required this.showLabels,
  });

  final Moment moment;
  final bool compact;
  final bool showLabels;

  @override
  State<_BuddyReactionBar> createState() => _BuddyReactionBarState();
}

class _BuddyReactionBarState extends State<_BuddyReactionBar> {
  late final ReactionController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<ReactionController>();
    _controller.observeMoment(widget.moment.id);
  }

  @override
  void didUpdateWidget(covariant _BuddyReactionBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.moment.id != widget.moment.id) {
      _controller.observeMoment(widget.moment.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final summary = _controller.summaryFor(widget.moment);

      return Wrap(
        spacing: AppSizes.space8,
        runSpacing: AppSizes.space8,
        children: _controller.reactionTypes
            .map((type) {
              return DDAnimatedReactionChip(
                icon: _controller.reactionIconData(type),
                label: widget.showLabels
                    ? _controller.reactionLabel(context, type)
                    : '',
                color: _controller.reactionColor(type),
                count: summary.countFor(type),
                isActive: summary.isActive(type),
                isBusy: _controller.isBusy(widget.moment.id),
                compact: widget.compact,
                onTap: () {
                  HapticFeedback.lightImpact();
                  _controller.toggleReaction(
                    momentId: widget.moment.id,
                    reactionType: type,
                    currentUserReaction: summary.currentUserReaction,
                  );
                },
              );
            })
            .toList(growable: false),
      );
    });
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
