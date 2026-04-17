import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:done_drop/core/theme/theme.dart';
import 'package:done_drop/core/constants/app_constants.dart';
import 'package:done_drop/app/core/widgets/widgets.dart';
import 'package:done_drop/features/auth/presentation/controllers/onboarding_controller.dart';

class OnboardingScreen extends GetView<OnboardingController> {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final spec = DDResponsiveSpec.of(context);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Page indicator
            Obx(
              () => Padding(
                padding: spec.pagePadding(
                  top: AppSizes.space20,
                  bottom: AppSizes.space20,
                ),
                child: Row(
                  children: List.generate(3, (i) {
                    return Expanded(
                      child: Container(
                        height: 3,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: i <= controller.currentPage.value
                              ? AppColors.primary
                              : AppColors.outlineVariant,
                          borderRadius: AppSizes.borderRadiusFull,
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
            Expanded(
              child: PageView(
                controller: controller.pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: controller.onPageChanged,
                children: [
                  const _WelcomePage(),
                  _UseCasePage(controller: controller),
                  const _PermissionsPage(),
                ],
              ),
            ),
            // CTA
            Padding(
              padding: spec.pagePadding(
                top: AppSizes.space16,
                bottom: AppSizes.space24,
              ),
              child: Obx(() {
                final page = controller.currentPage.value;
                return DDPrimaryButton(
                  label: page == 0
                      ? 'Get Started'
                      : page == 1
                      ? 'Continue'
                      : 'Done',
                  onPressed: controller.nextPage,
                  isExpanded: true,
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomePage extends StatelessWidget {
  const _WelcomePage();

  @override
  Widget build(BuildContext context) {
    final spec = DDResponsiveSpec.of(context);

    return DDResponsiveScrollBody(
      maxWidth: 560,
      padding: spec.pagePadding(
        top: spec.isShort ? AppSizes.space16 : AppSizes.space24,
        bottom: AppSizes.space16,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'DoneDrop',
              style: AppTypography.displayLarge(
                color: AppColors.primary,
              ).copyWith(fontStyle: FontStyle.italic, letterSpacing: -1),
            ),
            const SizedBox(height: AppSizes.space24),
            Text(
              'Hold yourself accountable.\nComplete your habits. Prove it.',
              textAlign: TextAlign.center,
              style: AppTypography.headlineMedium(color: AppColors.onSurface),
            ),
            const SizedBox(height: AppSizes.space16),
            Text(
              'Build habits. Complete them. Capture proof. Share privately with accountability partners.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UseCasePage extends StatelessWidget {
  const _UseCasePage({required this.controller});

  final OnboardingController controller;

  IconData _useCaseIcon(String key) {
    switch (key) {
      case 'personal':
        return Icons.person_outline;
      case 'with_friends':
        return Icons.people_outline;
      case 'couple':
        return Icons.favorite_outline;
      case 'squad':
        return Icons.celebration_outlined;
      default:
        return Icons.person_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final useCases = AppConstants.onboardingUseCases;
    final spec = DDResponsiveSpec.of(context);

    return DDResponsiveScrollBody(
      maxWidth: 760,
      padding: spec.pagePadding(
        top: AppSizes.space16,
        bottom: AppSizes.space16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WHAT BRINGS YOU HERE?',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.outline,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: AppSizes.space24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: ddAdaptiveGridDelegate(
              context,
              compactExtent: 180,
              mediumExtent: 220,
              expandedExtent: 240,
              mainAxisSpacing: AppSizes.space16,
              crossAxisSpacing: AppSizes.space16,
              childAspectRatio: 1.1,
            ),
            itemCount: useCases.length,
            itemBuilder: (context, index) {
              final uc = useCases[index];
              return GestureDetector(
                onTap: () {
                  controller.selectUseCase(uc['key'] as String);
                },
                child: Container(
                  padding: const EdgeInsets.all(AppSizes.space20),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: AppSizes.borderRadiusLg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        _useCaseIcon(uc['icon'] as String),
                        color: AppColors.primary,
                        size: 28,
                      ),
                      const SizedBox(height: AppSizes.space12),
                      Text(
                        uc['label'] as String,
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: AppColors.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Expanded(
                        child: Text(
                          uc['description'] as String,
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 12,
                            color: AppColors.onSurfaceVariant,
                            height: 1.35,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PermissionsPage extends StatelessWidget {
  const _PermissionsPage();

  @override
  Widget build(BuildContext context) {
    final spec = DDResponsiveSpec.of(context);

    return DDResponsiveScrollBody(
      maxWidth: 560,
      padding: spec.pagePadding(
        top: spec.isShort ? AppSizes.space16 : AppSizes.space24,
        bottom: AppSizes.space16,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryFixed,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.camera_alt_outlined,
                size: 36,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSizes.space32),
            Text(
              'Capture Your Proof',
              style: AppTypography.headlineMedium(color: AppColors.onSurface),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.space16),
            Text(
              'DoneDrop needs camera access to capture proof moments. Your photos stay private until you choose to share them.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: AppColors.onSurfaceVariant,
                height: 1.6,
              ),
            ),
            const SizedBox(height: AppSizes.space48),
            const _PermissionItem(
              icon: Icons.visibility_off_outlined,
              title: 'Private by default',
              desc: 'You control who sees your proof moments.',
            ),
            const SizedBox(height: AppSizes.space16),
            const _PermissionItem(
              icon: Icons.lock_outline,
              title: 'End-to-end secure',
              desc: 'Your accountability data stays yours.',
            ),
            const SizedBox(height: AppSizes.space16),
            const _PermissionItem(
              icon: Icons.notifications_outlined,
              title: 'Gentle reminders',
              desc: 'Optional nudges to complete your habits.',
            ),
          ],
        ),
      ),
    );
  }
}

class _PermissionItem extends StatelessWidget {
  const _PermissionItem({
    required this.icon,
    required this.title,
    required this.desc,
  });

  final IconData icon;
  final String title;
  final String desc;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: AppSizes.borderRadiusMd,
          ),
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),
        const SizedBox(width: AppSizes.space16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: AppColors.onSurface,
                ),
              ),
              Text(
                desc,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
