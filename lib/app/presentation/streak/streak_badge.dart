import 'package:flutter/material.dart';
import 'package:done_drop/core/models/streak.dart';
import 'package:done_drop/core/theme/theme.dart';
import 'package:done_drop/l10n/l10n.dart';

/// Enhanced streak badge with animated pulse, progress ring,
/// and milestone indicator for home screen.
class StreakBadge extends StatefulWidget {
  const StreakBadge({
    super.key,
    required this.streak,
    this.showProgress = false,
    this.size = BadgeSize.medium,
    this.onTap,
  });

  final int streak;
  final bool showProgress;
  final BadgeSize size;
  final VoidCallback? onTap;

  @override
  State<StreakBadge> createState() => _StreakBadgeState();
}

enum BadgeSize { small, medium, large }

class _StreakBadgeState extends State<StreakBadge>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _progressController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    if (widget.showProgress) {
      _progressController.forward();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  StreakMilestone? get _milestone => StreakMilestones.findForDays(widget.streak);
  StreakMilestone? get _nextMilestone => StreakMilestones.findNextForDays(widget.streak);
  bool get _isAtMilestone => _milestone != null;
  bool get _isLegendary => widget.streak >= 100;

  double get _progress {
    final next = _nextMilestone;
    if (next == null) return 1.0;
    final curr = _milestone;
    if (curr == null) {
      final firstMilestone = StreakMilestones.all.first;
      return widget.streak / firstMilestone.days;
    }
    return (widget.streak - curr.days) / (next.days - curr.days);
  }

  double get _size {
    switch (widget.size) {
      case BadgeSize.small: return 80;
      case BadgeSize.medium: return 120;
      case BadgeSize.large: return 160;
    }
  }

  Color get _primaryColor {
    if (_isLegendary) return const Color(0xFFFFD700);
    if (_isAtMilestone) return _milestone!.badgeColor;
    return const Color(0xFFFF6B35);
  }

  Color get _backgroundColor {
    if (_isLegendary) return const Color(0xFFFFFDE7);
    if (_isAtMilestone) return _milestone!.backgroundColor;
    return const Color(0xFFFFE8DD);
  }

  IconData get _icon {
    if (_isLegendary) return Icons.auto_awesome;
    if (_isAtMilestone) return _milestone!.icon;
    return Icons.local_fire_department;
  }

  @override
  Widget build(BuildContext context) {
    final labelSize = widget.size == BadgeSize.small ? 10.0 : (widget.size == BadgeSize.medium ? 12.0 : 14.0);
    final iconSize = widget.size == BadgeSize.small ? 16.0 : (widget.size == BadgeSize.medium ? 20.0 : 28.0);

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (_, child) {
          final glowSpread = _isAtMilestone ? (_pulseAnimation.value - 1.0) * 12 : 0.0;

          Widget badge = Container(
            width: _size,
            height: _size,
            decoration: BoxDecoration(
              color: _backgroundColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _primaryColor.withValues(alpha: 0.35),
                  blurRadius: _isAtMilestone ? 16 : 10,
                  spreadRadius: glowSpread,
                ),
                if (_isLegendary)
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (widget.showProgress)
                  SizedBox(
                    width: _size - 8,
                    height: _size - 8,
                    child: CircularProgressIndicator(
                      value: _progress.clamp(0.0, 1.0),
                      strokeWidth: widget.size == BadgeSize.small ? 2 : 3,
                      backgroundColor: _primaryColor.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
                    ),
                  ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_icon, color: _primaryColor, size: iconSize),
                    const SizedBox(height: 2),
                    Text(
                      '${widget.streak}',
                      style: TextStyle(
                        color: _primaryColor,
                        fontWeight: FontWeight.w900,
                        fontSize: labelSize + 4,
                      ),
                    ),
                    Text(
                      context.l10n.streakDaysUnit,
                      style: TextStyle(
                        color: _primaryColor.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w600,
                        fontSize: labelSize - 2,
                      ),
                    ),
                  ],
                ),
                if (_isAtMilestone)
                  Positioned(
                    top: widget.size == BadgeSize.small ? 4 : 8,
                    right: widget.size == BadgeSize.small ? 4 : 8,
                    child: Icon(
                      Icons.star,
                      color: _primaryColor,
                      size: widget.size == BadgeSize.small ? 10 : 14,
                    ),
                  ),
              ],
            ),
          );

          if (_isAtMilestone) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: badge,
            );
          }
          return badge;
        },
      ),
    );
  }
}

/// Small inline streak chip for activity items.
class StreakChip extends StatelessWidget {
  const StreakChip({
    super.key,
    required this.streak,
    this.isAtRisk = false,
  });

  final int streak;
  final bool isAtRisk;

  @override
  Widget build(BuildContext context) {
    if (streak <= 0) return const SizedBox.shrink();

    final color = isAtRisk ? AppColors.error : AppColors.primary;
    final icon = isAtRisk ? Icons.warning_amber : Icons.local_fire_department;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 3),
          Text(
            '$streak',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Progress indicator toward next milestone.
class MilestoneProgressBar extends StatelessWidget {
  const MilestoneProgressBar({
    super.key,
    required this.currentStreak,
    this.height = 8,
  });

  final int currentStreak;
  final double height;

  @override
  Widget build(BuildContext context) {
    final milestone = StreakMilestones.findNextForDays(currentStreak);
    if (milestone == null) return const SizedBox.shrink();

    final prev = StreakMilestones.findForDays(currentStreak);
    double progress;
    if (prev != null) {
      progress = (currentStreak - prev.days) / (milestone.days - prev.days);
    } else {
      final first = StreakMilestones.all.first;
      progress = currentStreak / first.days;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${currentStreak}d',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            Text(
              '${milestone.days}d',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: height,
            backgroundColor: AppColors.surfaceContainerHighest,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(milestone.icon, size: 12, color: milestone.badgeColor),
            const SizedBox(width: 4),
            Text(
              '${context.l10n.streakDaysToGo(milestone.days - currentStreak)} • ${milestone.localizedLabel(context.l10n)}',
              style: TextStyle(
                fontSize: 11,
                color: milestone.badgeColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
