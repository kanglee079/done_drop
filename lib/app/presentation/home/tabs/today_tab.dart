part of '../home_screen.dart';

// ── TODAY TAB — Discipline Engine ────────────────────────────────────────────

class _TodayTab extends StatelessWidget {
  const _TodayTab();

  @override
  Widget build(BuildContext context) {
    // Obx alone handles reactivity. No GetBuilder needed — avoids double rebuild.
    return Obx(() {
      final ctrl = Get.find<HomeController>();
      if (ctrl.isLoading.value) {
        return const _TodayShimmer();
      }
      return _TodayContent(ctrl: ctrl);
    });
  }
}

class _TodayShimmer extends StatelessWidget {
  const _TodayShimmer();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSizes.space20),
          // Stats header shimmer
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 32, width: 160, color: Colors.white),
                const SizedBox(height: 8),
                Container(height: 16, width: 100, color: Colors.white),
                const SizedBox(height: AppSizes.space20),
                Row(
                  children: List.generate(3, (_) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Container(
                      height: 64,
                      width: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: AppSizes.borderRadiusMd,
                      ),
                    ),
                  )),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.space24),
          // Section header shimmer
          ...List.generate(3, (_) => Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.space12),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppSizes.borderRadiusMd,
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }
}

class _TodayContent extends StatelessWidget {
  const _TodayContent({required this.ctrl});
  final HomeController ctrl;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {},
      color: AppColors.primary,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: _StatsHeader(
              completedToday: ctrl.completedToday.value,
              totalActivities: ctrl.activities.length,
              bestStreak: ctrl.currentBestStreak.value,
              friendCount: ctrl.friendCount.value,
              pendingCount: ctrl.pendingToday.value,
              onAddActivity: () => _showCreateActivityDialog(context),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.space24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Overdue ──────────────────────────────────────────────────
                if (ctrl.overdueToday.value > 0) ...[
                  _SectionHeader(title: 'Overdue', count: ctrl.overdueToday.value, color: AppColors.error),
                  const SizedBox(height: AppSizes.space12),
                  ...ctrl.activities.where((a) => ctrl.isOverdue(a.id)).map(
                    (a) => _ActivityItem(
                      key: ValueKey(a.id),
                      activity: a,
                      instance: ctrl.getInstance(a.id),
                      isCompleted: ctrl.isCompletedToday(a.id),
                      isPending: ctrl.isPendingToday(a.id),
                      isOverdue: ctrl.isOverdue(a.id),
                      onQuickComplete: () async => await ctrl.completeActivity(a.id),
                      onCompleteWithProof: () async => await ctrl.completeAndOpenCapture(a.id),
                      onSkip: () => ctrl.missActivity(a.id),
                    ),
                  ),
                  const SizedBox(height: AppSizes.space24),
                ],

                // ── Next Up ──────────────────────────────────────────────────
                if (ctrl.activities.where((a) => !ctrl.isOverdue(a.id) && !ctrl.isCompletedToday(a.id)).isNotEmpty) ...[
                  Builder(builder: (ctx) {
                    final nextUp = ctrl.activities.where((a) => !ctrl.isOverdue(a.id) && !ctrl.isCompletedToday(a.id)).first;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      const _SectionHeader(title: 'Next up', count: 0),
                      const SizedBox(height: AppSizes.space12),
                      _ActivityItem(
                        key: ValueKey(nextUp.id),
                        activity: nextUp,
                        instance: ctrl.getInstance(nextUp.id),
                        isCompleted: false,
                        isPending: true,
                        isOverdue: false,
                        isNextUp: true,
                        onQuickComplete: () async => await ctrl.completeActivity(nextUp.id),
                        onCompleteWithProof: () async => await ctrl.completeAndOpenCapture(nextUp.id),
                        onSkip: () => ctrl.missActivity(nextUp.id),
                      ),
                      const SizedBox(height: AppSizes.space24),
                      ]
                    );
                  }),
                ],

                // ── Today ───────────────────────────────────────────────────
                if (ctrl.activities.where((a) => !ctrl.isOverdue(a.id) && !ctrl.isCompletedToday(a.id)).length > 1) ...[
                  _SectionHeader(
                    title: "Later Today",
                    count: ctrl.activities.where((a) => !ctrl.isOverdue(a.id) && !ctrl.isCompletedToday(a.id)).length - 1,
                  ),
                  const SizedBox(height: AppSizes.space12),
                  ...ctrl.activities
                      .where((a) => !ctrl.isOverdue(a.id) && !ctrl.isCompletedToday(a.id))
                      .skip(1)
                      .map((a) => _ActivityItem(
                        key: ValueKey(a.id),
                        activity: a,
                        instance: ctrl.getInstance(a.id),
                        isCompleted: false,
                        isPending: ctrl.isPendingToday(a.id),
                        isOverdue: false,
                        onQuickComplete: () async => await ctrl.completeActivity(a.id),
                        onCompleteWithProof: () async => await ctrl.completeAndOpenCapture(a.id),
                        onSkip: () => ctrl.missActivity(a.id),
                      )),
                ],
                if (ctrl.activities.isEmpty) ...[
                  const _SectionHeader(
                    title: "Today's Tasks",
                    count: 0,
                  ),
                  const SizedBox(height: AppSizes.space12),
                  _EmptyState(
                    title: 'No habits yet',
                    description: 'Create your first habit and capture proof moments to share with friends!',
                    actionLabel: 'Add Habit',
                    onAction: () => _showCreateActivityDialog(context),
                  ),
                ],

                // ── Completed ──────────────────────────────────────────────
                if (ctrl.completedToday.value > 0) ...[
                  const SizedBox(height: AppSizes.space24),
                  _SectionHeader(title: 'Captured Today ✨', count: ctrl.completedToday.value),
                  const SizedBox(height: AppSizes.space12),
                  ...ctrl.activities.where((a) => ctrl.isCompletedToday(a.id)).map(
                    (a) => _ActivityItem(
                      key: ValueKey(a.id),
                      activity: a,
                      instance: ctrl.getInstance(a.id),
                      isCompleted: true,
                      isPending: false,
                      isOverdue: false,
                      onQuickComplete: null,
                      onCompleteWithProof: null,
                      onSkip: () => ctrl.missActivity(a.id),
                    ),
                  ),
                ],

                const SizedBox(height: AppSizes.space24),
                _AddActivityButton(onTap: () => _showCreateActivityDialog(context)),
                const SizedBox(height: AppSizes.space32),
                _RecapCard(),
                const SizedBox(height: 120),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateActivityDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: const Text('New Activity'),
        content: TextField(
          controller: titleCtrl,
          decoration: const InputDecoration(
            hintText: 'e.g., Morning run, Read 30 pages...',
            labelText: 'Activity name',
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final title = titleCtrl.text.trim();
              if (title.isNotEmpty) {
                ctrl.createActivity(title: title);
                Get.back();
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}

class _StatsHeader extends StatelessWidget {
  const _StatsHeader({
    required this.completedToday,
    required this.totalActivities,
    required this.bestStreak,
    required this.friendCount,
    required this.pendingCount,
    required this.onAddActivity,
  });

  final int completedToday;
  final int totalActivities;
  final int bestStreak;
  final int friendCount;
  final int pendingCount;
  final VoidCallback onAddActivity;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 400;

    return Container(
      padding: const EdgeInsets.fromLTRB(AppSizes.space24, AppSizes.space16, AppSizes.space24, AppSizes.space20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('EEEE').format(DateTime.now()),
                      style: const TextStyle(
                        fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.onSurface,
                      ),
                    ),
                    Text(
                      DateFormat('MMMM d').format(DateTime.now()),
                      style: const TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              if (bestStreak > 0) _StreakBadge(streak: bestStreak),
            ],
          ),
          const SizedBox(height: AppSizes.space20),
          if (!isCompact)
            Row(
              children: [
                Expanded(child: _StatChip(label: 'Captured', value: '$completedToday', icon: Icons.camera_alt_outlined, color: AppColors.primary)),
                const SizedBox(width: 8),
                Expanded(child: _StatChip(label: 'Pending', value: '$pendingCount', icon: Icons.pending_outlined, color: AppColors.secondary)),
                const SizedBox(width: 8),
                Expanded(child: _StatChip(label: 'Friends', value: '$friendCount', icon: Icons.people_outline, color: AppColors.tertiary)),
                const SizedBox(width: 8),
                _AddActivityChip(onTap: onAddActivity),
              ],
            )
          else
            Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _StatChip(label: 'Captured', value: '$completedToday', icon: Icons.camera_alt_outlined, color: AppColors.primary)),
                    const SizedBox(width: 8),
                    Expanded(child: _StatChip(label: 'Pending', value: '$pendingCount', icon: Icons.pending_outlined, color: AppColors.secondary)),
                    const SizedBox(width: 8),
                    Expanded(child: _StatChip(label: 'Friends', value: '$friendCount', icon: Icons.people_outline, color: AppColors.tertiary)),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(width: double.infinity, child: _AddActivityChip(onTap: onAddActivity)),
              ],
            ),
        ],
      ),
    );
  }
}

