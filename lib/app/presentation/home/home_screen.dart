import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/theme/theme.dart';
import '../../../core/models/moment.dart';
import '../../../firebase/repositories/moment_repository.dart';
import '../../../features/auth/presentation/controllers/auth_controller.dart';
import '../../routes/app_routes.dart';
import '../../core/widgets/widgets.dart';
import 'home_controller.dart';
import 'navigation_controller.dart';
import '../feed/feed_controller.dart';
import '../feed/reaction_controller.dart';
import '../settings/settings_controller.dart';

import '../streak/streak_controller.dart';
import '../streak/streak_milestone_overlay.dart';

/// DoneDrop Home Screen — Habit tracker × Locket-style photo sharing.
/// Uses GetX reactive state for synchronized tab navigation.
/// All tabs are rendered eagerly via IndexedStack for instant switching.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = Get.find<NavigationController>();

    return Obx(() {
      final currentIndex = nav.navIndex.value;
      return Stack(
        children: [
          Scaffold(
            backgroundColor: AppColors.surface,
            appBar: _buildAppBar(currentIndex),
            body: DDConnectivityBanner(
              child: IndexedStack(
                index: currentIndex,
                children: const [
                  _TodayTab(),
                  _FeedTab(),
                  _WallTab(),
                  _SettingsTab(),
                ],
              ),
            ),
            bottomNavigationBar: DDBottomNavBar(
              currentIndex: currentIndex,
              onTap: (i) => nav.setTab(i),
            ),
          ),
          // Streak milestone celebration overlay
          if (Get.isRegistered<StreakController>()) _buildMilestoneOverlay(),
        ],
      );
    });
  }

  Widget _buildMilestoneOverlay() {
    return Obx(() {
      final streakCtrl = Get.find<StreakController>();
      if (!streakCtrl.isShowingMilestoneOverlay.value) {
        return const SizedBox.shrink();
      }
      final milestone = streakCtrl.pendingMilestone.value;
      if (milestone == null) return const SizedBox.shrink();
      return StreakMilestoneOverlay(
        milestone: milestone,
        activityTitle: streakCtrl.activityTitleForMilestone.value,
        previousStreak: streakCtrl.streakCountBefore.value,
        newStreak: streakCtrl.streakCountAfter.value,
        onDismiss: streakCtrl.dismissMilestoneOverlay,
      );
    });
  }

  String _titleForIndex(int i) => switch (i) {
    0 => 'DoneDrop',
    1 => 'Buddy Feed',
    2 => 'Memory Wall',
    3 => 'Settings',
    _ => 'DoneDrop',
  };

  PreferredSizeWidget _buildAppBar(int navIndex) {
    return AppBar(
      backgroundColor: AppColors.surface.withValues(alpha: 0.85),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      title: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: Text(
          _titleForIndex(navIndex),
          key: ValueKey(navIndex),
          style: const TextStyle(
            fontFamily: AppTypography.serifFamily,
            fontSize: 22,
            fontStyle: FontStyle.italic,
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      centerTitle: true,
      automaticallyImplyLeading: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: AppColors.primary),
          onPressed: () {},
        ),
      ],
    );
  }
}

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
                      activity: a,
                      instance: ctrl.getInstance(a.id),
                      isCompleted: ctrl.isCompletedToday(a.id),
                      isPending: ctrl.isPendingToday(a.id),
                      isOverdue: ctrl.isOverdue(a.id),
                      onQuickComplete: () => ctrl.completeActivity(a.id),
                      onCompleteWithProof: () => ctrl.completeAndOpenCapture(a.id),
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
                        activity: nextUp,
                        instance: ctrl.getInstance(nextUp.id),
                        isCompleted: false,
                        isPending: true,
                        isOverdue: false,
                        isNextUp: true,
                        onQuickComplete: () => ctrl.completeActivity(nextUp.id),
                        onCompleteWithProof: () => ctrl.completeAndOpenCapture(nextUp.id),
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
                        activity: a,
                        instance: ctrl.getInstance(a.id),
                        isCompleted: false,
                        isPending: ctrl.isPendingToday(a.id),
                        isOverdue: false,
                        onQuickComplete: () => ctrl.completeActivity(a.id),
                        onCompleteWithProof: () => ctrl.completeAndOpenCapture(a.id),
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

