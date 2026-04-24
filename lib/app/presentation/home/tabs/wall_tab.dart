part of '../home_screen.dart';

class _WallTab extends StatelessWidget {
  const _WallTab();

  @override
  Widget build(BuildContext context) {
    final spec = DDResponsiveSpec.of(context);

    return Obx(() {
      final controller = Get.find<MemoryWallController>();
      if (controller.isLoading.value) {
        return const _WallLoadingState();
      }

      final filteredMoments = controller.filteredMoments;
      if (filteredMoments.isEmpty) {
        return const _EmptyWallState();
      }

      // Masonry quilted layout: alternating section patterns for visual rhythm.
      return CustomScrollView(
        slivers: [
          // Sticky category filter chips.
          SliverToBoxAdapter(
            child: _WallCategoryFilter(controller: controller),
          ),
          // Masonry grid using staggered grid view.
          SliverPadding(
            padding: spec.pagePadding(
              top: AppSizes.space12,
              bottom: 120,
            ),
            sliver: SliverMasonryGrid.count(
              crossAxisCount: _masonryColumnCount(context),
              mainAxisSpacing: AppSizes.space12,
              crossAxisSpacing: AppSizes.space12,
              childCount: filteredMoments.length,
              itemBuilder: (context, index) {
                final moment = filteredMoments[index];
                // Alternate card styles: hero (featured) vs tile.
                final isFeatured = index == 0 ||
                    (index < 3 && _isLandscapeMoment(moment));
                return _WallMasonryCard(
                  key: ValueKey('wall-masonry-${moment.id}'),
                  moment: moment,
                  isFeatured: isFeatured,
                );
              },
            ),
          ),
        ],
      );
    });
  }

  int _masonryColumnCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1120) return 4;
    if (width >= 920) return 3;
    if (width >= 600) return 2;
    return 2;
  }

  bool _isLandscapeMoment(Moment moment) {
    // Heuristic: moments with activity titles or captions tend to be featured.
    return (moment.caption.isNotEmpty || moment.activityTitle != null);
  }
}

class _WallCategoryFilter extends StatelessWidget {
  const _WallCategoryFilter({required this.controller});

  final MemoryWallController controller;

