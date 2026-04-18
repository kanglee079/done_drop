import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:done_drop/core/theme/theme.dart';
import 'package:done_drop/core/constants/app_constants.dart';
import 'package:done_drop/app/core/widgets/widgets.dart';
import 'package:done_drop/features/auth/presentation/controllers/onboarding_controller.dart';
import 'package:done_drop/core/services/locale_controller.dart';
import 'package:done_drop/l10n/l10n.dart';

class OnboardingScreen extends GetView<OnboardingController> {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final spec = DDResponsiveSpec.of(context);
    final l10n = context.l10n;
    final localeController = Get.isRegistered<LocaleController>()
        ? Get.find<LocaleController>()
        : null;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            Obx(
              () => Padding(
                padding: spec.pagePadding(
                  top: AppSizes.space20,
                  bottom: AppSizes.space20,
                ),
                child: Row(
                  children: [
                    Expanded(
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
                    if (localeController != null)
                      PopupMenuButton<String>(
                        initialValue: localeController.currentLanguageCode,
                        onSelected: localeController.setLocaleCode,
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'en',
                            child: Text(l10n.languageEnglish),
                          ),
                          PopupMenuItem(
                            value: 'vi',
                            child: Text(l10n.languageVietnamese),
                          ),
                        ],
                        icon: const Icon(
                          Icons.language_rounded,
                          color: AppColors.primary,
                        ),
                      ),
                  ],
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
            Padding(
              padding: spec.pagePadding(
                top: AppSizes.space16,
                bottom: AppSizes.space24,
              ),
              child: Obx(() {
                final page = controller.currentPage.value;
                return DDPrimaryButton(
                  label: page == 0
                      ? l10n.welcomeGetStarted
                      : page == 1
                      ? l10n.welcomeContinue
                      : l10n.welcomeDone,
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
    final l10n = context.l10n;

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
              l10n.appName,
              style: AppTypography.displayLarge(
                color: AppColors.primary,
              ).copyWith(fontStyle: FontStyle.italic, letterSpacing: -1),
            ),
            const SizedBox(height: AppSizes.space24),
            Text(
              l10n.onboardingHeadline,
              textAlign: TextAlign.center,
              style: AppTypography.headlineMedium(color: AppColors.onSurface),
            ),
            const SizedBox(height: AppSizes.space16),
            Text(
              l10n.onboardingSubtitle,
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
    final l10n = context.l10n;

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
            l10n.onboardingUseCaseTitle,
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
    final l10n = context.l10n;

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
              l10n.captureProofTitle,
              style: AppTypography.headlineMedium(color: AppColors.onSurface),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.space16),
            Text(
              l10n.captureProofSubtitle,
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
              title: l10n.privateByDefault,
              desc: l10n.privateByDefaultDesc,
            ),
            const SizedBox(height: AppSizes.space16),
            _PermissionItem(
              icon: Icons.lock_outline,
              title: l10n.secureByDefault,
              desc: l10n.secureByDefaultDesc,
            ),
            const SizedBox(height: AppSizes.space16),
            _PermissionItem(
              icon: Icons.notifications_outlined,
              title: l10n.gentleRemindersTitle,
              desc: l10n.gentleRemindersDesc,
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
