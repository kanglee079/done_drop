import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../../../core/constants/app_constants.dart';

/// DoneDrop Reaction Button — Like/celebrate/inspiring
class DDReactionButton extends StatelessWidget {
  const DDReactionButton({
    super.key,
    required this.type,
    this.isActive = false,
    this.onTap,
    this.showLabel = false,
  });

  final String type;
  final bool isActive;
  final VoidCallback? onTap;
  final bool showLabel;

  static const _reactionConfig = {
    'love': ('❤️', 'Love'),
    'celebrate': ('🙌', 'Celebrate'),
    'inspiring': ('✨', 'Inspiring'),
  };

  @override
  Widget build(BuildContext context) {
    final config = _reactionConfig[type] ?? ('❤️', type);
    final label = showLabel ? config.$2 : null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.space8),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primaryFixed
              : AppColors.surfaceContainerLow,
          borderRadius: AppSizes.borderRadiusFull,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              config.$1,
              style: const TextStyle(fontSize: 18),
            ),
            if (label != null) ...[
              const SizedBox(width: AppSizes.space4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isActive
                      ? AppColors.primary
                      : AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// DoneDrop Reaction Row — Row of reaction buttons
class DDReactionRow extends StatelessWidget {
  const DDReactionRow({
    super.key,
    required this.activeReactions,
    required this.reactionCounts,
    this.onReactionTap,
  });

  final List<String> activeReactions;
  final Map<String, int> reactionCounts;
  final Function(String type)? onReactionTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: AppConstants.reactionTypes.map((type) {
        final count = reactionCounts[type] ?? 0;
        return Padding(
          padding: const EdgeInsets.only(right: AppSizes.space8),
          child: GestureDetector(
            onTap: () => onReactionTap?.call(type),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.space12,
                vertical: AppSizes.space8,
              ),
              decoration: BoxDecoration(
                color: activeReactions.contains(type)
                    ? AppColors.primaryFixed
                    : AppColors.surfaceContainerLow,
                borderRadius: AppSizes.borderRadiusFull,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _emojiFor(type),
                    style: const TextStyle(fontSize: 16),
                  ),
                  if (count > 0) ...[
                    const SizedBox(width: AppSizes.space4),
                    Text(
                      '$count',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: activeReactions.contains(type)
                            ? AppColors.primary
                            : AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  static String _emojiFor(String type) {
    return switch (type) {
      'love' => '❤️',
      'celebrate' => '🙌',
      'inspiring' => '✨',
      _ => '❤️',
    };
  }
}