  @override
  Widget build(BuildContext context) {
    final categories = MemoryWallController.categories;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.space24,
        vertical: AppSizes.space12,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Obx(() => Row(
          children: categories.map((cat) {
            final isSelected = controller.selectedCategory.value == cat;
            final label = cat.isEmpty
                ? context.l10n.noneLabel
                : cat;
            return Padding(
              padding: const EdgeInsets.only(right: AppSizes.space8),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: AppSizes.borderRadiusFull,
                  onTap: () => controller.setFilter(cat),
                  child: AnimatedContainer(
                    duration: AppMotion.fast,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.space14,
                      vertical: AppSizes.space8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.surfaceContainerLow,
                      borderRadius: AppSizes.borderRadiusFull,
                      border: isSelected
                          ? null
                          : Border.all(color: AppColors.outlineVariant),
                    ),
                    child: Text(
                      label,
                      style: AppTypography.labelMedium(
                        color: isSelected
                            ? AppColors.onPrimary
                            : AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(growable: false),
        )),
      ),
    );
  }
}

/// Masonry card — two styles: featured (full-width-like) and standard tile.
class _WallMasonryCard extends StatelessWidget {
  const _WallMasonryCard({
    super.key,
    required this.moment,
    required this.isFeatured,
  });

  final Moment moment;
  final bool isFeatured;

  @override
  Widget build(BuildContext context) {
    return isFeatured
        ? _WallFeaturedCard(moment: moment)
        : _WallTileCard(moment: moment);
  }
}

class _WallFeaturedCard extends StatelessWidget {
  const _WallFeaturedCard({required this.moment});

  final Moment moment;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).languageCode;
    final imageUrl = moment.media.bestOriginalUrl;

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
          // Featured image — larger aspect ratio.
          AspectRatio(
            aspectRatio: 1.25,
            child: Stack(
              fit: StackFit.expand,
              children: [
                _WallMomentImage(
                  moment: moment,
                  imageUrl: imageUrl,
                  memCacheWidth: 800,
                ),
                // Gradient.
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.28),
                        ],
                        stops: const [0.5, 1],
                      ),
                    ),
                  ),
                ),
                // Date chip.
                Positioned(
                  right: AppSizes.space12,
                  top: AppSizes.space12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.space10,
                      vertical: AppSizes.space6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.42),
                      borderRadius: AppSizes.borderRadiusFull,
                    ),
                    child: Text(
                      DateFormat('MMM d', locale).format(moment.createdAt),
                      style: AppTypography.bodySmall(color: Colors.white),
                    ),
                  ),
                ),
                // Category chip.
                if ((moment.category ?? '').isNotEmpty)
                  Positioned(
                    left: AppSizes.space12,
                    top: AppSizes.space12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.space10,
                        vertical: AppSizes.space6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.tertiaryFixed,
                        borderRadius: AppSizes.borderRadiusFull,
                      ),
                      child: Text(
                        moment.category!,
                        style: AppTypography.bodySmall(color: AppColors.tertiary),
                      ),
                    ),
                  ),
                // Sync indicator.
                if (moment.isPendingSync)
                  Positioned(
                    left: AppSizes.space12,
                    right: AppSizes.space12,
                    bottom: AppSizes.space12,
                    child: _WallSyncPill(moment: moment),
                  ),
              ],
            ),
          ),
          // Caption block.
          Padding(
            padding: const EdgeInsets.all(AppSizes.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (moment.activityTitle != null) ...[
                  Row(
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: AppSizes.space6),
                      Expanded(
                        child: Text(
                          moment.activityTitle!,
                          style: AppTypography.labelMedium(
                            color: AppColors.primary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.space8),
                ],
                Text(
                  moment.caption.isEmpty
                      ? l10n.wallLeadFallback(
                          DateFormat('MMM d', locale).format(moment.createdAt),
                        )
                      : moment.caption,
                  style: AppTypography.titleMedium(color: AppColors.onSurface),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WallTileCard extends StatelessWidget {
  const _WallTileCard({required this.moment});

  final Moment moment;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final hasCaption = moment.caption.isNotEmpty;
    final hasCategory = (moment.category ?? '').isNotEmpty;
    // Dynamic aspect ratio based on content.
    final aspectRatio = !hasCaption && !hasCategory
        ? 1.0
        : hasCaption
            ? 0.85
            : 0.9;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppSizes.borderRadiusLg,
        border: Border.all(color: AppColors.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image.
              AspectRatio(
                aspectRatio: aspectRatio,
                child: _WallMomentImage(
                  moment: moment,
                  imageUrl: moment.media.bestThumbnailUrl,
                  memCacheWidth: 400,
                ),
              ),
              // Caption / meta.
              if (hasCaption || hasCategory)
                Padding(
                  padding: const EdgeInsets.all(AppSizes.space12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (hasCategory) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.space8,
                            vertical: AppSizes.space4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.tertiaryFixed,
                            borderRadius: AppSizes.borderRadiusFull,
                          ),
                          child: Text(
                            moment.category!,
                            style: AppTypography.labelSmall(
                              color: AppColors.tertiary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: AppSizes.space6),
                      ],
                      if (hasCaption)
                        Text(
                          moment.caption,
                          style: AppTypography.bodySmall(
                            color: AppColors.onSurface,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
            ],
          ),
          // Date overlay.
          Positioned(
            left: AppSizes.space10,
            top: AppSizes.space10,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.space8,
                vertical: AppSizes.space4,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.42),
                borderRadius: AppSizes.borderRadiusFull,
              ),
              child: Text(
                DateFormat('MMM d', locale).format(moment.createdAt),
                style: AppTypography.bodySmall(color: Colors.white),
              ),
            ),
          ),
          // Sync overlay.
          if (moment.isPendingSync)
            Positioned(
              left: AppSizes.space10,
              right: AppSizes.space10,
              bottom: hasCaption || hasCategory
                  ? 52 + AppSizes.space10
                  : AppSizes.space10,
              child: _WallSyncPill(moment: moment),
            ),
        ],
      ),
    );
  }
}

class _WallMomentImage extends StatelessWidget {
  const _WallMomentImage({
    required this.moment,
    required this.imageUrl,
    required this.memCacheWidth,
  });

  final Moment moment;
  final String imageUrl;
  final int memCacheWidth;

  @override
  Widget build(BuildContext context) {
    final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
    final cacheWidth = (memCacheWidth * devicePixelRatio).round();
    final localPreviewPath = moment.localPreviewPath;

    if (localPreviewPath != null && localPreviewPath.isNotEmpty) {
      return Image.file(
        File(localPreviewPath),
        fit: BoxFit.cover,
        cacheWidth: cacheWidth,
        filterQuality: FilterQuality.low,
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: double.infinity,
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
  }
}

class _WallSyncPill extends StatelessWidget {
  const _WallSyncPill({required this.moment});

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
        _wallSyncLabel(context, moment),
        style: AppTypography.bodySmall(color: AppColors.onSurface),
      ),
    );
  }
}

String _wallSyncLabel(BuildContext context, Moment moment) {
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

class _EmptyWallState extends StatelessWidget {
  const _EmptyWallState();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.space32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.tertiaryFixed,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.photo_library_outlined,
                color: AppColors.tertiary,
                size: 36,
              ),
            ),
            const SizedBox(height: AppSizes.space20),
            Text(
              l10n.wallEmptyTitle,
              textAlign: TextAlign.center,
              style: AppTypography.headlineSmall(color: AppColors.onSurface),
            ),
            const SizedBox(height: AppSizes.space10),
            Text(
              l10n.wallEmptySubtitle,
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
}

class _WallLoadingState extends StatelessWidget {
  const _WallLoadingState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.space24),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: AppSizes.space12,
          crossAxisSpacing: AppSizes.space12,
          childAspectRatio: 0.8,
        ),
        itemCount: 6,
        itemBuilder: (context, index) => Shimmer.fromColors(
          baseColor: AppColors.surfaceContainerHigh,
          highlightColor: AppColors.surfaceContainerLowest,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppSizes.borderRadiusLg,
            ),
          ),
        ),
      ),
    );
  }
}
