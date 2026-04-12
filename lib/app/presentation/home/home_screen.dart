import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/theme.dart';
import '../../routes/app_routes.dart';
import '../../core/widgets/widgets.dart';
import 'home_controller.dart';
import '../friends/friends_controller.dart';

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
      body: IndexedStack(
        index: _navIndex,
        children: screens,
      ),
      bottomNavigationBar: DDBottomNavBar(
        currentIndex: _navIndex,
        onTap: _onNavTap,
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 60),
        child: FloatingActionButton.extended(
          onPressed: () => Get.toNamed(AppRoutes.capture),
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.camera_alt, color: Colors.white),
          label: const Text(
            'Capture',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}

// ── TODAY TAB — Discipline Engine ───────────────────────────────────────────

class _TodayTab extends StatelessWidget {
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

          return RefreshIndicator(
            onRefresh: () async {},
            color: AppColors.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSizes.space24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Stats Header ───────────────────────────────────────
                  _StatsHeader(
                    completedToday: completedCount,
                    totalActivities: activities.length,
                    bestStreak: bestStreak,
                  ),
                  const SizedBox(height: AppSizes.space32),

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
                              onComplete: () => ctrl.completeActivity(a.id),
                              onSkip: () => ctrl.archiveActivity(a.id),
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
                              onComplete: () => ctrl.completeActivity(a.id),
                              onSkip: () => ctrl.archiveActivity(a.id),
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
                              onComplete: null,
                              onSkip: () => ctrl.archiveActivity(a.id),
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
                ],
              ),
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
  });

  final int completedToday;
  final int totalActivities;
  final int bestStreak;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Date + streak
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.local_fire_department, color: Colors.white, size: 18),
                const SizedBox(width: 4),
                Text(
                  '$bestStreak day streak',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
      ],
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
    required this.onComplete,
    required this.onSkip,
  });

  final dynamic activity;
  final dynamic instance;
  final bool isCompleted;
  final bool isPending;
  final bool isOverdue;
  final VoidCallback? onComplete;
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
          // Checkbox
          GestureDetector(
            onTap: onComplete,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
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
              ],
            ),
          ),

          // Streak indicator
          if (activity.currentStreak > 0) ...[
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
            const SizedBox(width: 8),
          ],

          // Complete button (if pending and not yet done)
          if (isPending && onComplete != null)
            GestureDetector(
              onTap: onComplete,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            )
          else if (isOverdue)
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

// ── FEED TAB ────────────────────────────────────────────────────────────────

class _FeedTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final friendsCtrl = Get.put(FriendsController(Get.find()));

    return Center(
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
            'Private moments from your\naccepted friends.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: AppSizes.space24),
          Obx(() => DDSecondaryButton(
                label: friendsCtrl.hasPendingRequests
                    ? 'Requests (${friendsCtrl.pendingRequestCount.value})'
                    : 'Friends',
                icon: Icons.people_outline,
                onPressed: () => Get.toNamed(AppRoutes.friends),
                isExpanded: false,
              )),
          const SizedBox(height: AppSizes.space12),
          DDPrimaryButton(
            label: 'Add Friend',
            icon: Icons.person_add,
            onPressed: () => Get.toNamed(AppRoutes.addFriend),
            isExpanded: false,
          ),
        ],
      ),
    );
  }
}

// ── WALL TAB ────────────────────────────────────────────────────────────────

class _WallTab extends StatelessWidget {
  const _WallTab();

  @override
  Widget build(BuildContext context) {
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
