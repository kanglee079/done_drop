import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/theme.dart';
import '../../routes/app_routes.dart';
import '../capture/moment_controller.dart';
import '../home/navigation_controller.dart';

/// DoneDrop Success Screen — Moment posted (or queued) confirmation.
///
/// Shows different messaging based on:
/// - Proof moment: celebrates the discipline achievement
/// - Offline queue: warns that moment will appear after sync
class SuccessScreen extends StatefulWidget {
  const SuccessScreen({super.key});

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _scaleAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.elasticOut),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut),
    );
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Read proof/queued context from MomentController (shared across flow)
    MomentController? momentCtrl;
    try {
      momentCtrl = Get.find<MomentController>();
    } catch (_) {
      // Not found — navigated directly to success
    }

    final isProofMoment = momentCtrl?.isProofMoment ?? false;
    final wasOfflineQueued = momentCtrl?.wasOfflineQueued ?? false;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.space24),
          child: AnimatedBuilder(
            animation: _animCtrl,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnim.value,
                child: Transform.scale(
                  scale: _scaleAnim.value,
                  child: child,
                ),
              );
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                // Animated success icon
                _AnimatedSuccessIcon(isProofMoment: isProofMoment),

                const SizedBox(height: AppSizes.space24),

                // Title
                const Text(
                  'Moment Saved ✨',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppSizes.space12),

                // Subtitle
                const Text(
                  'Your discipline is growing. Stay consistent.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),

                // Offline queue notice
                if (wasOfflineQueued) ...[
                  const SizedBox(height: AppSizes.space16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.space16,
                      vertical: AppSizes.space12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: AppSizes.borderRadiusMd,
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.cloud_off_outlined,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Saved offline — will sync when you\'re back online.',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const Spacer(),

                // Primary action — Return Home
                GestureDetector(
                  onTap: () => Get.offAllNamed(AppRoutes.home),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: AppSizes.borderRadiusMd,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'Return Home',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSizes.space16),

                // Secondary action — View Buddy Feed
                TextButton(
                  onPressed: () {
                    Get.offAllNamed(AppRoutes.home);
                    final nav = Get.find<NavigationController>();
                    nav.setTab(1); // Set to Buddy Feed tab
                  },
                  child: const Text(
                    'View Buddy Feed',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),

                const SizedBox(height: AppSizes.space24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedSuccessIcon extends StatefulWidget {
  const _AnimatedSuccessIcon({required this.isProofMoment});
  final bool isProofMoment;

  @override
  State<_AnimatedSuccessIcon> createState() => _AnimatedSuccessIconState();
}

class _AnimatedSuccessIconState extends State<_AnimatedSuccessIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _circleAnim;
  late Animation<double> _iconAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _circleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
      ),
    );
    _iconAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.3, 1.0, curve: Curves.elasticOut),
      ),
    );
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.75 + (_circleAnim.value * 0.25),
          child: Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: AppColors.tertiaryFixed.withValues(alpha: _circleAnim.value),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Transform.scale(
                scale: _iconAnim.value,
                child: Icon(
                  widget.isProofMoment ? Icons.emoji_events : Icons.check_circle,
                  size: 48,
                  color: AppColors.onTertiaryFixed,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
