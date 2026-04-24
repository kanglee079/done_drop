import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:done_drop/app/presentation/capture/moment_controller.dart';
import 'package:done_drop/app/presentation/home/navigation_controller.dart';
import 'package:done_drop/app/routes/app_routes.dart';
import 'package:done_drop/core/theme/theme.dart';
import 'package:done_drop/l10n/l10n.dart';

class SuccessScreen extends StatefulWidget {
  const SuccessScreen({super.key});

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen>
    with TickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final AnimationController _fadeController;
  late final AnimationController _particleController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _slideAnimation;

  MomentSubmissionResult? get _submission {
    if (!Get.isRegistered<MomentController>()) return null;
    return Get.find<MomentController>().lastSubmission.value;
  }

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.elasticOut,
      ),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeOut,
      ),
    );
    _slideAnimation = Tween<double>(begin: 24, end: 0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Staggered animation sequence.
    _scaleController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _fadeController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _particleController.forward();
    });

    HapticFeedback.heavyImpact();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  void _goHome() {
    if (Get.isRegistered<MomentController>()) {
      Get.find<MomentController>().resetComposer();
    }
    _returnToHome();
  }

  void _openBuddy() {
    if (Get.isRegistered<MomentController>()) {
      Get.find<MomentController>().resetComposer();
    }
    _returnToHome(tabIndex: 1);
  }

  void _returnToHome({int? tabIndex}) {
    var foundHome = false;
    Get.until((route) {
      final isHome = route.settings.name == AppRoutes.home;
      if (isHome) {
        foundHome = true;
      }
      return isHome;
    });

    if (!foundHome) {
      Get.offAllNamed(AppRoutes.home);
    }

    if (tabIndex != null) {
      Future<void>.microtask(() {
        if (Get.isRegistered<NavigationController>()) {
          Get.find<NavigationController>().setTab(tabIndex);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final submission = _submission;
    final isProofMoment = submission?.isProofMoment ?? false;
    final wasOfflineQueued = submission?.wasOfflineQueued ?? false;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _scaleAnimation,
            _fadeAnimation,
            _slideAnimation,
          ]),
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _slideAnimation.value),
              child: Opacity(
                opacity: _fadeAnimation.value,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacer(flex: 2),
                    // Checkmark icon with scale animation.
                    Center(
                      child: Transform.scale(
                        scale: _scaleAnimation.value,
                        child: _SuccessIcon(
                          isOfflineQueued: wasOfflineQueued,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSizes.space32),
                    // Title.
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.space32,
                      ),
                      child: Text(
                        wasOfflineQueued
                            ? l10n.savedForSyncTitle
                            : l10n.momentSavedTitle,
                        textAlign: TextAlign.center,
                        style: AppTypography.headlineMedium(
                          color: AppColors.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSizes.space12),
                    // Subtitle.
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.space32,
                      ),
                      child: Text(
                        isProofMoment
                            ? l10n.proofCapturedMessage
                            : l10n.quietProofMessage,
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyLarge(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const Spacer(flex: 1),
                    // CTA buttons.
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.space32,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          FilledButton(
                            onPressed: _goHome,
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSizes.space16,
                              ),
                            ),
                            child: Text(
                              wasOfflineQueued
                                  ? l10n.backToTodayAction
                                  : l10n.backToTodayAction,
                            ),
                          ),
                          if (!wasOfflineQueued) ...[
                            const SizedBox(height: AppSizes.space12),
                            OutlinedButton(
                              onPressed: _openBuddy,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppSizes.space16,
                                ),
                              ),
                              child: Text(l10n.openBuddyAction),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSizes.space48),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Animated success icon — expands from checkmark with a colored background.
class _SuccessIcon extends StatelessWidget {
  const _SuccessIcon({required this.isOfflineQueued});

  final bool isOfflineQueued;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 112,
      height: 112,
      decoration: BoxDecoration(
        gradient: isOfflineQueued
            ? const LinearGradient(
                colors: [Color(0xFF6B9EFF), Color(0xFF4A7FE0)],
              )
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.primaryContainer],
              ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: (isOfflineQueued
                    ? const Color(0xFF6B9EFF)
                    : AppColors.primary)
                .withValues(alpha: 0.28),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: Icon(
            isOfflineQueued ? Icons.cloud_done_outlined : Icons.check_rounded,
            key: ValueKey(isOfflineQueued),
            color: AppColors.onPrimary,
            size: 52,
          ),
        ),
      ),
    );
  }
}
