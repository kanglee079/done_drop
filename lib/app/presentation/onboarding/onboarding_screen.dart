import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:done_drop/core/theme/theme.dart';
import 'package:done_drop/app/core/widgets/widgets.dart';
import 'package:done_drop/features/auth/presentation/controllers/onboarding_controller.dart';

class OnboardingScreen extends GetView<OnboardingController> {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Page indicator
            Obx(() => Padding(
                  padding: const EdgeInsets.all(AppSizes.space24),
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
                )),
            Expanded(
              child: PageView(
                controller: controller.pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: controller.onPageChanged,
                children: [
                  _WelcomePage(),
                  _UseCasePage(controller: controller),
                  _PermissionsPage(),
                ],
              ),
            ),
            // CTA
            Padding(
              padding: const EdgeInsets.all(AppSizes.space24),
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
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.space24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'DoneDrop',
            style: AppTypography.displayLarge(color: AppColors.primary).copyWith(
              fontStyle: FontStyle.italic,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: AppSizes.space24),
          Text(
            'Life is a collection of done moments.',
            textAlign: TextAlign.center,
            style: AppTypography.headlineMedium(color: AppColors.onSurface),
          ),
          const SizedBox(height: AppSizes.space16),
          Text(
            'A curated space to preserve the small wins, the big adventures, and everything that matters in between.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _UseCasePage extends StatelessWidget {
  const _UseCasePage({required this.controller});

  final OnboardingController controller;

  @override
  Widget build(BuildContext context) {
    final useCases = const [
      {
        'key': 'personal',
        'label': 'Personal',
        'desc': 'A private journal for you.',
        'icon': Icons.person_outline,
      },
      {
        'key': 'couple',
        'label': 'Couple',
        'desc': 'Shared moments for two.',
        'icon': Icons.favorite_outline,
      },
      {
        'key': 'friends',
        'label': 'Friends',
        'desc': 'Close circles only.',
        'icon': Icons.groups_outlined,
      },
      {
        'key': 'squad',
        'label': 'Squad',
        'desc': 'For your accountability circle.',
        'icon': Icons.celebration_outlined,
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSizes.space24),
          Text(
            'WHO ARE YOU SHARING WITH?',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.outline,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: AppSizes.space24),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: AppSizes.space16,
              crossAxisSpacing: AppSizes.space16,
              childAspectRatio: 1.1,
              children: useCases.map((uc) {
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
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          uc['icon'] as IconData,
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Flexible(
                          child: Text(
                            uc['desc'] as String,
                            style: const TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 12,
                              color: AppColors.onSurfaceVariant,
                              height: 1.35,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _PermissionsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.space24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primaryFixed,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.camera_alt_outlined, size: 36, color: AppColors.primary),
          ),
          const SizedBox(height: AppSizes.space32),
          Text(
            'Camera Access',
            style: AppTypography.headlineMedium(color: AppColors.onSurface),
          ),
          const SizedBox(height: AppSizes.space16),
          Text(
            'DoneDrop needs camera access to capture your moments. Your photos are private and only shared with the circles you choose.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: AppColors.onSurfaceVariant,
              height: 1.6,
            ),
          ),
          const SizedBox(height: AppSizes.space48),
          _PermissionItem(
            icon: Icons.visibility_off_outlined,
            title: 'Private by default',
            desc: 'You control who sees your moments.',
          ),
          const SizedBox(height: AppSizes.space16),
          _PermissionItem(
            icon: Icons.lock_outline,
            title: 'End-to-end secure',
            desc: 'Your memories stay yours.',
          ),
          const SizedBox(height: AppSizes.space16),
          _PermissionItem(
            icon: Icons.notifications_outlined,
            title: 'Gentle reminders',
            desc: 'Optional nudges to capture your day.',
          ),
        ],
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
