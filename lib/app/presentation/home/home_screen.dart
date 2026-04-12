import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/theme.dart';
import '../../../core/models/moment.dart';
import '../../routes/app_routes.dart';
import '../../core/widgets/widgets.dart';
import 'home_controller.dart';
import '../feed/feed_controller.dart';
import '../feed/reaction_controller.dart';
import '../../../firebase/repositories/moment_repository.dart';
import '../../../features/auth/presentation/controllers/auth_controller.dart';

/// DoneDrop Home Screen — Discipline-first with bottom navigation.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;

  void _onNavTap(int index) {
    if (index == 2) {
      Get.toNamed(AppRoutes.capture);
    } else {
      setState(() => _navIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      _TodayTab(),
      _FeedTab(),
      const SizedBox(),
      const _WallTab(),
      const _SettingsTab(),
    ];

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withValues(alpha: 0.85),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'DoneDrop',
          style: TextStyle(
            fontFamily: AppTypography.serifFamily,
            fontSize: 22,
            fontStyle: FontStyle.italic,
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AppColors.primary),
            onPressed: () {},
          ),
        ],
      ),
      body: DDConnectivityBanner(
        child: IndexedStack(
          index: _navIndex,
          children: screens,
        ),
      ),
      bottomNavigationBar: DDBottomNavBar(
        currentIndex: _navIndex,
        onTap: _onNavTap,
      ),
    );
  }
}

// ── TODAY TAB — Discipline Engine ───────────────────────────────────────────

