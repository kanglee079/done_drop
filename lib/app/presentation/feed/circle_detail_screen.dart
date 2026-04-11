import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:done_drop/core/theme/theme.dart';
import 'package:done_drop/app/routes/app_routes.dart';
import 'package:done_drop/app/presentation/feed/circle_detail_controller.dart';

/// DoneDrop Circle Detail Screen
class CircleDetailScreen extends StatelessWidget {
  const CircleDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CircleDetailController>(
      init: CircleDetailController(),
      builder: (ctrl) {
        return Scaffold(
          backgroundColor: AppColors.surface,
          appBar: AppBar(
            backgroundColor: AppColors.surface.withValues(alpha: 0.85),
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.primary),
              onPressed: () => Get.back(),
            ),
            title: Obx(() => Text(
              ctrl.circle.value?.name ?? 'Circle',
              style: TextStyle(
                fontFamily: AppTypography.serifFamily,
                fontSize: 18,
                fontStyle: FontStyle.italic,
                color: AppColors.primary,
              ),
            )),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.person_add_outlined, color: AppColors.primary),
                onPressed: () => Get.toNamed(
                  AppRoutes.invite,
                  arguments: {'circleId': ctrl.circleId.value},
                ),
              ),
            ],
          ),
          body: Obx(() {
            if (ctrl.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }
            final circle = ctrl.circle.value;
            if (circle == null) {
              return const Center(child: Text('Circle not found'));
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.space24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    circle.name,
                    style: TextStyle(
                      fontFamily: AppTypography.serifFamily,
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.italic,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.space16),
                  // Members row
                  if (ctrl.members.isNotEmpty) ...[
                    Text(
                      '${ctrl.members.length} member${ctrl.members.length != 1 ? 's' : ''}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSizes.space12),
                    SizedBox(
                      height: 48,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: ctrl.members.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (_, i) {
                          final member = ctrl.members[i];
                          return CircleAvatar(
                            radius: 24,
                            backgroundColor: AppColors.primaryFixed,
                            backgroundImage: member.avatarUrl != null
                                ? CachedNetworkImageProvider(member.avatarUrl!)
                                : null,
                            child: member.avatarUrl == null
                                ? Text(
                                    member.displayName.isNotEmpty
                                        ? member.displayName[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  )
                                : null,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: AppSizes.space24),
                  ],
                  // Moments
                  if (ctrl.moments.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSizes.space32),
                        child: Column(
                          children: [
                            Icon(Icons.photo_camera_outlined,
                                size: 48, color: AppColors.outline),
                            const SizedBox(height: AppSizes.space12),
                            Text(
                              'No moments shared yet',
                              style: TextStyle(
                                fontFamily: AppTypography.serifFamily,
                                fontSize: 16,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: AppSizes.space8),
                            Text(
                              'Be the first to share a moment with this circle.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.outline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 4,
                        mainAxisSpacing: 4,
                      ),
                      itemCount: ctrl.moments.length,
                      itemBuilder: (_, i) {
                        final m = ctrl.moments[i];
                        return ClipRRect(
                          borderRadius: AppSizes.borderRadiusSm,
                          child: CachedNetworkImage(
                            imageUrl: m.imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (_, __) =>
                                Container(color: AppColors.surfaceContainerHighest),
                            errorWidget: (_, __, ___) => Container(
                              color: AppColors.surfaceContainerHighest,
                              child: const Icon(Icons.broken_image, size: 20),
                            ),
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: AppSizes.space48),
                  // Leave circle button
                  TextButton.icon(
                    onPressed: ctrl.leaveCircle,
                    icon: const Icon(Icons.exit_to_app, color: AppColors.error),
                    label: Text('Leave Circle',
                        style: TextStyle(color: AppColors.error)),
                  ),
                ],
              ),
            );
          }),
        );
      },
    );
  }
}
