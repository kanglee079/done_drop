import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/theme.dart';
import '../../routes/app_routes.dart';

/// DoneDrop Settings Screen
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            fontFamily: 'Newsreader',
            fontSize: 18,
            fontStyle: FontStyle.italic,
            color: AppColors.primary,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.space24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Settings',
              style: TextStyle(
                fontFamily: 'Newsreader',
                fontSize: 32,
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
                    const Icon(Icons.auto_awesome, color: Colors.white, size: 28),
                    const SizedBox(width: AppSizes.space16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'DoneDrop Premium',
                            style: TextStyle(
                              fontFamily: 'Newsreader',
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Unlock unlimited circles and premium themes.',
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
                fontFamily: 'Newsreader',
                fontSize: 18,
                fontStyle: FontStyle.italic,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: AppSizes.space16),
            _SettingsTile(
              title: 'Moment Reminders',
              desc: 'Daily gentle nudges to capture your day',
              trailing: Switch(
                value: true,
                onChanged: (_) {},
                activeTrackColor: AppColors.primary,
                thumbColor: WidgetStateProperty.all(Colors.white),
              ),
            ),
            _SettingsTile(
              title: 'Circle Activity',
              desc: 'Notifications when others drop moments',
              trailing: Switch(
                value: false,
                onChanged: (_) {},
                activeTrackColor: AppColors.primary,
                thumbColor: WidgetStateProperty.all(Colors.white),
              ),
            ),
            const SizedBox(height: AppSizes.space24),
            Text(
              'Privacy & Circles',
              style: TextStyle(
                fontFamily: 'Newsreader',
                fontSize: 18,
                fontStyle: FontStyle.italic,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: AppSizes.space16),
            _SettingsTile(
              title: 'Visibility',
              desc: 'Current setting: Personal Only',
              trailing: const Icon(Icons.chevron_right, color: AppColors.outline),
              onTap: () {},
            ),
            _SettingsTile(
              title: 'Account',
              desc: 'Email, password, sign out',
              trailing: const Icon(Icons.chevron_right, color: AppColors.outline),
              onTap: () {},
            ),
            const SizedBox(height: AppSizes.space48),
          ],
        ),
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
