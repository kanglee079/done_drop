part of '../home_screen.dart';

class _SettingsTab extends StatelessWidget {
  const _SettingsTab();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final homeController = Get.find<HomeController>();
      final settingsController = Get.find<SettingsController>();

      return ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.space24,
          AppSizes.space12,
          AppSizes.space24,
          120,
        ),
        children: [
          _MeProfileCard(
            displayName:
                homeController.profile.value?.displayName ?? 'DoneDrop member',
            email: settingsController.userEmail,
            completedToday: homeController.completedToday.value,
            bestStreak: homeController.currentBestStreak.value,
            buddyCount: homeController.friendCount.value,
          ),
          const SizedBox(height: AppSizes.space20),
          _MeSection(
            title: 'Stats',
            subtitle: 'The numbers that matter right now.',
          ),
          const SizedBox(height: AppSizes.space12),
          Row(
            children: [
              Expanded(
                child: _MeStatCard(
                  label: 'Weekly wins',
                  value: '${homeController.weeklyCompletionCount}',
                ),
              ),
              const SizedBox(width: AppSizes.space12),
              Expanded(
                child: _MeStatCard(
                  label: 'Active habits',
                  value: '${homeController.totalHabits}',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.space20),
          _MeSection(
            title: 'Reminders',
            subtitle: 'Keep the discipline loop visible.',
          ),
          const SizedBox(height: AppSizes.space12),
          Obx(
            () => _MeToggleTile(
              icon: Icons.notifications_none_rounded,
              title: 'Habit reminders',
              subtitle:
                  '${homeController.reminderCount} habits currently have reminders.',
              value: settingsController.momentReminders.value,
              onChanged: settingsController.toggleMomentReminders,
            ),
          ),
          const SizedBox(height: AppSizes.space20),
          _MeSection(
            title: 'Archived habits',
            subtitle: 'Standards you have paused, not deleted.',
          ),
          const SizedBox(height: AppSizes.space12),
          if (homeController.archivedActivities.isEmpty)
            const _MeInfoTile(
              icon: Icons.archive_outlined,
              title: 'No archived habits',
              subtitle: 'Standards you pause will show here.',
            )
          else
            ...homeController.archivedActivities
                .take(3)
                .map(
                  (activity) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.space12),
                    child: _MeArchiveTile(
                      key: ValueKey('archived-${activity.id}'),
                      icon: Icons.archive_outlined,
                      title: activity.title,
                      subtitle: activity.category ?? 'Archived habit',
                      trailing: TextButton(
                        onPressed: () =>
                            homeController.restoreActivity(activity.id),
                        child: Text(
                          'Restore',
                          style: AppTypography.labelMedium(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
          const SizedBox(height: AppSizes.space20),
          const _MeSection(
            title: 'Theme & settings',
            subtitle: 'App preferences and personal controls.',
          ),
          const SizedBox(height: AppSizes.space12),
          _MeLinkTile(
            icon: Icons.palette_outlined,
            title: 'Theme',
            subtitle: 'Using system theme',
            onTap: () => Get.snackbar(
              'Theme settings',
              'Theme controls are currently following your system setting.',
              snackPosition: SnackPosition.BOTTOM,
            ),
          ),
          const SizedBox(height: AppSizes.space12),
          _MeLinkTile(
            icon: Icons.person_outline_rounded,
            title: 'Profile',
            subtitle: 'Display name, username, avatar',
            onTap: () => Get.toNamed(AppRoutes.profile),
          ),
          const SizedBox(height: AppSizes.space12),
          _MeLinkTile(
            icon: Icons.group_outlined,
            title: 'Buddy circle',
            subtitle: 'Invite, remove, and manage close accountability friends',
            onTap: () => Get.toNamed(AppRoutes.friends),
          ),
          const SizedBox(height: AppSizes.space20),
          const _MeSection(
            title: 'Privacy & support',
            subtitle: 'Policies, help, and release details.',
          ),
          const SizedBox(height: AppSizes.space12),
          _MeLinkTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy policy',
            subtitle: 'Read how DoneDrop handles your account and moment data',
            onTap: settingsController.openPrivacyPolicy,
          ),
          const SizedBox(height: AppSizes.space12),
          _MeLinkTile(
            icon: Icons.description_outlined,
            title: 'Terms of service',
            subtitle: 'The rules for using DoneDrop and private buddy features',
            onTap: settingsController.openTermsOfService,
          ),
          const SizedBox(height: AppSizes.space12),
          _MeLinkTile(
            icon: Icons.support_agent_outlined,
            title: 'Support',
            subtitle: 'Report an issue or get help from inside the app',
            onTap: settingsController.openSupport,
          ),
          const SizedBox(height: AppSizes.space12),
          _MeInfoTile(
            icon: Icons.info_outline_rounded,
            title: 'App version',
            subtitle: settingsController.buildLabel,
          ),
          const SizedBox(height: AppSizes.space20),
          const _MeSection(
            title: 'Account actions',
            subtitle: 'Sign out, or permanently remove this account.',
          ),
          const SizedBox(height: AppSizes.space12),
          Obx(
            () => _MeDangerTile(
              icon: Icons.delete_outline_rounded,
              title: 'Delete account',
              subtitle: settingsController.isDeletingAccount.value
                  ? 'Removing your account data...'
                  : 'Permanently delete your profile, habits, and moments',
              onTap: settingsController.isDeletingAccount.value
                  ? null
                  : settingsController.deleteAccount,
            ),
          ),
          const SizedBox(height: AppSizes.space12),
          Obx(
            () => OutlinedButton.icon(
              onPressed: settingsController.isDeletingAccount.value
                  ? null
                  : settingsController.signOut,
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Sign out'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
              ),
            ),
          ),
        ],
      );
    });
  }
}