class _StreakBadge extends StatefulWidget {
  const _StreakBadge({required this.streak});
  final int streak;

  @override
  State<_StreakBadge> createState() => _StreakBadgeState();
}

class _StreakBadgeState extends State<_StreakBadge> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulse;

  static const _milestoneThresholds = [7, 14, 21, 30, 50, 100, 365];
  bool get _isMilestone => _milestoneThresholds.contains(widget.streak);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _pulse = Tween<double>(begin: 1.0, end: _isMilestone ? 1.18 : 1.06).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, child) {
        final glowSpread = _isMilestone ? (_pulse.value - 1.0) * 8 : 0.0;
        final glow = BoxShadow(
          color: Colors.orange.withValues(alpha: 0.5 * _pulse.value),
          blurRadius: 10 + glowSpread,
          spreadRadius: glowSpread,
        );
        return Transform.scale(
          scale: _pulse.value,
          child: Container(
            decoration: BoxDecoration(boxShadow: [glow]),
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          gradient: _isMilestone
              ? const LinearGradient(
                  colors: [Color(0xFFFF6B00), Color(0xFFFF9500)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : const LinearGradient(
                  colors: [Color(0xFFFF6B35), Color(0xFFFF8C42)],
                ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: (_isMilestone ? Colors.orange : const Color(0xFFFF6B35))
                  .withValues(alpha: 0.35),
              blurRadius: _isMilestone ? 12 : 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _isMilestone ? Icons.emoji_events : Icons.local_fire_department,
              color: Colors.white,
              size: _isMilestone ? 18 : 16,
            ),
            const SizedBox(width: 4),
            Text(
              '${widget.streak}d streak',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: _isMilestone ? 13 : 12,
              ),
            ),
            if (_isMilestone) ...[
              const SizedBox(width: 4),
              const Icon(Icons.star, color: Colors.white, size: 12),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value, required this.icon, required this.color});

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: color),
              ),
              Text(
                label,
                style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddActivityChip extends StatelessWidget {
  const _AddActivityChip({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_circle_outline, size: 16, color: AppColors.primary),
            const SizedBox(width: 6),
            const Text(
              'Add', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.count, this.color});
  final String title;
  final int count;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.w700,
            color: color ?? AppColors.onSurface,
          ),
        ),
        if (count > 0) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: (color ?? AppColors.primary).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color ?? AppColors.primary),
            ),
          ),
        ],
      ],
    );
  }
}

class _AddActivityButton extends StatelessWidget {
  const _AddActivityButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.space16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: AppSizes.borderRadiusMd,
          border: Border.all(color: AppColors.outlineVariant, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.add, size: 18, color: AppColors.primary),
            ),
            const SizedBox(width: AppSizes.space12),
            const Text(
              'Add new activity',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecapCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.recap),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.space20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withValues(alpha: 0.1),
              AppColors.primary.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: AppSizes.borderRadiusLg,
        ),
        child: Row(
          children: [
            const Icon(Icons.auto_awesome, color: AppColors.primary),
            const SizedBox(width: AppSizes.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Weekly Recap',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.onSurface),
                  ),
                  Text(
                    'See your consistency this week',
                    style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.outline),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.title, required this.description, required this.actionLabel, required this.onAction});

  final String title;
  final String description;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.space20),
      child: Column(
        children: [
          const Icon(Icons.task_alt, size: 48, color: AppColors.outlineVariant),
          const SizedBox(height: AppSizes.space16),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
          const SizedBox(height: 8),
          Text(description, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant)),
          const SizedBox(height: AppSizes.space16),
          DDPrimaryButton(label: actionLabel, icon: Icons.add, onPressed: onAction),
        ],
      ),
    );
  }
}
