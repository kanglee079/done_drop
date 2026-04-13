import 'dart:math';
import 'package:flutter/material.dart';

/// Confetti particle for milestone celebrations.
class ConfettiParticle {
  ConfettiParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.color,
    required this.size,
    required this.rotation,
    required this.rotationSpeed,
    required this.shape,
    this.opacity = 1.0,
    this.gravity = 0.15,
  });

  double x;
  double y;
  double vx;
  double vy;
  final Color color;
  double size;
  double rotation;
  double rotationSpeed;
  final ConfettiShape shape;
  double opacity;
  double gravity;

  factory ConfettiParticle.random(Random rng, Size canvasSize) {
    final colors = [
      const Color(0xFFFF6B35),
      const Color(0xFFFF9500),
      const Color(0xFFFFD700),
      const Color(0xFF4CAF50),
      const Color(0xFF2196F3),
      const Color(0xFFE91E63),
      const Color(0xFF9C27B0),
      const Color(0xFF00BCD4),
      const Color(0xFFFF5722),
      const Color(0xFF8BC34A),
    ];

    final shapeValues = ConfettiShape.values;
    final shape = shapeValues[rng.nextInt(shapeValues.length)];

    final centerX = canvasSize.width / 2;
    return ConfettiParticle(
      x: centerX + (rng.nextDouble() - 0.5) * canvasSize.width * 0.4,
      y: canvasSize.height * 0.45,
      vx: (rng.nextDouble() - 0.5) * 6,
      vy: -(rng.nextDouble() * 8 + 4),
      color: colors[rng.nextInt(colors.length)],
      size: rng.nextDouble() * 6 + 4,
      rotation: rng.nextDouble() * 2 * pi,
      rotationSpeed: (rng.nextDouble() - 0.5) * 0.3,
      shape: shape,
      opacity: 1.0,
      gravity: 0.15 + rng.nextDouble() * 0.05,
    );
  }
}

enum ConfettiShape { circle, square, rectangle, triangle, star }

/// Confetti animation overlay widget.
class ConfettiOverlay extends StatefulWidget {
  const ConfettiOverlay({
    super.key,
    required this.child,
    this.autoTrigger = false,
    this.particleCount = 80,
  });

  final Widget child;
  final bool autoTrigger;
  final int particleCount;

  @override
  State<ConfettiOverlay> createState() => ConfettiOverlayState();
}

class ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<ConfettiParticle> _particles = [];
  final Random _rng = Random();
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    );
    _controller.addListener(_updateParticles);
    if (widget.autoTrigger) {
      WidgetsBinding.instance.addPostFrameCallback((_) => fire());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void fire() {
    if (_isAnimating) return;
    _particles.clear();
    _isAnimating = true;
    _controller.forward(from: 0);
  }

  void _updateParticles() {
    if (!mounted) return;

    final canvasSize = context.size ?? const Size(400, 800);

    if (_particles.isEmpty) {
      for (int i = 0; i < widget.particleCount; i++) {
        _particles.add(ConfettiParticle.random(_rng, canvasSize));
      }
    }

    for (final p in _particles) {
      p.x += p.vx;
      p.y += p.vy;
      p.vy += p.gravity;
      p.vx *= 0.99;
      p.rotation += p.rotationSpeed;
      p.opacity = (1.0 - _controller.value).clamp(0.0, 1.0);
    }

    if (_controller.value >= 1.0) {
      setState(() {
        _particles.clear();
        _isAnimating = false;
      });
    } else {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_isAnimating && _particles.isNotEmpty)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _ConfettiPainter(particles: _particles),
              ),
            ),
          ),
      ],
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.particles});
  final List<ConfettiParticle> particles;

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      if (p.opacity <= 0) continue;
      final paint = Paint()
        ..color = p.color.withValues(alpha: p.opacity)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(p.x, p.y);
      canvas.rotate(p.rotation);

      switch (p.shape) {
        case ConfettiShape.circle:
          canvas.drawCircle(Offset.zero, p.size, paint);
          break;
        case ConfettiShape.square:
          canvas.drawRect(
            Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size),
            paint,
          );
          break;
        case ConfettiShape.rectangle:
          canvas.drawRect(
            Rect.fromCenter(center: Offset.zero, width: p.size * 1.5, height: p.size * 0.6),
            paint,
          );
          break;
        case ConfettiShape.triangle:
          final path = Path()
            ..moveTo(0, -p.size)
            ..lineTo(p.size, p.size)
            ..lineTo(-p.size, p.size)
            ..close();
          canvas.drawPath(path, paint);
          break;
        case ConfettiShape.star:
          _drawStar(canvas, p.size, paint);
          break;
      }

      canvas.restore();
    }
  }

  void _drawStar(Canvas canvas, double size, Paint paint) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final angle = (i * 4 * pi / 5) - pi / 2;
      final x = cos(angle) * size;
      final y = sin(angle) * size;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) => true;
}