class _MeProfileCard extends StatelessWidget {
  const _MeProfileCard({
    required this.displayName,
    required this.email,
    required this.completedToday,
    required this.bestStreak,
    required this.buddyCount,
  });

  final String displayName;
  final String email;
  final int completedToday;
  final int bestStreak;
  final int buddyCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.space24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppSizes.borderRadiusLg,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.16)),
        boxShadow: AppColors.elevatedShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primaryFixed,
                child: Text(
                  displayName.characters.first.toUpperCase(),
                  style: AppTypography.titleLarge(color: AppColors.primary),
                ),
              ),
              const SizedBox(width: AppSizes.space16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: AppTypography.titleLarge(
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppSizes.space2),
                    Text(
                      email,
                      style: AppTypography.bodySmall(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.space20),
          Row(
            children: [
              _ProfileMetric(label: 'Done today', value: '$completedToday'),
              _ProfileMetric(label: 'Best streak', value: '$bestStreak'),
              _ProfileMetric(label: 'Buddies', value: '$buddyCount'),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileMetric extends StatelessWidget {
  const _ProfileMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: AppTypography.titleLarge(color: AppColors.onSurface),
          ),
          const SizedBox(height: AppSizes.space2),
          Text(
            label,
            style: AppTypography.bodySmall(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _MeSection extends StatelessWidget {
  const _MeSection({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.titleMedium(color: AppColors.onSurface),
        ),
        const SizedBox(height: AppSizes.space4),
        Text(
          subtitle,
          style: AppTypography.bodySmall(color: AppColors.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _MeStatCard extends StatelessWidget {
  const _MeStatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.space16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppSizes.borderRadiusLg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.bodySmall(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: AppSizes.space8),
          Text(
            value,
            style: AppTypography.titleLarge(color: AppColors.onSurface),
          ),
        ],
      ),
    );
  }
}

class _MeToggleTile extends StatelessWidget {
  const _MeToggleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.space16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppSizes.borderRadiusLg,
      ),
      child: Row(
        children: [
          _MeIconBadge(icon: icon),
          const SizedBox(width: AppSizes.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.labelLarge(color: AppColors.onSurface),
                ),
                const SizedBox(height: AppSizes.space4),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _MeInfoTile extends StatelessWidget {
  const _MeInfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.space16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppSizes.borderRadiusLg,
      ),
      child: Row(
        children: [
          _MeIconBadge(icon: icon),
          const SizedBox(width: AppSizes.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.labelLarge(color: AppColors.onSurface),
                ),
                const SizedBox(height: AppSizes.space4),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MeArchiveTile extends StatelessWidget {
  const _MeArchiveTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.space16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppSizes.borderRadiusLg,
      ),
      child: Row(
        children: [
          _MeIconBadge(icon: icon),
          const SizedBox(width: AppSizes.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.labelLarge(color: AppColors.onSurface),
                ),
                const SizedBox(height: AppSizes.space4),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (trailing case final trailing?) trailing,
        ],
      ),
    );
  }
}

class _MeLinkTile extends StatelessWidget {
  const _MeLinkTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppSizes.borderRadiusLg,
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(AppSizes.space16),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: AppSizes.borderRadiusLg,
          ),
          child: Row(
            children: [
              _MeIconBadge(icon: icon),
              const SizedBox(width: AppSizes.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.labelLarge(
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppSizes.space4),
                    Text(
                      subtitle,
                      style: AppTypography.bodySmall(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.outline),
            ],
          ),
        ),
      ),
    );
  }
}

class _MeDangerTile extends StatelessWidget {
  const _MeDangerTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppSizes.borderRadiusLg,
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(AppSizes.space16),
          decoration: BoxDecoration(
            color: AppColors.errorContainer.withValues(alpha: 0.42),
            borderRadius: AppSizes.borderRadiusLg,
            border: Border.all(color: AppColors.error.withValues(alpha: 0.18)),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: AppColors.error),
              ),
              const SizedBox(width: AppSizes.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.labelLarge(color: AppColors.error),
                    ),
                    const SizedBox(height: AppSizes.space4),
                    Text(
                      subtitle,
                      style: AppTypography.bodySmall(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.error),
            ],
          ),
        ),
      ),
    );
  }
}

class _MeIconBadge extends StatelessWidget {
  const _MeIconBadge({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: AppColors.primaryFixed,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Icon(icon, color: AppColors.primary),
    );
  }
}