class _ActivityItem extends StatefulWidget {
  const _ActivityItem({
    required this.activity,
    required this.instance,
    required this.isCompleted,
    required this.isPending,
    required this.isOverdue,
    this.isNextUp = false,
    this.onQuickComplete,
    this.onCompleteWithProof,
    required this.onSkip,
  });

  final dynamic activity;
  final dynamic instance;
  final bool isCompleted;
  final bool isPending;
  final bool isOverdue;
  final bool isNextUp;
  final VoidCallback? onQuickComplete;
  final VoidCallback? onCompleteWithProof;
  final VoidCallback onSkip;

  @override
  State<_ActivityItem> createState() => _ActivityItemState();
}

class _ActivityItemState extends State<_ActivityItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  bool _completed = false;
  bool _isProcessing = false; // Per-item loading — only this button shows spinner

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleComplete() async {
    if (_completed || _isProcessing) return;
    setState(() {
      _completed = true;
      _isProcessing = true;
    });
    _controller.forward().then((_) => _controller.reverse());
    await Future(() => widget.onQuickComplete?.call());
    if (mounted) setState(() => _isProcessing = false);
  }

  Future<void> _handleCaptureComplete() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    await Future(() => widget.onCompleteWithProof?.call());
    if (mounted) setState(() => _isProcessing = false);
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = widget.isOverdue
        ? AppColors.error.withValues(alpha: 0.4)
        : widget.isCompleted
            ? AppColors.primary.withValues(alpha: 0.3)
            : AppColors.surfaceContainerHigh;

    if (widget.isNextUp) return _buildNextUpLayout(context, borderColor);

    return ScaleTransition(
      scale: _scale,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: AppSizes.space12),
        padding: const EdgeInsets.all(AppSizes.space16),
        decoration: BoxDecoration(
          color: _completed
              ? AppColors.primary.withValues(alpha: 0.05)
              : AppColors.surfaceContainerLow,
          borderRadius: AppSizes.borderRadiusMd,
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: (widget.isPending || widget.isOverdue) && !widget.isCompleted && !_isProcessing
                  ? _handleComplete : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: _completed || widget.isCompleted ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: widget.isCompleted
                        ? AppColors.primary
                        : widget.isOverdue ? AppColors.error : AppColors.outlineVariant,
                    width: 2,
                  ),
                ),
                child: _isProcessing && !_completed
                    ? const SizedBox(
                        width: 14, height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : (widget.isCompleted || _completed)
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
              ),
            ),
            const SizedBox(width: AppSizes.space16),
            Expanded(
              child: GestureDetector(
                onDoubleTap: widget.isPending && !widget.isCompleted && !_isProcessing && widget.onCompleteWithProof != null
                    ? _handleCaptureComplete : null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.activity.title,
                            style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600,
                              color: widget.isCompleted
                                  ? AppColors.onSurfaceVariant : AppColors.onSurface,
                              decoration: widget.isCompleted ? TextDecoration.lineThrough : null,
                            ),
                          ),
                        ),
                        if (widget.isPending && !widget.isCompleted && widget.onCompleteWithProof != null)
                          GestureDetector(
                            onTap: _isProcessing ? null : _handleCaptureComplete,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                gradient: _isProcessing
                                    ? LinearGradient(
                                        colors: [const Color(0xFF6366F1).withValues(alpha: 0.5), const Color(0xFF8B5CF6).withValues(alpha: 0.5)],
                                      )
                                    : const LinearGradient(
                                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                                      ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: _isProcessing
                                  ? const SizedBox(
                                      width: 18, height: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.camera_alt, size: 14, color: Colors.white),
                                      ],
                                    ),
                            ),
                          ),
                      ],
                    ),
                    if (widget.activity.category != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        widget.activity.category!,
                        style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (widget.activity.currentStreak > 0) ...[
              const SizedBox(width: 8),
              Row(
                children: [
                  Icon(Icons.local_fire_department, size: 14, color: widget.isOverdue ? AppColors.error : AppColors.primary),
                  const SizedBox(width: 2),
                  Text(
                    '${widget.activity.currentStreak}',
                    style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700,
                      color: widget.isOverdue ? AppColors.error : AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNextUpLayout(BuildContext context, Color borderColor) {
    return ScaleTransition(
      scale: _scale,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSizes.space12),
        padding: const EdgeInsets.all(AppSizes.space20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppSizes.borderRadiusMd,
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 2.0),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            )
          ]
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    widget.activity.title,
                    style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                ),
                if (widget.activity.currentStreak > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.local_fire_department, size: 16, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.activity.currentStreak}',
                          style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            if (widget.activity.category != null) ...[
              const SizedBox(height: 4),
              Text(
                widget.activity.category!,
                style: const TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    label: 'Complete now',
                    icon: Icons.check,
                    isPrimary: false,
                    onTap: _handleComplete,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    label: 'Complete + proof',
                    icon: Icons.camera_alt,
                    isPrimary: true,
                    onTap: _handleCaptureComplete,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({required String label, required IconData icon, required bool isPrimary, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: _isProcessing ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isPrimary ? null : AppColors.surface,
          gradient: isPrimary
              ? const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                )
              : null,
          border: isPrimary ? null : Border.all(color: AppColors.outlineVariant),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isPrimary && !_isProcessing ? [
            BoxShadow(
              color: const Color(0xFF6366F1).withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ] : [],
        ),
        child: _isProcessing
            ? const Center(
                child: SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 16, color: isPrimary ? Colors.white : AppColors.onSurface),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      label, 
                      style: TextStyle(
                        color: isPrimary ? Colors.white : AppColors.onSurface,
                        fontWeight: FontWeight.w700, fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
      ),
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

// ── FEED TAB ─────────────────────────────────────────────────────────────────

class _FeedTab extends StatelessWidget {
  const _FeedTab();

  @override
  Widget build(BuildContext context) {
    // Obx alone handles reactivity — no GetBuilder wrapper to avoid double rebuild.
    return Obx(() {
      final ctrl = Get.find<FeedController>();
      if (ctrl.isLoading.value) {
        return _FeedShimmer();
      }
      if (ctrl.moments.isEmpty) {
        return _EmptyFeedState(ctrl: ctrl);
      }
      return ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.space12),
        itemCount: ctrl.moments.length,
        itemBuilder: (_, i) => _FeedMomentCard(
          moment: ctrl.moments[i],
          ownerName: ctrl.getOwnerName(ctrl.moments[i].ownerId),
          ownerAvatar: ctrl.getOwnerAvatar(ctrl.moments[i].ownerId),
        ),
      );
    });
  }
}

class _FeedShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.space16),
      itemCount: 3,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSizes.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(width: 32, height: 32, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(height: 12, width: 100, color: Colors.white),
                    Container(height: 10, width: 60, color: Colors.white),
                  ]),
                ],
              ),
              const SizedBox(height: 12),
              Container(height: 200, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12))),
              const SizedBox(height: 12),
              Container(height: 14, width: double.infinity, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyFeedState extends StatelessWidget {
  const _EmptyFeedState({required this.ctrl});
  final FeedController ctrl;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.space32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.group_outlined, size: 56, color: AppColors.outlineVariant),
            const SizedBox(height: AppSizes.space16),
            const Text(
              'Buddy Feed', style: TextStyle(
                fontFamily: AppTypography.serifFamily, fontSize: 24, fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Private proofs from your\nbuddy crew will appear here.',
              textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: AppSizes.space24),
            Obx(() => ctrl.unreadCount.value > 0
                ? DDSecondaryButton(label: 'Mark All Read', icon: Icons.done_all, onPressed: ctrl.markAllRead, isExpanded: false)
                : const SizedBox.shrink()),
            const SizedBox(height: AppSizes.space12),
            Obx(() => DDSecondaryButton(
              label: 'Buddy Crew (${ctrl.friendCount.value})',
              icon: Icons.group_outlined,
              onPressed: () => Get.toNamed(AppRoutes.friends),
              isExpanded: false,
            )),
            const SizedBox(height: AppSizes.space12),
            DDPrimaryButton(label: 'Invite Buddy', icon: Icons.person_add, onPressed: () => Get.toNamed(AppRoutes.addFriend), isExpanded: false),
          ],
        ),
      ),
    );
  }
}

