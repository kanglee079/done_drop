import 'package:flutter/material.dart';
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
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  MomentSubmissionResult? get _submission {
    if (!Get.isRegistered<MomentController>()) return null;
    return Get.find<MomentController>().lastSubmission.value;
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: AppMotion.slow,
    )..forward();
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _scaleAnimation = Tween<double>(begin: 0.92, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
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
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.space24),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(),
                  Container(
                    width: 96,
                    height: 96,
                    margin: const EdgeInsets.symmetric(horizontal: 96),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryContainer],
                      ),
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: AppColors.elevatedShadow,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: AppColors.onPrimary,
                      size: 46,
                    ),
                  ),
                  const SizedBox(height: AppSizes.space24),
                  Text(
                    wasOfflineQueued
                        ? l10n.savedForSyncTitle
                        : l10n.momentSavedTitle,
                    textAlign: TextAlign.center,
                    style: AppTypography.headlineSmall(
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppSizes.space12),
                  Text(
                    isProofMoment
                        ? l10n.proofCapturedMessage
                        : l10n.quietProofMessage,
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyLarge(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSizes.space32),
                  FilledButton(
                    onPressed: _goHome,
                    child: Text(l10n.backToTodayAction),
                  ),
                  const SizedBox(height: AppSizes.space12),
                  TextButton(
                    onPressed: _openBuddy,
                    child: Text(
                      l10n.openBuddyAction,
                      style: AppTypography.labelLarge(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
