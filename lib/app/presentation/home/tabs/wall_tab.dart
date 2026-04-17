part of '../home_screen.dart';

class _WallTab extends StatelessWidget {
  const _WallTab();

  @override
  Widget build(BuildContext context) {
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
        padding: const EdgeInsets.fromLTRB(
          AppSizes.space24,
          AppSizes.space12,
          AppSizes.space24,
          120,
        ),
        itemCount: sections.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSizes.space24),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Month label with divider ───────────────────────────────────────
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
                style: AppTypography.labelMedium(color: AppColors.onSurfaceVariant),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.space4),
        Text(
          'private moments',
          style: AppTypography.bodySmall(color: AppColors.onSurfaceVariant),
        ),
        const SizedBox(height: AppSizes.space16),
        // ── Lead card ──────────────────────────────────────────────────────
        _WallLeadCard(moment: leadMoment),
        if (trailingMoments.isNotEmpty) ...[
          const SizedBox(height: AppSizes.space12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: AppSizes.space12,
              crossAxisSpacing: AppSizes.space12,
              childAspectRatio: 1.05,
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
            aspectRatio: 16 / 9,
            child: CachedNetworkImage(
              imageUrl: moment.media.original.downloadUrl.isEmpty
                  ? moment.media.thumbnail.downloadUrl
                  : moment.media.original.downloadUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) =>
                  Container(color: AppColors.surfaceContainerHigh),
              errorWidget: (_, __, ___) => Container(
                color: AppColors.surfaceContainerHigh,
                child: const Icon(Icons.broken_image_outlined),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSizes.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                      ? 'A private proof from ${DateFormat('MMM d').format(moment.createdAt)}'
                      : moment.caption,
                  style: AppTypography.bodyLarge(color: AppColors.onSurface),
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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppSizes.borderRadiusLg,
        border: Border.all(color: AppColors.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: CachedNetworkImage(
              imageUrl: moment.media.thumbnail.downloadUrl,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (_, __) =>
                  Container(color: AppColors.surfaceContainerHigh),
              errorWidget: (_, __, ___) => Container(
                color: AppColors.surfaceContainerHigh,
                child: const Icon(Icons.broken_image_outlined),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSizes.space12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('MMM d').format(moment.createdAt),
                  style: AppTypography.bodySmall(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSizes.space4),
                Text(
                  moment.caption.isEmpty ? 'Saved privately' : moment.caption,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelMedium(color: AppColors.onSurface),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyWallState extends StatelessWidget {
  const _EmptyWallState();

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
                'Keep one promise.',
                textAlign: TextAlign.center,
                style: AppTypography.headlineSmall(color: AppColors.onSurface),
              ),
              const SizedBox(height: AppSizes.space8),
              Text(
                'The wall grows from there, one kept standard at a time.',
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
      itemBuilder: (_, __) => Shimmer.fromColors(
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
      separatorBuilder: (_, __) => const SizedBox(height: AppSizes.space20),
      itemCount: 3,
    );
  }
}
