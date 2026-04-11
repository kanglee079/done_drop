import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:done_drop/core/theme/theme.dart';
import 'package:done_drop/app/presentation/settings/notification_controller.dart';

/// Screen for configuring notification schedules.
class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NotificationController>(
      init: NotificationController(),
      builder: (ctrl) {
        return Scaffold(
          backgroundColor: AppColors.surface,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.primary),
              onPressed: () => Get.back(),
            ),
            title: const Text('Notifications'),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.space24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Moment Reminders',
                  style: TextStyle(
                    fontFamily: AppTypography.serifFamily,
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: AppSizes.space8),
                Text(
                  'Get a gentle daily nudge to capture your moment.',
                  style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: AppSizes.space16),
                Obx(() => _SettingsTile(
                  title: 'Reminder',
                  desc: 'Toggle daily reminder on/off',
                  trailing: Switch(
                    value: ctrl.reminderEnabled.value,
                    onChanged: ctrl.toggleReminderEnabled,
                    activeTrackColor: AppColors.primary,
                    thumbColor: WidgetStateProperty.all(Colors.white),
                  ),
                )),
                Obx(() => GestureDetector(
                  onTap: ctrl.reminderEnabled.value ? ctrl.pickReminderTime : null,
                  child: _SettingsTile(
                    title: 'Time',
                    desc: ctrl.reminderTimeLabel,
                    trailing: Icon(Icons.chevron_right, color: ctrl.reminderEnabled.value
                        ? AppColors.outline
                        : AppColors.outline.withValues(alpha: 0.3)),
                  ),
                )),
                const SizedBox(height: AppSizes.space32),
                Text(
                  'Weekly Recap',
                  style: TextStyle(
                    fontFamily: AppTypography.serifFamily,
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: AppSizes.space8),
                Text(
                  'Receive a weekly summary of your moments.',
                  style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: AppSizes.space16),
                Obx(() => _SettingsTile(
                  title: 'Recap',
                  desc: 'Toggle weekly recap on/off',
                  trailing: Switch(
                    value: ctrl.recapEnabled.value,
                    onChanged: ctrl.toggleRecapEnabled,
                    activeTrackColor: AppColors.primary,
                    thumbColor: WidgetStateProperty.all(Colors.white),
                  ),
                )),
                Obx(() => GestureDetector(
                  onTap: ctrl.recapEnabled.value ? ctrl.pickRecapDay : null,
                  child: _SettingsTile(
                    title: 'Day',
                    desc: ctrl.recapDayLabel,
                    trailing: Icon(Icons.chevron_right, color: ctrl.recapEnabled.value
                        ? AppColors.outline
                        : AppColors.outline.withValues(alpha: 0.3)),
                  ),
                )),
                Obx(() => GestureDetector(
                  onTap: ctrl.recapEnabled.value ? ctrl.pickRecapTime : null,
                  child: _SettingsTile(
                    title: 'Time',
                    desc: ctrl.recapTimeLabel,
                    trailing: Icon(Icons.chevron_right, color: ctrl.recapEnabled.value
                        ? AppColors.outline
                        : AppColors.outline.withValues(alpha: 0.3)),
                  ),
                )),
                const SizedBox(height: AppSizes.space32),
                // Permission request
                OutlinedButton.icon(
                  onPressed: ctrl.requestPermissions,
                  icon: const Icon(Icons.notifications_outlined),
                  label: const Text('Request Notification Permission'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
                const SizedBox(height: AppSizes.space48),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.title,
    required this.desc,
    required this.trailing,
  });

  final String title;
  final String desc;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
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
                Text(title, style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 15,
                  color: AppColors.onSurface)),
                const SizedBox(height: 2),
                Text(desc, style: const TextStyle(
                  fontSize: 12, color: AppColors.onSurfaceVariant)),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
