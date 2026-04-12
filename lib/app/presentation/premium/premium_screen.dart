import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:done_drop/core/theme/theme.dart';
import 'package:done_drop/app/presentation/premium/premium_controller.dart';

/// DoneDrop Premium Screen
class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PremiumController>(
      init: PremiumController(),
      builder: (ctrl) {
        return Scaffold(
          backgroundColor: AppColors.surface,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.space24),
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
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, size: 14,
                                color: AppColors.onTertiaryFixed),
                            const SizedBox(width: 4),
                            Text(
                              'Premium',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.onTertiaryFixed,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.space16),
                  Text(
                    'Preserve More Memories',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppTypography.serifFamily,
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.space12),
                  Text(
                    'Upgrade your digital heirloom with tools designed for deeper reflection and permanent preservation.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.onSurfaceVariant,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: AppSizes.space40),
                  // Toggle plan
                  Obx(() => Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: AppSizes.borderRadiusFull,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _ToggleOption(
                          label: 'Monthly',
                          isSelected: ctrl.isMonthly.value,
                          onTap: () { if (!ctrl.isMonthly.value) ctrl.togglePlan(); },
                        ),
                        _ToggleOption(
                          label: 'Annual',
                          isSelected: !ctrl.isMonthly.value,
                          onTap: () { if (ctrl.isMonthly.value) ctrl.togglePlan(); },
                          badge: '-20%',
                        ),
                      ],
                    ),
                  )),
                  const SizedBox(height: AppSizes.space32),
                  // Benefits
                  Column(
                    children: const [
                      _BenefitItem(
                        icon: Icons.group,
                        title: 'Unlimited Friends',
                        desc: 'Connect with all your accountability partners.',
                      ),
                      SizedBox(height: AppSizes.space16),
                      _BenefitItem(
                        icon: Icons.filter_alt_outlined,
                        title: 'Advanced Filters',
                        desc: 'Search by mood, person, or subtle themes.',
                      ),
                      SizedBox(height: AppSizes.space16),
                      _BenefitItem(
                        icon: Icons.auto_awesome,
                        title: 'Custom Recap Themes',
                        desc: 'Exclusive editorial layouts for your memory books.',
                      ),
                      SizedBox(height: AppSizes.space16),
                      _BenefitItem(
                        icon: Icons.high_quality,
                        title: 'High-Res Backups',
                        desc: 'Lossless storage for every photo you treasure.',
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.space40),
                  // CTA
                  Obx(() => GestureDetector(
                    onTap: ctrl.isPurchasing.value ? null : ctrl.purchase,
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
                        child: ctrl.isPurchasing.value
                            ? const SizedBox(
                                width: 20, height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Start 7-Day Free Trial',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                  )),
                  const SizedBox(height: AppSizes.space12),
                  Obx(() => Text(
                    'Then ${ctrl.currentPrice}${ctrl.periodLabel}. Cancel anytime.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: AppColors.outline),
                  )),
                  const SizedBox(height: AppSizes.space16),
                  Obx(() => TextButton(
                    onPressed: ctrl.isRestoring.value ? null : ctrl.restorePurchases,
                    child: ctrl.isRestoring.value
                        ? const SizedBox(
                            width: 16, height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2,
                                color: AppColors.primary),
                          )
                        : Text(
                            'Restore Purchases',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.outline,
                            ),
                          ),
                  )),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ToggleOption extends StatelessWidget {
  const _ToggleOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.badge,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.space20,
          vertical: AppSizes.space8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.surfaceContainerLowest
              : Colors.transparent,
          borderRadius: AppSizes.borderRadiusFull,
          boxShadow: isSelected
              ? [BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                )]
              : null,
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? AppColors.onSurface
                    : AppColors.onSurfaceVariant,
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 4),
              Text(
                badge!,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ],
        ),
      ),
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
