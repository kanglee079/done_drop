import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:done_drop/app/presentation/capture/moment_controller.dart';
import 'package:done_drop/app/presentation/home/navigation_controller.dart';
import 'package:done_drop/app/routes/app_routes.dart';
import 'package:done_drop/core/theme/theme.dart';

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
    Get.offAllNamed(AppRoutes.home);
  }

  void _openBuddy() {
    if (Get.isRegistered<MomentController>()) {
      Get.find<MomentController>().resetComposer();
    }
    Get.offAllNamed(AppRoutes.home);
    Get.find<NavigationController>().setTab(1);
  }

  @override
  Widget build(BuildContext context) {
    final submission = _submission;
    final isProofMoment = submission?.isProofMoment ?? false;
    final wasOfflineQueued = submission?.wasOfflineQueued ?? false;

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
                    wasOfflineQueued ? 'Saved for sync' : 'Moment saved',
                    textAlign: TextAlign.center,
                    style: AppTypography.headlineSmall(
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppSizes.space12),
                  Text(
                    isProofMoment
                        ? 'Habit completed. Proof captured.'
                        : 'A quiet proof of your effort.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyLarge(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSizes.space32),
                  FilledButton(
                    onPressed: _goHome,
                    child: const Text('Back to Today'),
                  ),
                  const SizedBox(height: AppSizes.space12),
                  TextButton(
                    onPressed: _openBuddy,
                    child: Text(
                      'Open Buddy',
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
