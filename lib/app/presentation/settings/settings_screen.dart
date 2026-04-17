import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:done_drop/core/theme/theme.dart';
import 'package:done_drop/app/routes/app_routes.dart';
import 'package:done_drop/app/core/widgets/widgets.dart';
import 'package:done_drop/app/presentation/settings/settings_controller.dart';

/// DoneDrop Settings Screen
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SettingsController>(
      init: SettingsController(),
      builder: (ctrl) {
        final spec = DDResponsiveSpec.of(context);
        return Scaffold(
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
              'The Archive',
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
                  'Settings',
                  style: TextStyle(
                    fontFamily: AppTypography.serifFamily,
                    fontSize: spec.width < 360 ? 28 : 32,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: AppSizes.space8),
                Text(
                  'Curate your personal experience',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSizes.space32),
                // Premium banner
                GestureDetector(
                  onTap: () => Get.toNamed(AppRoutes.premium),
                  child: Container(
                    padding: const EdgeInsets.all(AppSizes.space24),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: AppSizes.borderRadiusLg,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.auto_awesome,
                          color: Colors.white,
                          size: 28,
                        ),
                        const SizedBox(width: AppSizes.space16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'DoneDrop Premium',
                                style: TextStyle(
                                  fontFamily: AppTypography.serifFamily,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Unlock more friends and premium themes.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: Colors.white),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.space32),
                // Notification settings
                Text(
                  'Preferences',
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
                    title: 'Habit Reminders',
                    desc: 'Daily gentle nudges to complete your habits',
                    trailing: Switch(
                      value: ctrl.momentReminders.value,
                      onChanged: ctrl.toggleMomentReminders,
                      activeTrackColor: AppColors.primary,
                      thumbColor: WidgetStateProperty.all(Colors.white),
                    ),
                  ),
                ),
                _SettingsTile(
                  title: 'Schedule & Preferences',
                  desc: 'Reminder time, recap day, and more',
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: AppColors.outline,
                  ),
                  onTap: () => Get.toNamed(AppRoutes.notificationSettings),
                ),
                const SizedBox(height: AppSizes.space24),
                Text(
                  'Privacy & Sharing',
                  style: TextStyle(
                    fontFamily: AppTypography.serifFamily,
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: AppSizes.space16),
                _SettingsTile(
                  title: 'Profile',
                  desc: ctrl.userEmail.isNotEmpty
                      ? ctrl.userEmail
                      : 'Edit your name, avatar, and bio',
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: AppColors.outline,
                  ),
                  onTap: () => Get.toNamed(AppRoutes.profile),
                ),
                _SettingsTile(
                  title: 'Friends',
                  desc: 'Manage your accountability partners',
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: AppColors.outline,
                  ),
                  onTap: () => Get.toNamed(AppRoutes.friends),
                ),
                _SettingsTile(
                  title: 'Visibility',
                  desc: 'Current setting: Personal Only',
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: AppColors.outline,
                  ),
                  onTap: () {},
                ),
                _SettingsTile(
                  title: 'Sign Out',
                  desc: 'Sign out of your account',
                  trailing: const Icon(Icons.logout, color: AppColors.outline),
                  onTap: () => _showSignOutDialog(context, ctrl),
                ),
                const SizedBox(height: AppSizes.space48),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSignOutDialog(BuildContext context, SettingsController ctrl) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Sign Out', style: TextStyle(color: AppColors.onSurface)),
        content: Text(
          'Are you sure you want to sign out?',
          style: TextStyle(color: AppColors.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ctrl.signOut();
            },
            child: Text('Sign Out', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
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