class _TodayTab extends StatelessWidget {
  const _TodayTab();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (ctrl) {
        if (ctrl.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        return Obx(() {
          final activities = ctrl.activities;
          final completedCount = ctrl.completedToday.value;
          final pendingCount = ctrl.pendingToday.value;
          final overdueCount = ctrl.overdueToday.value;
          final bestStreak = ctrl.currentBestStreak.value;
          final friendCount = ctrl.friendCount.value;

          return RefreshIndicator(
            onRefresh: () async {},
            color: AppColors.primary,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // Sticky stats header
                SliverToBoxAdapter(
                  child: _StatsHeader(
                    completedToday: completedCount,
                    totalActivities: activities.length,
                    bestStreak: bestStreak,
                    friendCount: friendCount,
                    pendingCount: pendingCount,
                    onAddActivity: () => _showCreateActivityDialog(context, ctrl),
                  ),
                ),

                // Content
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.space24),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // ── Overdue Section ───────────────────────────────────
                      if (overdueCount > 0) ...[
                        _SectionHeader(
                          title: 'Overdue',
                          count: overdueCount,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: AppSizes.space12),
                        ...activities
                            .where((a) => ctrl.isOverdue(a.id))
                            .map((a) => _ActivityItem(
                                  activity: a,
                                  instance: ctrl.getInstance(a.id),
                                  isCompleted: ctrl.isCompletedToday(a.id),
                                  isPending: ctrl.isPendingToday(a.id),
                                  isOverdue: ctrl.isOverdue(a.id),
                                  onQuickComplete: () => ctrl.completeActivity(a.id),
                                  onCompleteWithProof: () => ctrl.completeAndOpenCapture(a.id),
                                  onSkip: () => ctrl.missActivity(a.id),
                                )),
                        const SizedBox(height: AppSizes.space24),
                      ],

                      // ── Today Section ──────────────────────────────────────
                      _SectionHeader(
                        title: "Today's Tasks",
                        count: pendingCount + completedCount,
                      ),
                      const SizedBox(height: AppSizes.space12),

                      if (activities.isEmpty)
                        _EmptyState(
                          title: 'No activities yet',
                          description:
                              'Create your first discipline activity to start building streaks.',
                          actionLabel: 'Add Activity',
                          onAction: () => _showCreateActivityDialog(context, ctrl),
                        )
                      else ...[
                        ...activities
                            .where((a) =>
                                !ctrl.isOverdue(a.id) &&
                                !ctrl.isCompletedToday(a.id))
                            .map((a) => _ActivityItem(
                                  activity: a,
                                  instance: ctrl.getInstance(a.id),
                                  isCompleted: ctrl.isCompletedToday(a.id),
                                  isPending: ctrl.isPendingToday(a.id),
                                  isOverdue: false,
                                  onQuickComplete: () => ctrl.completeActivity(a.id),
                                  onCompleteWithProof: () => ctrl.completeAndOpenCapture(a.id),
                                  onSkip: () => ctrl.missActivity(a.id),
                                )),
                      ],

                      // ── Completed Section ─────────────────────────────────
                      if (completedCount > 0) ...[
                        const SizedBox(height: AppSizes.space24),
                        _SectionHeader(title: 'Completed Today', count: completedCount),
                        const SizedBox(height: AppSizes.space12),
                        ...activities
                            .where((a) => ctrl.isCompletedToday(a.id))
                            .map((a) => _ActivityItem(
                                  activity: a,
                                  instance: ctrl.getInstance(a.id),
                                  isCompleted: true,
                                  isPending: false,
                                  isOverdue: false,
                                  onQuickComplete: null,
                                  onCompleteWithProof: null,
                                  onSkip: () => ctrl.missActivity(a.id),
                                )),
                      ],

                      // ── Add Activity Button ────────────────────────────────
                      const SizedBox(height: AppSizes.space24),
                      _AddActivityButton(
                        onTap: () => _showCreateActivityDialog(context, ctrl),
                      ),

                      // ── Weekly Recap ─────────────────────────────────────
                      const SizedBox(height: AppSizes.space32),
                      _RecapCard(),

                      // Bottom padding for FAB + nav bar
                      const SizedBox(height: 120),
                    ]),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  void _showCreateActivityDialog(BuildContext context, HomeController ctrl) {
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
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
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
      padding: EdgeInsets.fromLTRB(
        AppSizes.space24,
        AppSizes.space16,
        AppSizes.space24,
        AppSizes.space20,
      ),
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
          // Date + streak row
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
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    Text(
                      DateFormat('MMMM d').format(DateTime.now()),
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              // Streak badge
              if (bestStreak > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.local_fire_department, color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '$bestStreak day streak',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSizes.space20),

          // Stats chips row
          if (!isCompact)
            Row(
              children: [
                Expanded(child: _StatChip(label: 'Done', value: '$completedToday', icon: Icons.check_circle_outline, color: AppColors.primary)),
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
                    Expanded(child: _StatChip(label: 'Done', value: '$completedToday', icon: Icons.check_circle_outline, color: AppColors.primary)),
                    const SizedBox(width: 8),
                    Expanded(child: _StatChip(label: 'Pending', value: '$pendingCount', icon: Icons.pending_outlined, color: AppColors.secondary)),
                    const SizedBox(width: 8),
                    Expanded(child: _StatChip(label: 'Friends', value: '$friendCount', icon: Icons.people_outline, color: AppColors.tertiary)),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: _AddActivityChip(onTap: onAddActivity),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

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
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.onSurfaceVariant,
                ),
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
            Icon(Icons.add_circle_outline, size: 16, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              'Add',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.count,
    this.color,
  });

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
            fontSize: 18,
            fontWeight: FontWeight.w700,
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
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color ?? AppColors.primary,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ActivityItem extends StatelessWidget {
  const _ActivityItem({
    required this.activity,
    required this.instance,
    required this.isCompleted,
    required this.isPending,
    required this.isOverdue,
    required this.onQuickComplete,
    required this.onCompleteWithProof,
    required this.onSkip,
  });

  final dynamic activity;
  final dynamic instance;
  final bool isCompleted;
  final bool isPending;
  final bool isOverdue;
  /// Quick complete — just mark done, no proof photo. Null for completed items.
  final VoidCallback? onQuickComplete;
  /// Complete with proof — mark done AND open camera. Null for completed items.
  final VoidCallback? onCompleteWithProof;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final borderColor = isOverdue
        ? AppColors.error.withValues(alpha: 0.4)
        : isCompleted
            ? AppColors.primary.withValues(alpha: 0.3)
            : AppColors.surfaceContainerHigh;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.space12),
      padding: const EdgeInsets.all(AppSizes.space16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: AppSizes.borderRadiusMd,
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Row(
        children: [
          // Checkbox — quick complete (no proof)
          GestureDetector(
            onTap: (isPending || isOverdue) && !isCompleted && onQuickComplete != null
                ? onQuickComplete!
                : null,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isCompleted ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isCompleted
                      ? AppColors.primary
                      : isOverdue
                          ? AppColors.error
                          : AppColors.outlineVariant,
                  width: 2,
                ),
              ),
              child: isCompleted
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: AppSizes.space16),

          // Activity info
          Expanded(
            child: GestureDetector(
              // Double-tap activity title to complete with proof
              onDoubleTap: isPending && !isCompleted && onCompleteWithProof != null
                  ? onCompleteWithProof!
                  : null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          activity.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isCompleted
                                ? AppColors.onSurfaceVariant
                                : AppColors.onSurface,
                            decoration: isCompleted ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      ),
                      if (isPending && !isCompleted && onCompleteWithProof != null)
                        GestureDetector(
                          onTap: onCompleteWithProof!,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.camera_alt, size: 12, color: Colors.white),
                                const SizedBox(width: 4),
                                Text(
                                  'Capture',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (activity.category != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      activity.category!,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                  if (isPending && !isCompleted) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Tap ✓ to quick complete  •  Tap Capture for proof',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.outline,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Streak indicator
          if (activity.currentStreak > 0) ...[
            const SizedBox(width: 8),
            Row(
              children: [
                Icon(
                  Icons.local_fire_department,
                  size: 14,
                  color: isOverdue ? AppColors.error : AppColors.primary,
                ),
                const SizedBox(width: 2),
                Text(
                  '${activity.currentStreak}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isOverdue ? AppColors.error : AppColors.primary,
                  ),
                ),
              ],
            ),
          ],

          if (isOverdue)
            Text(
              'Missed',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.error,
              ),
            )
          else if (isCompleted)
            Text(
              'Done',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
        ],
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
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.add, size: 18, color: AppColors.primary),
            ),
            const SizedBox(width: AppSizes.space12),
            Text(
              'Add new activity',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
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
                  Text(
                    'Weekly Recap',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  Text(
                    'See your consistency this week',
                    style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.outline),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.onAction,
  });

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
          Icon(Icons.task_alt, size: 48, color: AppColors.outlineVariant),
          const SizedBox(height: AppSizes.space16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: AppSizes.space16),
          DDPrimaryButton(
            label: actionLabel,
            icon: Icons.add,
            onPressed: onAction,
          ),
        ],
      ),
    );
  }
}

