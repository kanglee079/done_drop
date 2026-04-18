import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:done_drop/app/core/widgets/widgets.dart';
import 'package:done_drop/app/presentation/buddy_wall/buddy_wall_controller.dart';
import 'package:done_drop/app/routes/app_routes.dart';
import 'package:done_drop/core/models/moment.dart';
import 'package:done_drop/core/theme/theme.dart';
import 'package:done_drop/l10n/l10n.dart';

class BuddyWallScreen extends GetView<BuddyWallController> {
  const BuddyWallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final spec = DDResponsiveSpec.of(context);
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Normal AppBar with title (always visible)
          SliverAppBar(
            expandedHeight: 0,
            pinned: true,
            backgroundColor: AppColors.surface.withValues(alpha: 0.95),
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              onPressed: () => Get.back(),
              icon: const Icon(Icons.arrow_back, color: AppColors.primary),
            ),
            title: Text(
              l10n.buddyWallTitle(
                controller.ownerName.isEmpty
                    ? l10n.memberFallbackName
                    : controller.ownerName,
              ),
              style: AppTypography.titleMedium(color: AppColors.onSurface),
            ),
            actions: [
              IconButton(
                onPressed: () => Get.toNamed(
                  AppRoutes.chat,
                  arguments: {
                    'buddyId': controller.ownerId,
                    'buddyName': controller.ownerName,
                    'buddyAvatarUrl': controller.ownerAvatarUrl,
                  },
                ),
                icon: const Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),

          // Profile card (shows name, avatar, moment count)
          SliverToBoxAdapter(
            child: Obx(() {
              final momentCount = controller.filteredMoments.length;
              final ownerName = controller.ownerName.isEmpty
                  ? l10n.memberFallbackName
                  : controller.ownerName;
              return Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.space16,
                  AppSizes.space8,
                  AppSizes.space16,
                  AppSizes.space12,
                ),
                child: _BuddyProfileCard(
                  ownerName: ownerName,
                  momentCount: momentCount,
                  avatarUrl: controller.ownerAvatarUrl,
                ),
              );
            }),
          ),

          // Category filter chips
          SliverToBoxAdapter(
            child: Obx(
              () => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(
                  left: AppSizes.space16,
                  right: AppSizes.space16,
                  bottom: AppSizes.space12,
                ),
                child: Row(
                  children:
                      BuddyWallController.categories.map<Widget>((category) {
                    final label = category.isEmpty
                        ? l10n.memoryWallAllFilter
                        : category;
                    final isSelected = category.isEmpty
                        ? controller.selectedCategory.value.isEmpty
                        : controller.selectedCategory.value == category;
                    return Padding(
                      padding: const EdgeInsets.only(right: AppSizes.space8),
                      child: DDChip(
                        label: label,
                        isSelected: isSelected,
                        onTap: () => controller.setFilter(category),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),

          // Grid content
          Obx(() {
            if (controller.isLoading.value) {
              return const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              );
            }

            final moments = controller.filteredMoments;
            if (moments.isEmpty) {
              return SliverFillRemaining(
                child: Center(
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
                            Icons.photo_library_outlined,
                            color: AppColors.primary,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: AppSizes.space16),
                        Text(
                          l10n.buddyWallEmptyTitle,
                          textAlign: TextAlign.center,
                          style:
                              AppTypography.headlineSmall(color: AppColors.onSurface),
                        ),
                        const SizedBox(height: AppSizes.space8),
                        Text(
                          l10n.buddyWallEmptySubtitle(controller.ownerName),
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

            return SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.space16,
                0,
                AppSizes.space16,
                120,
              ),
              sliver: SliverGrid(
                gridDelegate: ddAdaptiveGridDelegate(
                  context,
                  compactExtent: 168,
                  mediumExtent: 196,
                  expandedExtent: 220,
                  mainAxisSpacing: AppSizes.space12,
                  crossAxisSpacing: AppSizes.space12,
                  mainAxisExtent: spec.isCompact ? 214 : 236,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) =>
                      _BuddyWallMomentTile(moment: moments[index]),
                  childCount: moments.length,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _BuddyProfileCard extends StatelessWidget {
  const _BuddyProfileCard({
    required this.ownerName,
    required this.momentCount,
    required this.avatarUrl,
  });

  final String ownerName;
  final int momentCount;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(AppSizes.space16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppSizes.borderRadiusLg,
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primaryFixed,
            backgroundImage:
                avatarUrl != null ? NetworkImage(avatarUrl!) : null,
            child: avatarUrl == null
                ? Text(
                    ownerName.characters.first.toUpperCase(),
                    style: AppTypography.titleMedium(color: AppColors.primary),
                  )
                : null,
          ),
          const SizedBox(width: 14),
          // Name & subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ownerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.titleMedium(color: AppColors.onSurface),
                ),
                const SizedBox(height: AppSizes.space2),
                Text(
                  l10n.buddyWallHeroSubtitle(momentCount),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      AppTypography.bodySmall(color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          // Count badge
          const SizedBox(width: AppSizes.space12),
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primaryFixed,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                '$momentCount',
                style: AppTypography.titleMedium(color: AppColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BuddyWallMomentTile extends StatelessWidget {
  const _BuddyWallMomentTile({required this.moment});

  final Moment moment;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;

    return ClipRRect(
      borderRadius: AppSizes.borderRadiusLg,
      child: Stack(
        fit: StackFit.expand,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final devicePixelRatio =
                  MediaQuery.devicePixelRatioOf(context);
              final cacheWidth =
                  (constraints.maxWidth * devicePixelRatio).round();
              final previewPath = moment.localPreviewPath;

              if (previewPath != null && previewPath.isNotEmpty) {
                return Image.file(
                  File(previewPath),
                  fit: BoxFit.cover,
                  cacheWidth: cacheWidth,
                  filterQuality: FilterQuality.low,
                );
              }

              return CachedNetworkImage(
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
                  child: const Icon(Icons.image_not_supported_outlined),
                ),
              );
            },
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.14),
                    Colors.black.withValues(alpha: 0.74),
                  ],
                  stops: const [0.35, 0.62, 1],
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
                  color: Colors.black.withValues(alpha: 0.44),
                  borderRadius: AppSizes.borderRadiusFull,
                ),
                child: Text(
                  moment.category!,
                  style: AppTypography.bodySmall(color: Colors.white),
                ),
              ),
            ),
          Positioned(
            left: AppSizes.space12,
            right: AppSizes.space12,
            bottom: AppSizes.space12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatWallDate(moment.createdAt, locale),
                  style: AppTypography.bodySmall(
                    color: Colors.white.withValues(alpha: 0.88),
                  ),
                ),
                const SizedBox(height: AppSizes.space4),
                Text(
                  moment.caption.isEmpty
                      ? context.l10n.wallTileFallback
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

  String _formatWallDate(DateTime date, String locale) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return locale == 'vi' ? '$day/$month' : '$month/$day';
  }
}
