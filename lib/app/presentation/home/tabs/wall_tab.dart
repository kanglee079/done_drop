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

      final groupedMoments = controller.groupedMomentsByMonth;
      if (groupedMoments.isEmpty) {
        return const _EmptyWallState();
      }

      final sections = groupedMoments.entries.toList(growable: false);
      return ListView.separated(
        padding: spec.pagePadding(top: AppSizes.space12, bottom: 120),
        itemCount: sections.length,
        separatorBuilder: (context, index) =>
            const SizedBox(height: AppSizes.space24),
        itemBuilder: (context, index) {
          final section = sections[index];
          return _WallMonthSection(
            key: ValueKey('wall-${section.key}'),
            title: section.key,
            moments: section.value,
          );
        },
      );
    });
  }
}

class _WallMonthSection extends StatelessWidget {
  const _WallMonthSection({
    super.key,
    required this.title,
    required this.moments,
  });

  final String title;
  final List<Moment> moments;

  @override
  Widget build(BuildContext context) {
    final leadMoment = moments.first;
    final trailingMoments = moments.skip(1).toList(growable: false);
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: AppTypography.headlineSmall(color: AppColors.onSurface),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.space10,
                vertical: AppSizes.space6,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: AppSizes.borderRadiusFull,
              ),
              child: Text(
                '${moments.length}',
                style: AppTypography.labelMedium(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.space4),
        Text(
          l10n.wallSectionSubtitle,
          style: AppTypography.bodySmall(color: AppColors.onSurfaceVariant),
        ),
        const SizedBox(height: AppSizes.space16),
        _WallLeadCard(moment: leadMoment),
        if (trailingMoments.isNotEmpty) ...[
          const SizedBox(height: AppSizes.space12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: ddAdaptiveGridDelegate(
              context,
              compactExtent: 160,
              mediumExtent: 190,
              expandedExtent: 220,
              mainAxisSpacing: AppSizes.space12,
              crossAxisSpacing: AppSizes.space12,
              mainAxisExtent: DDResponsiveSpec.of(context).isCompact
                  ? 204
                  : 226,
            ),
            itemCount: trailingMoments.length,
            itemBuilder: (context, index) => _WallTileCard(
              key: ValueKey('wall-tile-${trailingMoments[index].id}'),
              moment: trailingMoments[index],
            ),
          ),
        ],
      ],
    );
  }
}

class _WallLeadCard extends StatelessWidget {
  const _WallLeadCard({required this.moment});

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
          AspectRatio(
            aspectRatio: 1.32,
            child: Stack(
              fit: StackFit.expand,
              children: [
                _WallMomentImage(moment: moment, imageUrl: imageUrl),
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
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSizes.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (moment.isPendingSync) ...[
                  _MomentSyncPill(moment: moment),
                  const SizedBox(height: AppSizes.space12),
                ],
                if ((moment.category ?? '').isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.space10,
                      vertical: AppSizes.space8,
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
                if ((moment.category ?? '').isNotEmpty)
                  const SizedBox(height: AppSizes.space12),
                Text(
                  moment.caption.isEmpty
                      ? l10n.wallLeadFallback(
                          DateFormat('MMM d', locale).format(moment.createdAt),
                        )
                      : moment.caption,
                  style: AppTypography.titleMedium(color: AppColors.onSurface),
                ),
                const SizedBox(height: AppSizes.space8),
                Text(
                  l10n.wallSectionSubtitle,
                  style: AppTypography.bodySmall(
                    color: AppColors.onSurfaceVariant,
                  ),
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
  const _WallTileCard({super.key, required this.moment});

  final Moment moment;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).languageCode;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppSizes.borderRadiusLg,
        border: Border.all(color: AppColors.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _WallMomentImage(
            moment: moment,
            imageUrl: moment.media.bestThumbnailUrl,
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.18),
                    Colors.black.withValues(alpha: 0.78),
                  ],
                  stops: const [0.42, 0.64, 1],
                ),
              ),
            ),
          ),
          if ((moment.category ?? '').isNotEmpty)
            Positioned(
              left: AppSizes.space10,
              top: AppSizes.space10,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.space8,
                  vertical: AppSizes.space6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.42),
                  borderRadius: AppSizes.borderRadiusFull,
                ),
                child: Text(
                  moment.category!,
                  style: AppTypography.bodySmall(color: Colors.white),
                ),
              ),
            ),
          if (moment.isPendingSync)
            Positioned(
              left: AppSizes.space10,
              right: AppSizes.space10,
              bottom: 58,
              child: _MomentSyncPill(moment: moment),
            ),
          Positioned(
            left: AppSizes.space12,
            right: AppSizes.space12,
            bottom: AppSizes.space12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('MMM d', locale).format(moment.createdAt),
                  style: AppTypography.bodySmall(
                    color: Colors.white.withValues(alpha: 0.88),
                  ),
                ),
                const SizedBox(height: AppSizes.space4),
                Text(
                  moment.caption.isEmpty
                      ? l10n.wallTileFallback
                      : moment.caption,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelLarge(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WallMomentImage extends StatelessWidget {
  const _WallMomentImage({required this.moment, required this.imageUrl});

  final Moment moment;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
        final cacheWidth = (constraints.maxWidth * devicePixelRatio).round();
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
            child: const Icon(Icons.broken_image_outlined),
          ),
        );
      },
    );
  }
}

class _EmptyWallState extends StatelessWidget {
  const _EmptyWallState();

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
                  color: AppColors.tertiaryFixed,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.photo_library_outlined,
                  color: AppColors.tertiary,
                  size: 34,
                ),
              ),
              const SizedBox(height: AppSizes.space16),
              Text(
                l10n.wallEmptyTitle,
                textAlign: TextAlign.center,
                style: AppTypography.headlineSmall(color: AppColors.onSurface),
              ),
              const SizedBox(height: AppSizes.space8),
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
      ),
    );
  }
}

class _WallLoadingState extends StatelessWidget {
  const _WallLoadingState();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSizes.space24),
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: AppColors.surfaceContainerHigh,
        highlightColor: AppColors.surfaceContainerLowest,
        child: Container(
          height: 280,
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
