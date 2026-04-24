import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:done_drop/core/theme/theme.dart';
import 'package:done_drop/app/routes/app_routes.dart';
import 'package:done_drop/app/core/widgets/widgets.dart';
import 'package:done_drop/app/presentation/settings/settings_controller.dart';
import 'package:done_drop/l10n/l10n.dart';

/// DoneDrop Settings Screen
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return GetBuilder<SettingsController>(
      builder: (ctrl) {
        final spec = DDResponsiveSpec.of(context);
        return DismissKeyboard(
          child: Scaffold(
            backgroundColor: AppColors.surface,
            appBar: AppBar(
              backgroundColor: AppColors.surface.withValues(alpha: 0.85),
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.primary),
                onPressed: () => Get.back(),
              ),
              title: Text(
                l10n.settingsArchiveTitle,
                style: TextStyle(
                  fontFamily: AppTypography.serifFamily,
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                  color: AppColors.primary,
                ),
              ),
              centerTitle: true,
            ),
            body: DDResponsiveScrollBody(
              maxWidth: 640,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.settingsTitle,
                    style: TextStyle(
                      fontFamily: AppTypography.serifFamily,
                      fontSize: spec.width < 360 ? 28 : 32,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppSizes.space8),
                  Text(
                    l10n.settingsSubtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  Obx(
                    () {
                      if (!ctrl.shouldShowPremiumEntry) {
                        return const SizedBox(height: AppSizes.space24);
                      }

                      return Column(
                        children: [
                          const SizedBox(height: AppSizes.space32),
                          GestureDetector(
                            onTap: () => Get.toNamed(AppRoutes.premium),
                            child: Container(
                              padding: const EdgeInsets.all(AppSizes.space24),
                              decoration: BoxDecoration(
                                gradient:
                                    ctrl.hasPremiumAccess ||
                                        ctrl.isStoreBillingReady
                                    ? AppColors.primaryGradient
                                    : null,
                                color:
                                    ctrl.hasPremiumAccess ||
                                        ctrl.isStoreBillingReady
                                    ? null
                                    : AppColors.surfaceContainerLowest,
                                borderRadius: AppSizes.borderRadiusLg,
                                border:
                                    ctrl.hasPremiumAccess ||
                                        ctrl.isStoreBillingReady
                                    ? null
                                    : Border.all(
                                        color: AppColors.outlineVariant,
                                      ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    ctrl.hasPremiumAccess ||
                                            ctrl.isStoreBillingReady
                                        ? Icons.auto_awesome
                                        : Icons.lock_clock_outlined,
                                    color:
                                        ctrl.hasPremiumAccess ||
                                            ctrl.isStoreBillingReady
                                        ? Colors.white
                                        : AppColors.primary,
                                    size: 28,
                                  ),
                                  const SizedBox(width: AppSizes.space16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          ctrl.premiumEntryTitle,
                                          style: TextStyle(
                                            fontFamily:
                                                AppTypography.serifFamily,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color:
                                                ctrl.hasPremiumAccess ||
                                                    ctrl.isStoreBillingReady
                                                ? Colors.white
                                                : AppColors.onSurface,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          ctrl.premiumEntrySubtitle,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color:
                                                ctrl.hasPremiumAccess ||
                                                    ctrl.isStoreBillingReady
                                                ? Colors.white70
                                                : AppColors.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      if (!ctrl.hasPremiumAccess &&
                                          !ctrl.isStoreBillingReady)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: AppSizes.space8,
                                            vertical: AppSizes.space4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryFixed,
                                            borderRadius:
                                                AppSizes.borderRadiusFull,
                                          ),
                                          child: Text(
                                            l10n.billingStatusIssueChip,
                                            style: AppTypography.labelSmall(
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        ),
                                      const SizedBox(height: AppSizes.space8),
                                      Icon(
                                        Icons.chevron_right,
                                        color:
                                            ctrl.hasPremiumAccess ||
                                                ctrl.isStoreBillingReady
                                            ? Colors.white
                                            : AppColors.outline,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSizes.space32),
                        ],
                      );
                    },
                  ),
                  // Notification settings
                  Text(
                    l10n.preferencesTitle,
                    style: TextStyle(
                      fontFamily: AppTypography.serifFamily,
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppSizes.space16),
                  Obx(
                    () => _SettingsTile(
                      title: l10n.habitRemindersSettingTitle,
                      desc: l10n.habitRemindersSettingSubtitle,
                      trailing: Switch(
                        value: ctrl.momentReminders.value,
                        onChanged: ctrl.toggleMomentReminders,
                        activeTrackColor: AppColors.primary,
                        thumbColor: WidgetStateProperty.all(Colors.white),
                      ),
                    ),
                  ),
                  _SettingsTile(
                    title: l10n.schedulePreferencesTitle,
                    desc: l10n.schedulePreferencesSubtitle,
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: AppColors.outline,
                    ),
                    onTap: () => Get.toNamed(AppRoutes.notificationSettings),
                  ),
                  const SizedBox(height: AppSizes.space24),
                  Text(
                    l10n.privacySharingTitle,
                    style: TextStyle(
                      fontFamily: AppTypography.serifFamily,
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppSizes.space16),
                  _SettingsTile(
                    title: l10n.profileTitle,
                    desc: ctrl.userEmail.isNotEmpty
                        ? ctrl.userEmail
                        : l10n.profileSettingsDescFallback,
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: AppColors.outline,
                    ),
                    onTap: () => Get.toNamed(AppRoutes.profile),
                  ),
                  _SettingsTile(
                    title: l10n.friendsSettingsTitle,
                    desc: l10n.friendsSettingsSubtitle,
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: AppColors.outline,
                    ),
                    onTap: () => Get.toNamed(AppRoutes.friends),
                  ),
                  _SettingsTile(
                    title: l10n.visibilitySettingsTitle,
                    desc: l10n.visibilitySettingsSubtitle,
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: AppColors.outline,
                    ),
                    onTap: () {},
                  ),
                  _SettingsTile(
                    title: l10n.signOutTitle,
                    desc: l10n.signOutSubtitle,
                    trailing: const Icon(
                      Icons.logout,
                      color: AppColors.outline,
                    ),
                    onTap: () => _showSignOutDialog(context, ctrl),
                  ),
                  const SizedBox(height: AppSizes.space48),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showSignOutDialog(BuildContext context, SettingsController ctrl) async {
    final l10n = context.l10n;
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: l10n.confirmSignOutTitle,
      message: l10n.confirmSignOutMessage,
      isDestructive: true,
    );

    if (confirmed) {
      await ctrl.signOut();
    }
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.title,
    required this.desc,
    required this.trailing,
    this.onTap,
  });

  final String title;
  final String desc;
  final Widget trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.space16),
        margin: const EdgeInsets.only(bottom: AppSizes.space8),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: AppSizes.borderRadiusMd,
        ),
        child: Row(
          children: [
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
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