class _FeedMomentCard extends StatelessWidget {
  const _FeedMomentCard({required this.moment, required this.ownerName, required this.ownerAvatar});

  final Moment moment;
  final String ownerName;
  final String? ownerAvatar;

  @override
  Widget build(BuildContext context) {
    final reactionCtrl = Get.find<ReactionController>();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.space16, vertical: AppSizes.space8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: AppSizes.borderRadiusLg,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Owner header
          Container(
            padding: const EdgeInsets.all(AppSizes.space12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primaryFixed,
                  backgroundImage: ownerAvatar != null ? NetworkImage(ownerAvatar!) : null,
                  child: ownerAvatar == null
                      ? const Icon(Icons.person, size: 16, color: AppColors.primary) : null,
                ),
                const SizedBox(width: AppSizes.space8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ownerName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
                      Text(_timeAgo(moment.createdAt), style: const TextStyle(fontSize: 11, color: AppColors.outline)),
                    ],
                  ),
                ),
                _FeedVisibilityBadge(visibility: moment.visibility),
              ],
            ),
          ),

          // Image
          AspectRatio(
            aspectRatio: 1,
            child: CachedNetworkImage(
              imageUrl: moment.media.thumbnail.downloadUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(color: AppColors.surfaceContainerHighest),
              errorWidget: (_, __, ___) => Container(
                color: AppColors.surfaceContainerHighest,
                child: const Icon(Icons.broken_image, color: AppColors.outline),
              ),
            ),
          ),

          // Caption + Reactions
          Padding(
            padding: const EdgeInsets.all(AppSizes.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (moment.caption.isNotEmpty) ...[
                  Text(moment.caption, style: const TextStyle(fontSize: 14, color: AppColors.onSurface, height: 1.4)),
                  const SizedBox(height: AppSizes.space12),
                ],
                Row(
                  children: [
                    ...reactionCtrl.reactionTypes.map((type) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => reactionCtrl.toggleReaction(momentId: moment.id, reactionType: type),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHighest,
                            borderRadius: AppSizes.borderRadiusFull,
                          ),
                          child: Text(reactionCtrl.reactionIcon(type), style: const TextStyle(fontSize: 16)),
                        ),
                      ),
                    )),
                    const Spacer(),
                    if (moment.category != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          moment.category!,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

class _FeedVisibilityBadge extends StatelessWidget {
  const _FeedVisibilityBadge({required this.visibility});
  final String visibility;

  @override
  Widget build(BuildContext context) {
    final (icon, label) = switch (visibility) {
      'all_friends' => (Icons.groups, 'Crew'),
      'selected_friends' => (Icons.person_outline, 'Buddy'),
      _ => (Icons.lock_outline, 'Personal'),
    };
    return Row(
      children: [
        Icon(icon, size: 12, color: AppColors.outline),
        const SizedBox(width: 2),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.outline)),
      ],
    );
  }
}

