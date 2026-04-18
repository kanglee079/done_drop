import 'package:flutter/material.dart';

import 'package:done_drop/core/constants/app_constants.dart';
import 'package:done_drop/core/theme/theme.dart';
import 'package:done_drop/l10n/l10n.dart';

class DDAnimatedReactionChip extends StatefulWidget {
  const DDAnimatedReactionChip({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.count,
    required this.isActive,
    this.isBusy = false,
    this.onTap,
    this.compact = false,
  });

  final IconData icon;
  final String label;
  final Color color;
  final int count;
  final bool isActive;
  final bool isBusy;
  final VoidCallback? onTap;
  final bool compact;

  @override
  State<DDAnimatedReactionChip> createState() => _DDAnimatedReactionChipState();
}

class _DDAnimatedReactionChipState extends State<DDAnimatedReactionChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1, end: 1.08).chain(
          CurveTween(curve: Curves.easeOutCubic),
        ),
        weight: 45,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.08, end: 0.98).chain(
          CurveTween(curve: Curves.easeInOut),
        ),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.98, end: 1).chain(
          CurveTween(curve: Curves.easeOutBack),
        ),
        weight: 30,
      ),
    ]).animate(_controller);
  }

  @override
  void didUpdateWidget(covariant DDAnimatedReactionChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isActive && widget.isActive) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeBackground = widget.color.withValues(alpha: 0.12);
    final idleBackground = AppColors.surfaceContainerLow;
    final labelStyle = widget.compact
        ? AppTypography.bodySmall(color: AppColors.onSurface)
        : AppTypography.labelMedium(color: AppColors.onSurface);

    return ScaleTransition(
      scale: _scale,
      child: AnimatedOpacity(
        duration: AppMotion.fast,
        opacity: widget.isBusy ? 0.72 : 1,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: AppSizes.borderRadiusFull,
            onTap: widget.isBusy ? null : widget.onTap,
            child: AnimatedContainer(
              duration: AppMotion.fast,
              curve: AppMotion.standard,
              padding: EdgeInsets.symmetric(
                horizontal: widget.compact
                    ? AppSizes.space10
                    : AppSizes.space12,
                vertical: widget.compact ? AppSizes.space8 : AppSizes.space10,
              ),
              decoration: BoxDecoration(
                color: widget.isActive ? activeBackground : idleBackground,
                borderRadius: AppSizes.borderRadiusFull,
                border: Border.all(
                  color: widget.isActive
                      ? widget.color.withValues(alpha: 0.22)
                      : AppColors.outlineVariant,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.icon,
                    size: widget.compact ? 16 : 18,
                    color: widget.isActive ? widget.color : AppColors.outline,
                  ),
                  if (widget.label.isNotEmpty) ...[
                    const SizedBox(width: AppSizes.space6),
                    Text(
                      widget.label,
                      style: labelStyle.copyWith(
                        color: widget.isActive
                            ? widget.color
                            : AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                  if (widget.count > 0) ...[
                    const SizedBox(width: AppSizes.space6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.space6,
                        vertical: AppSizes.space2,
                      ),
                      decoration: BoxDecoration(
                        color: widget.isActive
                            ? widget.color.withValues(alpha: 0.18)
                            : AppColors.surfaceContainerHighest,
                        borderRadius: AppSizes.borderRadiusFull,
                      ),
                      child: Text(
                        '${widget.count}',
                        style: AppTypography.bodySmall(
                          color: widget.isActive
                              ? widget.color
                              : AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Legacy reaction button retained for non-feed surfaces that still use it.
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

  @override
  Widget build(BuildContext context) {
    final (icon, label, color) = _reactionConfig(context, type);

    return DDAnimatedReactionChip(
      icon: icon,
      label: showLabel ? label : '',
      color: color,
      count: 0,
      isActive: isActive,
      onTap: onTap,
      compact: true,
    );
  }
}

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
    return Wrap(
      spacing: AppSizes.space8,
      runSpacing: AppSizes.space8,
      children: AppConstants.reactionTypes.map((type) {
        final (icon, label, color) = _reactionConfig(context, type);
        return DDAnimatedReactionChip(
          icon: icon,
          label: label,
          color: color,
          count: reactionCounts[type] ?? 0,
          isActive: activeReactions.contains(type),
          onTap: () => onReactionTap?.call(type),
          compact: true,
        );
      }).toList(),
    );
  }
}

(IconData, String, Color) _reactionConfig(BuildContext context, String type) {
  final l10n = context.l10n;
  switch (type) {
    case 'love':
      return (
        Icons.favorite_rounded,
        l10n.reactionLoveLabel,
        const Color(0xFFE2497A),
      );
    case 'celebrate':
      return (
        Icons.celebration_rounded,
        l10n.reactionCelebrateLabel,
        const Color(0xFFF2994A),
      );
    case 'inspiring':
      return (
        Icons.auto_awesome_rounded,
        l10n.reactionInspiringLabel,
        AppColors.tertiary,
      );
    default:
      return (
        Icons.thumb_up_alt_rounded,
        l10n.reactionLoveLabel,
        AppColors.primary,
      );
  }
}
