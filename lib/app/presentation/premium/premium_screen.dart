import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:done_drop/app/core/widgets/widgets.dart';
import 'package:done_drop/core/theme/theme.dart';
import 'package:done_drop/app/presentation/premium/premium_controller.dart';
import 'package:done_drop/l10n/l10n.dart';

/// DoneDrop Premium Screen
class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return GetBuilder<PremiumController>(
      init: PremiumController(),
      builder: (ctrl) {
        final spec = DDResponsiveSpec.of(context);

        return Scaffold(
          backgroundColor: AppColors.surface,
          body: SafeArea(
            child: DDResponsiveScrollBody(
              maxWidth: 720,
              padding: spec.pagePadding(
                top: AppSizes.space24,
                bottom: AppSizes.space24,
              ),
              child: Column(
                children: [
                  // Top bar
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: AppColors.primary),
                        onPressed: () => Get.back(),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.space12,
                          vertical: AppSizes.space4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.tertiaryFixed,
                          borderRadius: AppSizes.borderRadiusFull,
                        ),
                        child: Text(
                          ctrl.statusLabel,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onTertiaryFixed,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.space16),
                  Text(
                    l10n.premiumScreenTitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppTypography.serifFamily,
                      fontSize: spec.isCompact ? 32 : 36,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.space12),
                  Text(
                    l10n.premiumScreenSubtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.onSurfaceVariant,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: AppSizes.space40),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSizes.space20),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: AppSizes.borderRadiusLg,
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.premiumWhatUnlocksTitle,
                          style: AppTypography.titleMedium(
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: AppSizes.space8),
                        Text(
                          l10n.premiumWhatUnlocksSubtitle,
                          style: AppTypography.bodyMedium(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.space32),
                  // Benefits
                  Column(
                    children: [
                      _BenefitItem(
                        icon: Icons.group,
                        title: l10n.premiumBenefitUnlimitedFriendsTitle,
                        desc: l10n.premiumBenefitUnlimitedFriendsDesc,
                      ),
                      const SizedBox(height: AppSizes.space16),
                      _BenefitItem(
                        icon: Icons.filter_alt_outlined,
                        title: l10n.premiumBenefitAdvancedFiltersTitle,
                        desc: l10n.premiumBenefitAdvancedFiltersDesc,
                      ),
                      const SizedBox(height: AppSizes.space16),
                      _BenefitItem(
                        icon: Icons.auto_awesome,
                        title: l10n.premiumBenefitCustomThemesTitle,
                        desc: l10n.premiumBenefitCustomThemesDesc,
                      ),
                      const SizedBox(height: AppSizes.space16),
                      _BenefitItem(
                        icon: Icons.high_quality,
                        title: l10n.premiumBenefitHighResBackupsTitle,
                        desc: l10n.premiumBenefitHighResBackupsDesc,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.space40),
                  GestureDetector(
                    onTap: ctrl.showUnavailableMessage,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: AppSizes.borderRadiusFull,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.25),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          l10n.premiumUnavailableAction,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.space12),
                  Text(
                    l10n.premiumFooterNote,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: AppColors.outline),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BenefitItem extends StatelessWidget {
  const _BenefitItem({
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
      crossAxisAlignment: CrossAxisAlignment.start,
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
              const SizedBox(height: 2),
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