// ── FEED TAB — Real friend moments ─────────────────────────────────────────────

class _FeedTab extends StatelessWidget {
  const _FeedTab();

  @override
  Widget build(BuildContext context) {
    // Uses FeedController registered in HomeBinding
    return GetBuilder<FeedController>(
      builder: (ctrl) {
        return Obx(() {
          if (ctrl.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (ctrl.moments.isEmpty) {
            return _EmptyFeedState(ctrl: ctrl);
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: AppSizes.space12),
            itemCount: ctrl.moments.length,
            itemBuilder: (ctx, i) {
              final moment = ctrl.moments[i];
              return _FeedMomentCard(
                moment: moment,
                ownerName: ctrl.getOwnerName(moment.ownerId),
                ownerAvatar: ctrl.getOwnerAvatar(moment.ownerId),
              );
            },
          );
        });
      },
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
            Icon(Icons.people_outline, size: 56, color: AppColors.outlineVariant),
            const SizedBox(height: AppSizes.space16),
            Text(
              'Friend Feed',
              style: TextStyle(
                fontFamily: AppTypography.serifFamily,
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Private moments from your\naccepted friends will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: AppSizes.space24),
            Obx(() => ctrl.unreadCount.value > 0
                ? DDSecondaryButton(
                    label: 'Mark All Read',
                    icon: Icons.done_all,
                    onPressed: ctrl.markAllRead,
                    isExpanded: false,
                  )
                : const SizedBox.shrink()),
            const SizedBox(height: AppSizes.space12),
            DDSecondaryButton(
              label: 'Friends (${ctrl.friendCount.value})',
              icon: Icons.people_outline,
              onPressed: () => Get.toNamed(AppRoutes.friends),
              isExpanded: false,
            ),
            const SizedBox(height: AppSizes.space12),
            DDPrimaryButton(
              label: 'Add Friends',
              icon: Icons.person_add,
              onPressed: () => Get.toNamed(AppRoutes.addFriend),
              isExpanded: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedMomentCard extends StatelessWidget {
  const _FeedMomentCard({
    required this.moment,
    required this.ownerName,
    required this.ownerAvatar,
  });

  final dynamic moment;
  final String ownerName;
  final String? ownerAvatar;

  @override
  Widget build(BuildContext context) {
    final reactionCtrl = Get.find<ReactionController>();

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSizes.space16,
        vertical: AppSizes.space8,
      ),
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
                  backgroundImage:
                      ownerAvatar != null ? NetworkImage(ownerAvatar!) : null,
                  child: ownerAvatar == null
                      ? Icon(Icons.person, size: 16, color: AppColors.primary)
                      : null,
                ),
                const SizedBox(width: AppSizes.space8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ownerName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                      ),
                      Text(
                        _timeAgo(moment.createdAt as DateTime),
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                // Visibility badge
                _FeedVisibilityBadge(visibility: moment.visibility as String),
              ],
            ),
          ),

          // Image
          AspectRatio(
            aspectRatio: 1,
            child: CachedNetworkImage(
              imageUrl: moment.media.thumbnail.downloadUrl as String,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                color: AppColors.surfaceContainerHighest,
              ),
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
                if ((moment.caption as String).isNotEmpty) ...[
                  Text(
                    moment.caption as String,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.onSurface,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: AppSizes.space12),
                ],
                Row(
                  children: [
                    ...reactionCtrl.reactionTypes.map((type) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => reactionCtrl.toggleReaction(
                              momentId: moment.id as String,
                              reactionType: type,
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerHighest,
                                borderRadius: AppSizes.borderRadiusFull,
                              ),
                              child: Text(
                                reactionCtrl.reactionIcon(type),
                                style: const TextStyle(fontSize: 16),
                              ),
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
                          moment.category as String,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
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
      'all_friends' => (Icons.people, 'Friends'),
      'selected_friends' => (Icons.group, 'Selected'),
      _ => (Icons.lock_outline, 'Personal'),
    };

    return Row(
      children: [
        Icon(icon, size: 12, color: AppColors.outline),
        const SizedBox(width: 2),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: AppColors.outline),
        ),
      ],
    );
  }
}


// ── WALL TAB — Personal moments grid ─────────────────────────────────────────

class _WallTab extends StatelessWidget {
  const _WallTab();

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final uid = authController.firebaseUser?.uid;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Memory Wall',
          style: TextStyle(
            fontFamily: AppTypography.serifFamily,
            fontSize: 18,
            fontStyle: FontStyle.italic,
            color: AppColors.primary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt, color: AppColors.primary),
            onPressed: () => Get.toNamed(AppRoutes.capture),
          ),
        ],
      ),
      body: uid == null
          ? _buildEmptyState()
          : _WallContent(userId: uid),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: DDEmptyState(
        title: 'Memory Wall',
        description: 'Your proof moments appear here.',
        icon: Icons.auto_awesome_mosaic_outlined,
        actionLabel: 'View your moments',
        onAction: () => Get.toNamed(AppRoutes.memoryWall),
      ),
    );
  }
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
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        final moments = snapshot.data ?? [];
        if (moments.isEmpty) {
          return _WallEmptyState();
        }

        return GridView.builder(
          padding: const EdgeInsets.all(AppSizes.space16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: AppSizes.space8,
            crossAxisSpacing: AppSizes.space8,
            childAspectRatio: 1,
          ),
          itemCount: moments.length,
          itemBuilder: (context, i) {
            final moment = moments[i];
            return _WallMomentTile(moment: moment);
          },
        );
      },
    );
  }
}

class _WallEmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_awesome_mosaic_outlined,
              size: 80, color: AppColors.outlineVariant),
          const SizedBox(height: AppSizes.space24),
          Text(
            'No moments yet',
            style: TextStyle(
              fontFamily: AppTypography.serifFamily,
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your personal museum of moments\nwill appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant),
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
                child: Text('Delete', style: TextStyle(color: AppColors.error)),
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
                child: Icon(Icons.image_not_supported, color: AppColors.outline),
              ),
            ),
            if (moment.caption.isNotEmpty)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
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

// ── SETTINGS TAB ────────────────────────────────────────────────────────────

class _SettingsTab extends StatelessWidget {
  const _SettingsTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.settings_outlined, size: 56, color: AppColors.outlineVariant),
          const SizedBox(height: AppSizes.space16),
          Text(
            'Settings',
            style: TextStyle(
              fontFamily: AppTypography.serifFamily,
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: AppSizes.space24),
          DDPrimaryButton(
            label: 'Open Settings',
            icon: Icons.settings,
            onPressed: () => Get.toNamed(AppRoutes.settings),
            isExpanded: false,
          ),
        ],
      ),
    );
  }
}
