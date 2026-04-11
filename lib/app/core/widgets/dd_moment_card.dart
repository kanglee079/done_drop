import 'package:flutter/material.dart';
import 'package:done_drop/app/core/widgets/dd_image.dart';
import 'package:done_drop/app/core/widgets/dd_avatar.dart';
import '../../../core/theme/theme.dart';

/// DoneDrop Moment Card — Primary card component for feed/memory wall
/// Matches the design: 4:5 aspect ratio, rounded-lg, no divider lines
class DDMomentCard extends StatelessWidget {
  const DDMomentCard({
    super.key,
    required this.imageUrl,
    this.caption,
    this.timeAgo,
    this.category,
    this.ownerName,
    this.ownerAvatar,
    this.onTap,
    this.onReactionTap,
    this.aspectRatio = 4 / 5,
  });

  final String imageUrl;
  final String? caption;
  final String? timeAgo;
  final String? category;
  final String? ownerName;
  final String? ownerAvatar;
  final VoidCallback? onTap;
  final VoidCallback? onReactionTap;
  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: AppSizes.borderRadiusLg,
          boxShadow: AppColors.cardShadow,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            AspectRatio(
              aspectRatio: aspectRatio,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  DDImage(
                    source: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: Container(
                      color: AppColors.surfaceContainerHigh,
                    ),
                    errorWidget: Container(
                      color: AppColors.surfaceContainerHigh,
                      child: const Icon(Icons.image_not_supported,
                          color: AppColors.outline),
                    ),
                  ),
                  // Time chip
                  if (timeAgo != null)
                    Positioned(
                      top: AppSizes.space16,
                      right: AppSizes.space16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.space12,
                          vertical: AppSizes.space4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.tertiaryFixed.withValues(alpha: 0.9),
                          borderRadius: AppSizes.borderRadiusFull,
                        ),
                        child: Text(
                          timeAgo!,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onTertiaryFixed,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  // Category chip
                  if (category != null)
                    Positioned(
                      top: AppSizes.space16,
                      right: AppSizes.space16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.space12,
                          vertical: AppSizes.space4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.tertiaryFixed.withValues(alpha: 0.9),
                          borderRadius: AppSizes.borderRadiusFull,
                        ),
                        child: Text(
                          category!,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onTertiaryFixed,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Caption & footer
            Padding(
              padding: const EdgeInsets.all(AppSizes.space16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (caption != null && caption!.isNotEmpty) ...[
                    Text(
                      '"$caption"',
                      style: TextStyle(
                        fontFamily: AppTypography.serifFamily,
                        fontSize: 18,
                        fontStyle: FontStyle.italic,
                        color: AppColors.onSurface,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: AppSizes.space12),
                  ],
                  if (ownerName != null)
                    Row(
                      children: [
                        if (ownerAvatar != null)
                          Container(
                            width: 24,
                            height: 24,
                            margin: const EdgeInsets.only(right: AppSizes.space8),
                            child: DDAvatar(
                              imageUrl: ownerAvatar,
                              size: 24,
                            ),
                          ),
                        Expanded(
                          child: Text(
                            ownerName!,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