// ── WALL TAB ─────────────────────────────────────────────────────────────────

class _WallTab extends StatelessWidget {
  const _WallTab();

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final uid = authController.firebaseUser?.uid;

    if (uid == null) return _buildEmptyState();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.space16),
      child: _WallContent(userId: uid),
    );
  }

  Widget _buildEmptyState() => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.space24),
      child: DDEmptyState(
        title: 'Memory Wall',
        description: 'Your proof moments appear here.',
        icon: Icons.auto_awesome_mosaic_outlined,
        actionLabel: 'Capture your first moment',
        onAction: () => Get.toNamed(AppRoutes.capture),
      ),
    ),
  );
}

class _WallContent extends StatelessWidget {
  const _WallContent({required this.userId});
  final String userId;

  @override
  Widget build(BuildContext context) {
    final momentRepo = Get.find<MomentRepository>();

    return StreamBuilder<List<Moment>>(
      stream: momentRepo.watchPersonalMoments(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _WallShimmer();
        }

        final moments = snapshot.data ?? [];
        if (moments.isEmpty) return _WallEmptyState();

        return GridView.builder(
          padding: const EdgeInsets.only(top: AppSizes.space8, bottom: AppSizes.space8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: AppSizes.space8,
            crossAxisSpacing: AppSizes.space8,
            childAspectRatio: 1,
          ),
          itemCount: moments.length,
          itemBuilder: (_, i) => _WallMomentTile(moment: moments[i]),
        );
      },
    );
  }
}

class _WallShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.only(top: AppSizes.space8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, mainAxisSpacing: AppSizes.space8, crossAxisSpacing: AppSizes.space8,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppSizes.borderRadiusMd,
        )),
      ),
    );
  }
}

class _WallEmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.auto_awesome_mosaic_outlined, size: 80, color: AppColors.outlineVariant),
        const SizedBox(height: AppSizes.space24),
        const Text(
          'No moments yet',
          style: TextStyle(fontFamily: AppTypography.serifFamily, fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.onSurface),
        ),
        const SizedBox(height: 8),
        const Text(
          'Your proof moments appear here.',
          style: TextStyle(fontFamily: AppTypography.serifFamily, fontSize: 16, color: AppColors.onSurfaceVariant),
        ),
        const SizedBox(height: AppSizes.space24),
        DDPrimaryButton(
          label: 'Capture your first moment',
          icon: Icons.camera_alt,
          onPressed: () => Get.toNamed(AppRoutes.capture),
          isExpanded: false,
        ),
      ],
    ),
  );
}

