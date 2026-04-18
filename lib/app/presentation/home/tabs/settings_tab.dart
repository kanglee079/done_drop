part of '../home_screen.dart';

class _SettingsTab extends StatelessWidget {
  const _SettingsTab();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final homeController = Get.find<HomeController>();
      final settingsController = Get.find<SettingsController>();
      final l10n = context.l10n;

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
                homeController.profile.value?.displayName ??
                l10n.memberFallbackName,
            email: settingsController.userEmail,
            completedToday: homeController.completedToday.value,
            bestStreak: homeController.currentBestStreak.value,
            buddyCount: homeController.friendCount.value,
          ),
          const SizedBox(height: AppSizes.space20),
          _MeSection(
            title: l10n.statsSectionTitle,
            subtitle: l10n.statsSectionSubtitle,
          ),
          const SizedBox(height: AppSizes.space12),
          Row(
            children: [
              Expanded(
                child: _MeStatCard(
                  label: l10n.weeklyWinsLabel,
                  value: '${homeController.weeklyCompletionCount}',
                ),
              ),
              const SizedBox(width: AppSizes.space12),
              Expanded(
                child: _MeStatCard(
                  label: l10n.activeHabitsLabel,
                  value: '${homeController.totalHabits}',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.space20),
          _MeSection(
            title: l10n.remindersSectionTitle,
            subtitle: l10n.remindersSectionSubtitle,
          ),
          const SizedBox(height: AppSizes.space12),
          Obx(
            () => _MeToggleTile(
              icon: Icons.notifications_none_rounded,
              title: l10n.habitRemindersTitle,
              subtitle: l10n.habitRemindersSubtitle(
                homeController.reminderCount,
              ),
              value: settingsController.momentReminders.value,
              onChanged: settingsController.toggleMomentReminders,
            ),
          ),
          const SizedBox(height: AppSizes.space20),
          _MeSection(
            title: l10n.archivedHabitsSectionTitle,
            subtitle: l10n.archivedHabitsSectionSubtitle,
          ),
          const SizedBox(height: AppSizes.space12),
          if (homeController.archivedActivities.isEmpty)
            _MeInfoTile(
              icon: Icons.archive_outlined,
              title: l10n.noArchivedHabitsTitle,
              subtitle: l10n.noArchivedHabitsSubtitle,
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
                      subtitle: activity.category ?? l10n.archivedHabitFallback,
                      trailing: TextButton(
                        onPressed: () =>
                            homeController.restoreActivity(activity.id),
                        child: Text(
                          l10n.restoreAction,
                          style: AppTypography.labelMedium(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
          const SizedBox(height: AppSizes.space20),
          _MeSection(
            title: l10n.themeSettingsTitle,
            subtitle: l10n.themeSettingsSubtitle,
          ),
          const SizedBox(height: AppSizes.space12),
          _MeLinkTile(
            icon: Icons.palette_outlined,
            title: l10n.themeTitle,
            subtitle: l10n.themeSubtitle,
            onTap: () => Get.snackbar(
              l10n.themeSettingsSnackbarTitle,
              l10n.themeSettingsSnackbarMessage,
              snackPosition: SnackPosition.BOTTOM,
            ),
          ),
          const SizedBox(height: AppSizes.space12),
          Obx(
            () => _MeLinkTile(
              icon: Icons.language_rounded,
              title: l10n.languageLabel,
              subtitle: settingsController.currentLanguageLabel,
              onTap: () => _showLanguageSheet(context, settingsController),
            ),
          ),
          const SizedBox(height: AppSizes.space12),
          _MeLinkTile(
            icon: Icons.person_outline_rounded,
            title: l10n.profileTitle,
            subtitle: l10n.profileSubtitle,
            onTap: () => Get.toNamed(AppRoutes.profile),
          ),
          const SizedBox(height: AppSizes.space12),
          _MeLinkTile(
            icon: Icons.group_outlined,
            title: l10n.buddyCircleTitle,
            subtitle: l10n.buddyCircleSubtitle,
            onTap: () => Get.toNamed(AppRoutes.friends),
          ),
          const SizedBox(height: AppSizes.space20),
          _MeSection(
            title: l10n.privacySupportSectionTitle,
            subtitle: l10n.privacySupportSectionSubtitle,
          ),
          const SizedBox(height: AppSizes.space12),
          _MeLinkTile(
            icon: Icons.privacy_tip_outlined,
            title: l10n.privacyPolicy,
            subtitle: l10n.privacyPolicySubtitle,
            onTap: settingsController.openPrivacyPolicy,
          ),
          const SizedBox(height: AppSizes.space12),
          _MeLinkTile(
            icon: Icons.description_outlined,
            title: l10n.termsOfService,
            subtitle: l10n.termsSubtitle,
            onTap: settingsController.openTermsOfService,
          ),
          const SizedBox(height: AppSizes.space12),
          _MeLinkTile(
            icon: Icons.support_agent_outlined,
            title: l10n.supportTitle,
            subtitle: l10n.supportSubtitle,
            onTap: settingsController.openSupport,
          ),
          const SizedBox(height: AppSizes.space12),
          _MeInfoTile(
            icon: Icons.info_outline_rounded,
            title: l10n.appVersionTitle,
            subtitle: settingsController.buildLabel,
          ),
          const SizedBox(height: AppSizes.space20),
          _MeSection(
            title: l10n.accountActionsSectionTitle,
            subtitle: l10n.accountActionsSectionSubtitle,
          ),
          const SizedBox(height: AppSizes.space12),
          Obx(
            () => _MeDangerTile(
              icon: Icons.delete_outline_rounded,
              title: l10n.deleteAccountTitle,
              subtitle: settingsController.isDeletingAccount.value
                  ? l10n.deleteAccountRemovingSubtitle
                  : l10n.deleteAccountSubtitle,
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
                  : () => _showSignOutDialog(context, settingsController),
              icon: const Icon(Icons.logout_rounded),
              label: Text(l10n.signOutAction),
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

  void _showLanguageSheet(BuildContext context, SettingsController controller) {
    final l10n = context.l10n;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.space24,
          AppSizes.space20,
          AppSizes.space24,
          AppSizes.space32,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSizes.radiusXl),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.languageLabel,
                style: AppTypography.headlineSmall(color: AppColors.onSurface),
              ),
              const SizedBox(height: AppSizes.space12),
              _LanguageOptionTile(
                label: l10n.languageEnglish,
                selected: controller.currentLanguageCode == 'en',
                onTap: () async {
                  await controller.changeLanguage('en');
                  Get.back();
                },
              ),
              const SizedBox(height: AppSizes.space8),
              _LanguageOptionTile(
                label: l10n.languageVietnamese,
                selected: controller.currentLanguageCode == 'vi',
                onTap: () async {
                  await controller.changeLanguage('vi');
                  Get.back();
                },
              ),
            ],
          ),
        ),
      ),
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

class _LanguageOptionTile extends StatelessWidget {
  const _LanguageOptionTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppSizes.borderRadiusMd,
      child: Ink(
        padding: const EdgeInsets.all(AppSizes.space16),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primaryFixed
              : AppColors.surfaceContainerLow,
          borderRadius: AppSizes.borderRadiusMd,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTypography.titleMedium(color: AppColors.onSurface),
              ),
            ),
            if (selected)
              const Icon(Icons.check_rounded, color: AppColors.primary),
          ],
        ),
      ),
    );
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
              _ProfileMetric(
                label: context.l10n.summaryDone,
                value: '$completedToday',
              ),
              _ProfileMetric(
                label: context.l10n.summaryBestStreak,
                value: '$bestStreak',
              ),
              _ProfileMetric(
                label: context.l10n.summaryBuddies,
                value: '$buddyCount',
              ),
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
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: AppSizes.metricCardMinHeight),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.space16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: AppSizes.borderRadiusLg,
          border: Border.all(color: AppColors.outlineVariant),
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
    final trailingChildren = trailing == null ? null : <Widget>[trailing!];
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
          ...?trailingChildren,
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
