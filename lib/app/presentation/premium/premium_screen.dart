import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'package:done_drop/app/core/widgets/widgets.dart';
import 'package:done_drop/app/presentation/premium/premium_controller.dart';
import 'package:done_drop/core/services/billing_service.dart';
import 'package:done_drop/core/theme/theme.dart';
import 'package:done_drop/l10n/l10n.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  PremiumController _resolveController() {
    if (Get.isRegistered<PremiumController>()) {
      return Get.find<PremiumController>();
    }

    final billing = Get.isRegistered<BillingService>()
        ? Get.find<BillingService>()
        : Get.put(BillingService());

    return Get.put(PremiumController(billing));
  }

  @override
  Widget build(BuildContext context) {
    final spec = DDResponsiveSpec.of(context);
    final controller = _resolveController();

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: DDResponsiveScrollBody(
          maxWidth: 720,
          padding: spec.pagePadding(
            top: AppSizes.space24,
            bottom: AppSizes.space24,
          ),
          child: Obx(() {
            final billing = controller.billing;
            final l10n = context.l10n;
            final hasPremium = controller.hasPremiumAccess;
            final activeKind = billing.activeKind;
            final offers = billing.offers;
            final hasCatalogIssue =
                billing.missingProductIds.isNotEmpty || offers.isEmpty;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TopBar(statusLabel: controller.statusLabel),
                const SizedBox(height: AppSizes.space20),
                Text(
                  hasPremium
                      ? l10n.billingPremiumActiveTitle
                      : l10n.premiumBannerTitle,
                  style: TextStyle(
                    fontFamily: AppTypography.serifFamily,
                    fontSize: spec.isCompact ? 30 : 36,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppSizes.space10),
                Text(
                  hasPremium
                      ? l10n.billingPremiumActiveSubtitle(
                          controller.planLabel(activeKind),
                        )
                      : l10n.billingPremiumReadySubtitle,
                  style: AppTypography.bodyMedium(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSizes.space24),
                if (billing.isLoadingCatalog.value || billing.isRestoring.value)
                  _LoadingCard(
                    message: billing.isRestoring.value
                        ? l10n.billingCheckingRestoreMessage
                        : l10n.billingCheckingSubtitle,
                  )
                else if (!billing.storeAvailable.value)
                  _StateCard(
                    icon: Icons.storefront_outlined,
                    title: l10n.billingStoreUnavailableTitle,
                    message: billing.errorMessage.value?.trim().isNotEmpty ==
                            true
                        ? billing.errorMessage.value!
                        : l10n.billingStoreUnavailableMessage,
                    primaryActionLabel: l10n.billingRetryAction,
                    onPrimaryAction: () =>
                        billing.refreshCatalog(triggerRestore: false),
                  )
                else if (hasCatalogIssue)
                  _StateCard(
                    icon: Icons.inventory_2_outlined,
                    title: l10n.billingCatalogMissingTitle,
                    message: l10n.billingCatalogMissingMessage(
                      billing.missingProductIds.isEmpty
                          ? l10n.billingCatalogSetupNeededSubtitle
                          : billing.missingProductIds.join(', '),
                    ),
                    primaryActionLabel: l10n.billingRetryAction,
                    onPrimaryAction: () =>
                        billing.refreshCatalog(triggerRestore: false),
                  )
                else ...[
                  _InfoCard(
                    title: l10n.premiumWhatUnlocksTitle,
                    subtitle: l10n.billingWhatUnlocksTodaySubtitle,
                  ),
                  const SizedBox(height: AppSizes.space24),
                  _BenefitTile(
                    icon: Icons.group_rounded,
                    title: l10n.premiumBenefitUnlimitedFriendsTitle,
                    description: l10n.premiumBenefitUnlimitedFriendsDesc,
                  ),
                  const SizedBox(height: AppSizes.space14),
                  _BenefitTile(
                    icon: Icons.sync_rounded,
                    title: l10n.billingBenefitRestoreTitle,
                    description: l10n.billingBenefitRestoreDesc,
                  ),
                  const SizedBox(height: AppSizes.space14),
                  _BenefitTile(
                    icon: Icons.all_inclusive_rounded,
                    title: l10n.billingBenefitLifetimeTitle,
                    description: l10n.billingBenefitLifetimeDesc,
                  ),
                  const SizedBox(height: AppSizes.space24),
                  Text(
                    l10n.billingChoosePlanTitle,
                    style: AppTypography.titleMedium(
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppSizes.space12),
                  ...offers.map(
                    (offer) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSizes.space16),
                      child: _OfferCard(
                        offer: offer,
                        title: controller.planLabel(offer.kind),
                        subtitle: _subtitleForOffer(context, offer.kind),
                        details: offer.productDetails,
                        isActive: billing.isOfferActive(offer.kind),
                        isBusy: billing.isOfferPurchasing(offer.kind),
                        hasLifetime:
                            billing.activeKind == PremiumProductKind.lifetime,
                        canSwitch:
                            hasPremium &&
                            billing.activeKind != null &&
                            billing.activeKind != offer.kind &&
                            billing.activeKind != PremiumProductKind.lifetime,
                        onTap: () => controller.purchase(offer.kind),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.space8),
                  Wrap(
                    spacing: AppSizes.space12,
                    runSpacing: AppSizes.space12,
                    children: [
                      OutlinedButton.icon(
                        onPressed: controller.restore,
                        icon: const Icon(Icons.restore_rounded),
                        label: Text(l10n.restoreAction),
                      ),
                      if (billing.activeSubscriptionProductId != null)
                        OutlinedButton.icon(
                          onPressed: controller.manageSubscription,
                          icon: const Icon(Icons.open_in_new_rounded),
                          label: Text(l10n.billingManageAction),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.space16),
                  Text(
                    l10n.billingFooterDisclosure,
                    style: AppTypography.bodySmall(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            );
          }),
        ),
      ),
    );
  }

  String _subtitleForOffer(BuildContext context, PremiumProductKind kind) {
    final l10n = context.l10n;
    return switch (kind) {
      PremiumProductKind.monthly => l10n.billingMonthlyPlanSubtitle,
      PremiumProductKind.yearly => l10n.billingYearlyPlanSubtitle,
      PremiumProductKind.lifetime => l10n.billingLifetimePlanSubtitle,
    };
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.statusLabel});

  final String statusLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.close, color: AppColors.primary),
          onPressed: () => Get.back(),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.space12,
            vertical: AppSizes.space6,
          ),
          decoration: BoxDecoration(
            color: AppColors.tertiaryFixed,
            borderRadius: AppSizes.borderRadiusFull,
          ),
          child: Text(
            statusLabel,
            style: AppTypography.labelMedium(
              color: AppColors.onTertiaryFixed,
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.space20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppSizes.borderRadiusLg,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.titleMedium(color: AppColors.onSurface)),
          const SizedBox(height: AppSizes.space8),
          Text(
            subtitle,
            style: AppTypography.bodyMedium(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.space20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppSizes.borderRadiusLg,
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: AppSizes.space12),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodyMedium(color: AppColors.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}

class _StateCard extends StatelessWidget {
  const _StateCard({
    required this.icon,
    required this.title,
    required this.message,
    required this.primaryActionLabel,
    required this.onPrimaryAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String primaryActionLabel;
  final VoidCallback onPrimaryAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.space20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppSizes.borderRadiusLg,
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(height: AppSizes.space12),
          Text(title, style: AppTypography.titleMedium(color: AppColors.onSurface)),
          const SizedBox(height: AppSizes.space8),
          Text(
            message,
            style: AppTypography.bodyMedium(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: AppSizes.space16),
          FilledButton.icon(
            onPressed: onPrimaryAction,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(primaryActionLabel),
          ),
        ],
      ),
    );
  }
}

class _BenefitTile extends StatelessWidget {
  const _BenefitTile({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

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
                style: AppTypography.titleSmall(color: AppColors.onSurface),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: AppTypography.bodySmall(
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

class _OfferCard extends StatelessWidget {
  const _OfferCard({
    required this.offer,
    required this.title,
    required this.subtitle,
    required this.details,
    required this.isActive,
    required this.isBusy,
    required this.hasLifetime,
    required this.canSwitch,
    required this.onTap,
  });

  final BillingOffer offer;
  final String title;
  final String subtitle;
  final ProductDetails details;
  final bool isActive;
  final bool isBusy;
  final bool hasLifetime;
  final bool canSwitch;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDisabled = isActive || isBusy || hasLifetime;
    final accent = isActive ? AppColors.primary : AppColors.surfaceContainerLow;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.space20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppSizes.borderRadiusLg,
        border: Border.all(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.28)
              : AppColors.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.titleMedium(
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTypography.bodySmall(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.space12,
                  vertical: AppSizes.space6,
                ),
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: AppSizes.borderRadiusFull,
                ),
                child: Text(
                  details.price,
                  style: AppTypography.labelLarge(
                    color: isActive ? Colors.white : AppColors.onSurface,
                  ),
                ),
              ),
            ],
          ),
          if (details.description.trim().isNotEmpty) ...[
            const SizedBox(height: AppSizes.space12),
            Text(
              details.description.trim(),
              style: AppTypography.bodySmall(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: AppSizes.space16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: isDisabled ? null : onTap,
              child: Text(
                isBusy
                    ? l10n.billingPendingAction
                    : isActive
                    ? l10n.billingOwnedAction
                    : hasLifetime
                    ? l10n.billingOwnedAction
                    : canSwitch
                    ? l10n.billingSwitchPlanAction(details.price)
                    : l10n.billingChoosePlanAction(details.price),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