class _WallMomentTile extends StatelessWidget {
  const _WallMomentTile({required this.moment});
  final Moment moment;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () async {
        final confirmed = await Get.dialog<bool>(
          AlertDialog(
            title: const Text('Delete Moment'),
            content: const Text('Are you sure you want to delete this moment?'),
            actions: [
              TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
              TextButton(
                onPressed: () => Get.back(result: true),
                child: const Text('Delete', style: TextStyle(color: AppColors.error)),
              ),
            ],
          ),
        );
        if (confirmed == true) {
          Get.find<MomentRepository>().deleteMoment(moment.id);
        }
      },
      child: ClipRRect(
        borderRadius: AppSizes.borderRadiusMd,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: moment.media.thumbnail.downloadUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(color: AppColors.surfaceContainerHigh),
              errorWidget: (_, __, ___) => Container(
                color: AppColors.surfaceContainerHigh,
                child: const Icon(Icons.image_not_supported, color: AppColors.outline),
              ),
            ),
            if (moment.caption.isNotEmpty)
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter, end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
                    ),
                  ),
                  child: Text(
                    moment.caption,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── SETTINGS TAB ─────────────────────────────────────────────────────────────

class _SettingsTab extends StatelessWidget {
  const _SettingsTab();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SettingsController>(
      init: SettingsController(),
      builder: (ctrl) => SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.space24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page title
            const Text(
              'Settings',
              style: TextStyle(
                fontFamily: AppTypography.serifFamily,
                fontSize: 32,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: AppSizes.space8),
            Text(
              ctrl.userEmail,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSizes.space32),

            // ── Account Section ──────────────────────────────────────────────
            _SettingsSection(title: 'Account'),
            _SettingsTile(
              icon: Icons.person_outline,
              title: 'Edit Profile',
              subtitle: 'Change your name, username, avatar',
              onTap: () => Get.toNamed(AppRoutes.profile),
            ),
            _SettingsTile(
              icon: Icons.alternate_email,
              title: 'Email',
              subtitle: ctrl.userEmail,
              trailing: const SizedBox.shrink(),
            ),
            const SizedBox(height: AppSizes.space16),

            // ── Preferences Section ──────────────────────────────────────────
            _SettingsSection(title: 'Preferences'),
            Obx(() => _SettingsToggleTile(
              icon: Icons.notifications_outlined,
              title: 'Moment Reminders',
              subtitle: 'Daily reminders for pending activities',
              value: ctrl.momentReminders.value,
              onChanged: ctrl.toggleMomentReminders,
            )),
            const SizedBox(height: AppSizes.space16),

            // ── About Section ────────────────────────────────────────────────
            _SettingsSection(title: 'About'),
            _SettingsTile(
              icon: Icons.info_outline,
              title: 'App Version',
              subtitle: '1.0.0 (Build 1)',
              trailing: const SizedBox.shrink(),
            ),
            const SizedBox(height: AppSizes.space32),

            // ── Sign Out ─────────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final confirm = await Get.dialog<bool>(
                    AlertDialog(
                      title: const Text('Sign Out'),
                      content: const Text('Are you sure you want to sign out?'),
                      actions: [
                        TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
                        TextButton(
                          onPressed: () => Get.back(result: true),
                          child: const Text('Sign Out', style: TextStyle(color: AppColors.error)),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await ctrl.signOut();
                  }
                },
                icon: const Icon(Icons.logout, size: 20),
                label: const Text('Sign Out'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.space8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.onSurfaceVariant,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSizes.space8),
        padding: const EdgeInsets.all(AppSizes.space16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: AppSizes.borderRadiusMd,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: AppColors.primary),
            ),
            const SizedBox(width: AppSizes.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            trailing ?? const Icon(Icons.chevron_right, color: AppColors.outline),
          ],
        ),
      ),
    );
  }
}

class _SettingsToggleTile extends StatelessWidget {
  const _SettingsToggleTile({
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
      margin: const EdgeInsets.only(bottom: AppSizes.space8),
      padding: const EdgeInsets.all(AppSizes.space16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: AppSizes.borderRadiusMd,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: AppSizes.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
