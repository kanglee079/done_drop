import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:done_drop/core/theme/theme.dart';
import 'package:done_drop/app/core/widgets/widgets.dart';
import 'package:done_drop/app/presentation/feed/feed_controller.dart';
import 'package:done_drop/app/presentation/feed/reaction_controller.dart';

/// DoneDrop Feed Screen — Circle feed view
class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FeedController>(
      init: FeedController(),
      builder: (ctrl) {
        return Scaffold(
          backgroundColor: AppColors.surface,
          appBar: AppBar(
            backgroundColor: AppColors.surface.withValues(alpha: 0.85),
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: CircleAvatar(
                backgroundColor: AppColors.surfaceContainerHigh,
                child: const Icon(Icons.person, color: AppColors.primary),
              ),
            ),
            title: Text(
              'DoneDrop',
              style: TextStyle(
                fontFamily: AppTypography.serifFamily,
                fontSize: 20,
                fontStyle: FontStyle.italic,
                color: AppColors.primary,
              ),
            ),
            centerTitle: true,
          ),
          body: Obx(() {
            if (ctrl.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }
            if (ctrl.circles.isEmpty) {
              return const Center(
                child: DDEmptyState(
                  title: 'No Circles Yet',
                  description: 'Create or join a circle to see shared moments here.',
                  icon: Icons.group_outlined,
                ),
              );
            }
            if (ctrl.moments.isEmpty) {
              return const Center(
                child: DDEmptyState(
                  title: 'Circle Feed',
                  description: 'Shared moments from your circles will appear here.',
                  icon: Icons.group_outlined,
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.space12),
              itemCount: ctrl.moments.length,
              itemBuilder: (ctx, i) {
                final moment = ctrl.moments[i];
                return _MomentTile(moment: moment);
              },
            );
          }),
        );
      },
    );
  }
}

class _MomentTile extends StatelessWidget {
  const _MomentTile({required this.moment});
  final dynamic moment;

  @override
  Widget build(BuildContext context) {
    final reactionCtrl = Get.find<ReactionController>();
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSizes.space16,
        vertical: AppSizes.space8,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: AppSizes.borderRadiusLg,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          AspectRatio(
            aspectRatio: 1,
            child: CachedNetworkImage(
              imageUrl: moment.imageUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                color: AppColors.surfaceContainerHighest,
              ),
              errorWidget: (_, __, ___) => Container(
                color: AppColors.surfaceContainerHighest,
                child: const Icon(Icons.broken_image, color: AppColors.outline),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSizes.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (moment.caption.isNotEmpty) ...[
                  Text(
                    moment.caption,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.onSurface,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: AppSizes.space12),
                ],
                // Reaction bar
                Row(
                  children: [
                    ...reactionCtrl.reactionTypes.map((type) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => reactionCtrl.toggleReaction(
                          momentId: moment.id,
                          reactionType: type,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHighest,
                            borderRadius: AppSizes.borderRadiusFull,
                          ),
                          child: Text(
                            reactionCtrl.reactionIcon(type),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    )),
                    const Spacer(),
                    Text(
                      _timeAgo(moment.createdAt),
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.outline,
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
