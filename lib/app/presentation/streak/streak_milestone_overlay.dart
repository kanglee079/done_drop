import 'dart:math';
import 'package:flutter/material.dart';
import 'package:done_drop/core/models/streak.dart';
import 'package:done_drop/core/widgets/confetti_overlay.dart';

/// Full-screen celebration overlay when a streak milestone is reached.
class StreakMilestoneOverlay extends StatefulWidget {
  const StreakMilestoneOverlay({
    super.key,
    required this.milestone,
    required this.activityTitle,
    required this.previousStreak,
    required this.newStreak,
    required this.onDismiss,
  });

  final StreakMilestone milestone;
  final String activityTitle;
  final int previousStreak;
  final int newStreak;
  final VoidCallback onDismiss;

  @override
  State<StreakMilestoneOverlay> createState() => _StreakMilestoneOverlayState();
}

class _StreakMilestoneOverlayState extends State<StreakMilestoneOverlay>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _particleController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _glowAnimation;

  final GlobalKey<ConfettiOverlayState> _confettiKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _particleController = AnimationController(
      duration: const Duration(milliseconds: 3500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _rotateAnimation = Tween<double>(begin: -0.5, end: 0.0).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 60.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
      ),
    );

    _scaleController.forward();
    _confettiKey.currentState?.fire();

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _confettiKey.currentState?.fire();
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  void _dismiss() {
    _scaleController.reverse().then((_) {
      widget.onDismiss();
    });
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.milestone;
    final isLegendary = m.days >= 100;

    return Material(
      color: Colors.black.withValues(alpha: 0.75),
      child: ConfettiOverlay(
        key: _confettiKey,
        particleCount: isLegendary ? 120 : 80,
        child: SafeArea(
          child: Stack(
            children: [
              GestureDetector(
                onTap: _dismiss,
                behavior: HitTestBehavior.opaque,
                child: const SizedBox.expand(),
              ),
              Center(
                child: AnimatedBuilder(
                  animation: _scaleController,
                  builder: (_, __) {
                    return Transform.scale(
                      scale: _scaleAnimation.value.clamp(0.0, 1.0),
                      child: Transform.rotate(
                        angle: _rotateAnimation.value * pi / 6,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _TrophyIcon(
                              milestone: m,
                              glowAnimation: _glowAnimation,
                              isLegendary: isLegendary,
                            ),
                            SizedBox(height: 16 + _slideAnimation.value),
                            if (_slideAnimation.value < 30) ...[
                              _buildTitle(m),
                              const SizedBox(height: 8),
                              _buildSubtitle(),
                              const SizedBox(height: 12),
                              _buildStreakCounter(),
                              const SizedBox(height: 32),
                              _buildDismissButton(),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                top: 20,
                right: 16,
                child: IconButton(
                  onPressed: _dismiss,
                  icon: const Icon(Icons.close, color: Colors.white70),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(StreakMilestone m) {
    return Column(
      children: [
        Text(
          '🎉 MILESTONE REACHED!',
          style: TextStyle(
            color: m.badgeColor,
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            shadows: [
              Shadow(
                color: m.glowColor.withValues(alpha: 0.5),
                blurRadius: 10,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          m.label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildSubtitle() {
    return Text(
      widget.activityTitle,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.8),
        fontSize: 14,
        fontStyle: FontStyle.italic,
      ),
    );
  }

  Widget _buildStreakCounter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: widget.milestone.badgeColor.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            widget.milestone.icon,
            color: widget.milestone.badgeColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            '${widget.newStreak} days',
            style: TextStyle(
              color: widget.milestone.badgeColor,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDismissButton() {
    return TextButton(
      onPressed: _dismiss,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
        backgroundColor: Colors.white.withValues(alpha: 0.15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: const Text(
        'Keep Going!',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _TrophyIcon extends StatelessWidget {
  const _TrophyIcon({
    required this.milestone,
    required this.glowAnimation,
    required this.isLegendary,
  });

  final StreakMilestone milestone;
  final Animation<double> glowAnimation;
  final bool isLegendary;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: glowAnimation,
      builder: (_, __) {
        final glowRadius = 20 + (glowAnimation.value * 20);
        final glowOpacity = 0.3 + (glowAnimation.value * 0.4);

        return Container(
          width: isLegendary ? 140 : 110,
          height: isLegendary ? 140 : 110,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                milestone.backgroundColor,
                milestone.glowColor.withValues(alpha: 0.3),
                Colors.transparent,
              ],
              stops: const [0.3, 0.6, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: milestone.glowColor.withValues(alpha: glowOpacity),
                blurRadius: glowRadius,
                spreadRadius: glowRadius * 0.3,
              ),
              if (isLegendary)
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.3),
                  blurRadius: glowRadius * 1.5,
                  spreadRadius: glowRadius * 0.5,
                ),
            ],
          ),
          child: Center(
            child: Icon(
              milestone.icon,
              color: milestone.badgeColor,
              size: isLegendary ? 70 : 55,
            ),
          ),
        );
      },
    );
  }
}