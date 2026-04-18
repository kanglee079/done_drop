part of '../home_screen.dart';

class _TodayTab extends StatelessWidget {
  const _TodayTab();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final controller = Get.find<HomeController>();
      if (controller.isLoading.value) {
        return const _TodayLoadingState();
      }
      return _TodayContent(controller: controller);
    });
  }
}

class _TodayContent extends StatelessWidget {
  const _TodayContent({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    final nextHabit = controller.nextUpHabit;
    final spec = DDResponsiveSpec.of(context);
    final l10n = context.l10n;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: spec.pagePadding(
            top: AppSizes.space12,
            bottom: AppSizes.space32,
          ),
          sliver: SliverList.list(
            children: [
              _TodayIntro(controller: controller),
              const SizedBox(height: AppSizes.space20),
              _TodaySummaryRow(controller: controller),
              const SizedBox(height: AppSizes.space20),
              if (nextHabit != null) ...[
                _SectionHeading(
                  title: l10n.nextUpTitle,
                  subtitle: l10n.nextUpSubtitle,
                ),
                const SizedBox(height: AppSizes.space12),
                HabitActionCard(
                  key: ValueKey('next-up-${nextHabit.id}'),
                  activity: nextHabit,
                  instance: controller.getInstance(nextHabit.id),
                  variant: HabitCardVariant.hero,
                  actionState: controller.actionStateFor(nextHabit.id),
                  isCompleted: controller.isCompletedToday(nextHabit.id),
                  isOverdue: controller.isOverdue(nextHabit.id),
                  onCompleteWithProof: () =>
                      controller.completeAndOpenCapture(nextHabit.id),
                ),
                const SizedBox(height: AppSizes.space24),
              ],
              if (controller.overdueActivities.isNotEmpty) ...[
                _SectionHeading(
                  title: l10n.overdueTitle,
                  subtitle: l10n.overdueSubtitle,
                  trailing: '${controller.overdueActivities.length}',
                ),
                const SizedBox(height: AppSizes.space12),
                ...controller.overdueActivities.map(
                  (activity) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.space12),
                    child: HabitActionCard(
                      key: ValueKey('overdue-${activity.id}'),
                      activity: activity,
                      instance: controller.getInstance(activity.id),
                      variant: HabitCardVariant.content,
                      actionState: controller.actionStateFor(activity.id),
                      isCompleted: controller.isCompletedToday(activity.id),
                      isOverdue: true,
                      onCompleteWithProof: () =>
                          controller.completeAndOpenCapture(activity.id),
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.space12),
              ],
              _SectionHeading(
                title: l10n.laterTodayTitle,
                subtitle: controller.laterTodayHabits.isEmpty
                    ? l10n.laterTodayEmpty
                    : l10n.laterTodayFilled,
                trailing: controller.laterTodayHabits.isEmpty
                    ? null
                    : '${controller.laterTodayHabits.length}',
              ),
              const SizedBox(height: AppSizes.space12),
              if (controller.activities.isEmpty)
                _EmptyTodayState(
                  onCreateHabit: () => _showCreateHabitSheet(context),
                )
              else if (controller.laterTodayHabits.isEmpty)
                _UtilityMessageCard(
                  icon: Icons.done_all_outlined,
                  title: nextHabit == null
                      ? l10n.allHabitsHandledTitle
                      : l10n.onlyOneThingLeftTitle,
                  subtitle: nextHabit == null
                      ? l10n.allHabitsHandledSubtitle
                      : l10n.onlyOneThingLeftSubtitle,
                )
              else
                ...controller.laterTodayHabits.map(
                  (activity) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.space12),
                    child: HabitActionCard(
                      key: ValueKey('later-${activity.id}'),
                      activity: activity,
                      instance: controller.getInstance(activity.id),
                      variant: HabitCardVariant.content,
                      actionState: controller.actionStateFor(activity.id),
                      isCompleted: false,
                      isOverdue: false,
                      onCompleteWithProof: () =>
                          controller.completeAndOpenCapture(activity.id),
                    ),
                  ),
                ),
              const SizedBox(height: AppSizes.space24),
              _SectionHeading(
                title: l10n.capturedTodayTitle,
                subtitle: l10n.capturedTodaySubtitle,
              ),
              const SizedBox(height: AppSizes.space12),
              _CapturedTodayStrip(controller: controller),
              const SizedBox(height: AppSizes.space24),
              _WeeklyRecapTeaser(controller: controller),
              const SizedBox(height: AppSizes.space24),
              _CreateHabitCard(
                onCreateHabit: () => _showCreateHabitSheet(context),
              ),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ],
    );
  }

  void _showCreateHabitSheet(BuildContext context) {
    final titleController = TextEditingController();
    final categoryController = TextEditingController();
    final l10n = context.l10n;
    var selectedTime = TimeOfDay(
      hour: (DateTime.now().hour + 1) % 24,
      minute: 0,
    );

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setState) => Container(
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
                  l10n.addHabitTitle,
                  style: AppTypography.headlineSmall(
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: AppSizes.space8),
                Text(
                  l10n.addHabitSubtitle,
                  style: AppTypography.bodySmall(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSizes.space20),
                TextField(
                  controller: titleController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(hintText: l10n.habitNameHint),
                ),
                const SizedBox(height: AppSizes.space12),
                TextField(
                  controller: categoryController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(hintText: l10n.habitCategoryHint),
                ),
                const SizedBox(height: AppSizes.space16),
                Text(
                  l10n.habitTimeLabel,
                  style: AppTypography.labelMedium(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSizes.space8),
                OutlinedButton.icon(
                  onPressed: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                    );
                    if (picked == null) return;
                    setState(() => selectedTime = picked);
                  },
                  icon: const Icon(Icons.schedule_rounded),
                  label: Text(
                    MaterialLocalizations.of(context).formatTimeOfDay(
                      selectedTime,
                      alwaysUse24HourFormat: false,
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.space20),
                FilledButton(
                  onPressed: () async {
                    final title = titleController.text.trim();
                    if (title.isEmpty) return;
                    try {
                      await controller.createActivity(
                        title: title,
                        category: categoryController.text.trim().isEmpty
                            ? null
                            : categoryController.text.trim(),
                        reminderTime: _formatTimeValue(selectedTime),
                      );
                      Get.back();
                    } catch (_) {
                      Get.snackbar(
                        l10n.addHabitTitle,
                        l10n.setupSaveError,
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    }
                  },
                  child: Text(l10n.createHabitAction),
                ),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}

class _TodayIntro extends StatelessWidget {
  const _TodayIntro({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(AppSizes.space20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppSizes.borderRadiusLg,
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.todayGreeting(controller.greetingName),
                  style: AppTypography.labelMedium(color: AppColors.primary),
                ),
                const SizedBox(height: AppSizes.space8),
                Text(
                  l10n.todayIntroTitle,
                  style: AppTypography.headlineSmall(
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: AppSizes.space8),
                Text(
                  l10n.todayIntroProgress(
                    controller.completedToday.value,
                    controller.totalHabits,
                  ),
                  style: AppTypography.bodySmall(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primaryFixed,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Center(
              child: Text(
                '${(controller.todayProgress * 100).round()}%',
                style: AppTypography.labelLarge(color: AppColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TodaySummaryRow extends StatelessWidget {
  const _TodaySummaryRow({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 430) {
          final halfWidth = (constraints.maxWidth - AppSizes.space12) / 2;
          return Wrap(
            spacing: AppSizes.space12,
            runSpacing: AppSizes.space12,
            children: [
              SizedBox(
                width: halfWidth,
                child: _SummaryStatCard(
                  label: l10n.summaryDone,
                  value: '${controller.completedToday.value}',
                  hint: l10n.summaryToday,
                  tint: AppColors.primary,
                  compact: true,
                ),
              ),
              SizedBox(
                width: halfWidth,
                child: _SummaryStatCard(
                  label: l10n.summaryBestStreak,
                  value: '${controller.currentBestStreak.value}',
                  hint: l10n.summaryDays,
                  tint: AppColors.tertiary,
                  compact: true,
                ),
              ),
              SizedBox(
                width: constraints.maxWidth,
                child: _SummaryStatCard(
                  label: l10n.summaryBuddies,
                  value: '${controller.friendCount.value}',
                  hint: l10n.summaryPrivate,
                  tint: AppColors.secondary,
                  compact: true,
                ),
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: _SummaryStatCard(
                label: l10n.summaryDone,
                value: '${controller.completedToday.value}',
                hint: l10n.summaryToday,
                tint: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSizes.space12),
            Expanded(
              child: _SummaryStatCard(
                label: l10n.summaryBestStreak,
                value: '${controller.currentBestStreak.value}',
                hint: l10n.summaryDays,
                tint: AppColors.tertiary,
              ),
            ),
            const SizedBox(width: AppSizes.space12),
            Expanded(
              child: _SummaryStatCard(
                label: l10n.summaryBuddies,
                value: '${controller.friendCount.value}',
                hint: l10n.summaryPrivate,
                tint: AppColors.secondary,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SummaryStatCard extends StatelessWidget {
  const _SummaryStatCard({
    required this.label,
    required this.value,
    required this.hint,
    required this.tint,
    this.compact = false,
  });

  final String label;
  final String value;
  final String hint;
  final Color tint;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: AppSizes.metricCardMinHeight),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.space16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: AppSizes.borderRadiusLg,
          border: Border.all(color: tint.withValues(alpha: 0.12)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTypography.labelMedium(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSizes.space8),
            Text(
              value,
              style:
                  (compact
                          ? AppTypography.titleMedium(
                              color: AppColors.onSurface,
                            )
                          : AppTypography.titleLarge(
                              color: AppColors.onSurface,
                            ))
                      .copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSizes.space4),
            Text(hint, style: AppTypography.bodySmall(color: tint)),
          ],
        ),
      ),
    );
  }
}

class _CapturedTodayStrip extends StatelessWidget {
  const _CapturedTodayStrip({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    final captured = controller.completedHabits;
    final l10n = context.l10n;

    if (captured.isEmpty) {
      return _UtilityMessageCard(
        icon: Icons.camera_alt_outlined,
        title: l10n.nothingCapturedTitle,
        subtitle: l10n.nothingCapturedSubtitle,
      );
    }

    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: captured.length,
        separatorBuilder: (_, index) => const SizedBox(width: AppSizes.space12),
        itemBuilder: (context, index) {
          final activity = captured[index];
          final instance = controller.getInstance(activity.id);
          final hasProof = (instance?.momentId ?? '').isNotEmpty;

          return Container(
            key: ValueKey('captured-${activity.id}'),
            width: 170,
            padding: const EdgeInsets.all(AppSizes.space16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: AppSizes.borderRadiusLg,
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: hasProof
                        ? AppColors.tertiaryFixed
                        : AppColors.primaryFixed,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    hasProof
                        ? Icons.verified_outlined
                        : Icons.check_circle_outline,
                    color: hasProof ? AppColors.tertiary : AppColors.primary,
                  ),
                ),
                const Spacer(),
                Text(
                  activity.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelLarge(color: AppColors.onSurface),
                ),
                const SizedBox(height: AppSizes.space4),
                Text(
                  hasProof
                      ? l10n.capturedProofAttached
                      : l10n.capturedSavedOnly,
                  style: AppTypography.bodySmall(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _WeeklyRecapTeaser extends StatelessWidget {
  const _WeeklyRecapTeaser({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final progress = controller.totalHabits == 0
        ? 0.0
        : controller.completedToday.value / controller.totalHabits;

    return Container(
      padding: const EdgeInsets.all(AppSizes.space20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppSizes.borderRadiusLg,
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.weeklyRecapTitle,
                  style: AppTypography.titleMedium(color: AppColors.onSurface),
                ),
              ),
              TextButton(
                onPressed: () => Get.toNamed(AppRoutes.recap),
                child: Text(l10n.weeklyRecapOpen),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.space8),
          Text(
            l10n.weeklyRecapSummary(controller.weeklyCompletionCount),
            style: AppTypography.bodyMedium(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: AppSizes.space16),
          ClipRRect(
            borderRadius: AppSizes.borderRadiusFull,
            child: LinearProgressIndicator(
              value: progress.clamp(0, 1),
              minHeight: 10,
              backgroundColor: AppColors.surfaceContainerHigh,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _CreateHabitCard extends StatelessWidget {
  const _CreateHabitCard({required this.onCreateHabit});

  final VoidCallback onCreateHabit;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(AppSizes.space20),
      decoration: BoxDecoration(
        color: AppColors.primaryFixed,
        borderRadius: AppSizes.borderRadiusLg,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.needNewHabitTitle,
                  style: AppTypography.titleMedium(color: AppColors.onSurface),
                ),
                const SizedBox(height: AppSizes.space8),
                Text(
                  l10n.needNewHabitSubtitle,
                  style: AppTypography.bodySmall(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          FilledButton.icon(
            onPressed: onCreateHabit,
            icon: const Icon(Icons.add),
            label: Text(l10n.addAction),
          ),
        ],
      ),
    );
  }
}

class _UtilityMessageCard extends StatelessWidget {
  const _UtilityMessageCard({
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
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.space20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppSizes.borderRadiusLg,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryFixed,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
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

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.titleMedium(color: AppColors.onSurface),
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
        if (trailing != null)
          Text(
            trailing!,
            style: AppTypography.labelLarge(color: AppColors.primary),
          ),
      ],
    );
  }
}

class _EmptyTodayState extends StatelessWidget {
  const _EmptyTodayState({required this.onCreateHabit});

  final VoidCallback onCreateHabit;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.space24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppSizes.borderRadiusLg,
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primaryFixed,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.checklist_rounded,
              color: AppColors.primary,
              size: 34,
            ),
          ),
          const SizedBox(height: AppSizes.space16),
          Text(
            l10n.emptyTodayTitle,
            style: AppTypography.headlineSmall(color: AppColors.onSurface),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.space8),
          Text(
            l10n.emptyTodaySubtitle,
            style: AppTypography.bodyMedium(color: AppColors.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.space20),
          FilledButton(
            onPressed: onCreateHabit,
            child: Text(l10n.createFirstHabitAction),
          ),
        ],
      ),
    );
  }
}

class _TodayLoadingState extends StatelessWidget {
  const _TodayLoadingState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSizes.space24),
      children: [
        Shimmer.fromColors(
          baseColor: AppColors.surfaceContainerHigh,
          highlightColor: AppColors.surfaceContainerLowest,
          child: Container(
            height: 110,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppSizes.borderRadiusLg,
            ),
          ),
        ),
        const SizedBox(height: AppSizes.space20),
        Row(
          children: List.generate(
            3,
            (index) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: index == 2 ? 0 : AppSizes.space12,
                ),
                child: Shimmer.fromColors(
                  baseColor: AppColors.surfaceContainerHigh,
                  highlightColor: AppColors.surfaceContainerLowest,
                  child: Container(
                    height: 108,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: AppSizes.borderRadiusLg,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSizes.space20),
        Shimmer.fromColors(
          baseColor: AppColors.surfaceContainerHigh,
          highlightColor: AppColors.surfaceContainerLowest,
          child: Container(
            height: 220,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppSizes.borderRadiusLg,
            ),
          ),
        ),
      ],
    );
  }
}

String _formatTimeValue(TimeOfDay time) =>
    '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
