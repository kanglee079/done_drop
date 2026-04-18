import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:done_drop/core/theme/theme.dart';
import 'package:done_drop/core/models/moment.dart';
import 'package:done_drop/app/core/widgets/widgets.dart';
import 'package:done_drop/app/presentation/memory_wall/memory_wall_controller.dart';
import 'package:done_drop/app/routes/app_routes.dart';
import 'package:done_drop/l10n/l10n.dart';

/// DoneDrop Memory Wall Screen — personal moments grid with category filters.
class MemoryWallScreen extends StatelessWidget {
  const MemoryWallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return GetBuilder<MemoryWallController>(
      builder: (ctrl) {
        final spec = DDResponsiveSpec.of(context);

        return Scaffold(
          backgroundColor: AppColors.surface,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.primary),
              onPressed: () => Get.back(),
            ),
            title: Text(
              l10n.memoryWallTitle,
              style: TextStyle(
                fontFamily: AppTypography.serifFamily,
                fontSize: 18,
                fontStyle: FontStyle.italic,
                color: AppColors.primary,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.camera_alt, color: AppColors.primary),
                onPressed: () => Get.toNamed(AppRoutes.capture),
              ),
            ],
          ),
          body: DDResponsiveCenter(
            maxWidth: spec.pageMaxWidth(
              compact: 600,
              medium: 920,
              expanded: 1100,
            ),
            child: Column(
              children: [
                Obx(
                  () => SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: spec.pagePadding(
                      top: AppSizes.space12,
                      bottom: AppSizes.space12,
                    ),
                    child: Row(
                      children: MemoryWallController.categories.map((cat) {
                        final label = cat.isEmpty
                            ? l10n.memoryWallAllFilter
                            : cat;
                        final isSelected = cat.isEmpty
                            ? ctrl.selectedCategory.value.isEmpty
                            : ctrl.selectedCategory.value == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: DDChip(
                            label: label,
                            isSelected: isSelected,
                            onTap: () => ctrl.setFilter(cat),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                Expanded(
                  child: Obx(() {
                    if (ctrl.isLoading.value) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      );
                    }
                    if (ctrl.moments.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.auto_awesome_mosaic_outlined,
                              size: 80,
                              color: AppColors.outlineVariant,
                            ),
                            const SizedBox(height: AppSizes.space24),
                            Text(
                              l10n.memoryWallEmptyTitle,
                              style: TextStyle(
                                fontFamily: AppTypography.serifFamily,
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: AppColors.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.memoryWallEmptySubtitle,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: AppSizes.space24),
                            DDPrimaryButton(
                              label: l10n.createFirstMomentAction,
                              icon: Icons.camera_alt,
                              onPressed: () => Get.toNamed(AppRoutes.capture),
                            ),
                          ],
                        ),
                      );
                    }
                    return GridView.builder(
                      padding: spec.pagePadding(
                        top: AppSizes.space4,
                        bottom: AppSizes.space16,
                      ),
                      gridDelegate: ddAdaptiveGridDelegate(
                        context,
                        compactExtent: 160,
                        mediumExtent: 190,
                        expandedExtent: 220,
                        mainAxisSpacing: AppSizes.space8,
                        crossAxisSpacing: AppSizes.space8,
                        childAspectRatio: 1,
                      ),
                      itemCount: ctrl.filteredMoments.length,
                      itemBuilder: (context, i) {
                        final moment = ctrl.filteredMoments[i];
                        return _MomentTile(
                          moment: moment,
                          onDelete: () => ctrl.deleteMoment(moment.id),
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MomentTile extends StatelessWidget {
  const _MomentTile({required this.moment, required this.onDelete});
  final Moment moment;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () async {
        final confirmed = await Get.dialog<bool>(
          AlertDialog(
            title: Text(context.l10n.deleteMomentTitle),
            content: Text(context.l10n.deleteMomentMessage),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: Text(context.l10n.cancelAction),
              ),
              TextButton(
                onPressed: () => Get.back(result: true),
                child: Text(
                  context.l10n.deleteAction,
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            ],
          ),
        );
        if (confirmed == true) onDelete();
      },
      child: ClipRRect(
        borderRadius: AppSizes.borderRadiusMd,
        child: Stack(
          fit: StackFit.expand,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
                final cacheWidth =
                    (constraints.maxWidth * devicePixelRatio).round();

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
                    child: Icon(
                      Icons.image_not_supported,
                      color: AppColors.outline,
                    ),
                  ),
                );
              },
            ),
            if (moment.localPreviewPath != null &&
                moment.localPreviewPath!.isNotEmpty)
              Positioned.fill(
                child: Image.file(
                  File(moment.localPreviewPath!),
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.low,
                ),
              ),
            if (moment.isPendingSync)
              Positioned(
                left: 10,
                right: 10,
                top: 10,
                child: _SyncBadge(moment: moment),
              ),
            if (moment.isPendingSync)
              Positioned(
                left: 10,
                right: 10,
                bottom: 10,
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
            if (moment.caption.isNotEmpty)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                  child: Text(
                    moment.caption,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SyncBadge extends StatelessWidget {
  const _SyncBadge({required this.moment});

  final Moment moment;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.68),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          switch (moment.syncStatus) {
            MomentSyncStatus.queued => l10n.statusQueued,
            MomentSyncStatus.processing => l10n.statusPreparing,
            MomentSyncStatus.uploading =>
              l10n.statusUploading((moment.uploadProgress * 100).round()),
            MomentSyncStatus.finalizing => l10n.statusSyncing,
            MomentSyncStatus.failed => l10n.statusFailed,
            MomentSyncStatus.synced => l10n.statusPosted,
          },
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
