import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:done_drop/core/theme/theme.dart';
import 'package:done_drop/core/models/moment.dart';
import 'package:done_drop/app/core/widgets/widgets.dart';
import 'package:done_drop/app/presentation/memory_wall/memory_wall_controller.dart';
import 'package:done_drop/app/routes/app_routes.dart';

/// DoneDrop Memory Wall Screen — personal moments grid with category filters.
class MemoryWallScreen extends StatelessWidget {
  const MemoryWallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MemoryWallController>(
      builder: (ctrl) {
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
              'Memory Wall',
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
          body: Column(
            children: [
              // Category filter chips
              Obx(() => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.space24,
                  vertical: AppSizes.space12,
                ),
                child: Row(
                  children: MemoryWallController.categories.map((cat) {
                    final isSelected = (cat == 'All Moments' && ctrl.selectedCategory.value.isEmpty)
                        || ctrl.selectedCategory.value == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: DDChip(
                        label: cat,
                        isSelected: isSelected,
                        onTap: () => ctrl.setFilter(cat),
                      ),
                    );
                  }).toList(),
                ),
              )),

              // Grid
              Expanded(
                child: Obx(() {
                  if (ctrl.isLoading.value) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                  }
                  if (ctrl.moments.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.auto_awesome_mosaic_outlined,
                              size: 80, color: AppColors.outlineVariant),
                          const SizedBox(height: AppSizes.space24),
                          Text(
                            'No moments yet',
                            style: TextStyle(
                              fontFamily: AppTypography.serifFamily,
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Your personal museum of moments\nwill appear here.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant),
                          ),
                          const SizedBox(height: AppSizes.space24),
                          DDPrimaryButton(
                            label: 'Create your first moment',
                            icon: Icons.camera_alt,
                            onPressed: () => Get.toNamed(AppRoutes.capture),
                          ),
                        ],
                      ),
                    );
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.all(AppSizes.space16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
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
            title: const Text('Delete Moment'),
            content: const Text('Are you sure you want to delete this moment?'),
            actions: [
              TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
              TextButton(
                onPressed: () => Get.back(result: true),
                child: Text('Delete', style: TextStyle(color: AppColors.error)),
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
            CachedNetworkImage(
              imageUrl: moment.media.thumbnail.downloadUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(color: AppColors.surfaceContainerHigh),
              errorWidget: (_, __, ___) => Container(
                color: AppColors.surfaceContainerHigh,
                child: Icon(Icons.image_not_supported, color: AppColors.outline),
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
                      colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
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
