import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:done_drop/core/models/streak.dart';
import 'package:done_drop/core/models/activity.dart';
import 'package:done_drop/core/theme/theme.dart';
import 'package:done_drop/app/core/widgets/widgets.dart';
import 'package:done_drop/app/presentation/streak/streak_badge.dart';
import 'package:done_drop/features/auth/presentation/controllers/auth_controller.dart';
import 'package:done_drop/firebase/repositories/activity_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:done_drop/l10n/l10n.dart';

class StreakHistoryScreen extends StatelessWidget {
  const StreakHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Get.back(),
        ),
        title: Text(
          context.l10n.streakJourneyTitle,
          style: const TextStyle(
            fontFamily: AppTypography.serifFamily,
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        centerTitle: true,
      ),
      body: const DDResponsiveCenter(
        maxWidth: 760,
        child: _StreakHistoryContent(),
      ),
    );
  }
}

class _StreakHistoryContent extends StatefulWidget {
  const _StreakHistoryContent();

  @override
  State<_StreakHistoryContent> createState() => _StreakHistoryContentState();
}

class _StreakHistoryContentState extends State<_StreakHistoryContent> {
  List<Activity> _activities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    final authController = Get.find<AuthController>();
    final uid = authController.firebaseUser?.uid;
    if (uid == null) return;

    final repo = ActivityRepository(FirebaseFirestore.instance);
    await for (final list in repo.watchActiveActivities(uid)) {
      if (mounted) {
        setState(() {
          _activities = list;
          _isLoading = false;
        });
      }
    }
  }

  int get _bestStreak {
    if (_activities.isEmpty) return 0;
    return _activities
        .map((a) => a.longestStreak)
        .reduce((a, b) => a > b ? a : b);
  }

  int get _totalStreakDays {
    return _activities.fold(0, (total, a) => total + a.currentStreak);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    return CustomScrollView(
      slivers: [
        // Hero streak badge
        SliverToBoxAdapter(
          child: _StreakHeroCard(
            bestStreak: _bestStreak,
            totalDays: _totalStreakDays,
            activityCount: _activities.length,
          ),
        ),

        // Milestone roadmap
        SliverToBoxAdapter(
          child: _MilestoneRoadmap(currentStreak: _bestStreak),
        ),

        // Activity streaks list
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
            child: Row(
              children: [
                const Icon(
                  Icons.list_alt,
                  size: 18,
                  color: AppColors.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  context.l10n.streakActivityStreaksTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),

        if (_activities.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Text(
                  context.l10n.streakNoActivitiesYet,
                  style: const TextStyle(color: AppColors.onSurfaceVariant),
                ),
              ),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) => _ActivityStreakCard(activity: _activities[i]),
              childCount: _activities.length,
            ),
          ),

        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }
}

class _StreakHeroCard extends StatelessWidget {
  const _StreakHeroCard({
    required this.bestStreak,
    required this.totalDays,
    required this.activityCount,
  });

  final int bestStreak;
  final int totalDays;
  final int activityCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.15),
            AppColors.primary.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          StreakBadge(
            streak: bestStreak,
            showProgress: true,
            size: BadgeSize.large,
          ),
          const SizedBox(height: 20),
          Text(
            bestStreak > 0
                ? context.l10n.streakBestTitle
                : context.l10n.streakStartTitle,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 20,
            runSpacing: 12,
            children: [
              _StatItem(
                label: context.l10n.streakBestStatLabel,
                value: '$bestStreak ${context.l10n.streakDaysUnit}',
                icon: Icons.emoji_events,
              ),
              _StatItem(
                label: context.l10n.streakTotalStatLabel,
                value: '$totalDays ${context.l10n.streakDaysUnit}',
                icon: Icons.local_fire_department,
              ),
              _StatItem(
                label: context.l10n.streakActiveStatLabel,
                value: '$activityCount',
                icon: Icons.check_circle,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 92,
      child: Column(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.onSurface,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _MilestoneRoadmap extends StatelessWidget {
  const _MilestoneRoadmap({required this.currentStreak});

  final int currentStreak;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.flag,
                size: 18,
                color: AppColors.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                context.l10n.streakMilestoneRoadmapTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...StreakMilestones.all.map(
            (milestone) => _MilestoneRow(
              milestone: milestone,
              isReached: milestone.days <= currentStreak,
              isCurrent:
                  currentStreak < milestone.days &&
                  (StreakMilestones.all.indexOf(milestone) == 0 ||
                      StreakMilestones
                              .all[StreakMilestones.all.indexOf(milestone) - 1]
                              .days <=
                          currentStreak),
              currentStreak: currentStreak,
            ),
          ),
        ],
      ),
    );
  }
}

class _MilestoneRow extends StatelessWidget {
  const _MilestoneRow({
    required this.milestone,
    required this.isReached,
    required this.isCurrent,
    required this.currentStreak,
  });

  final StreakMilestone milestone;
  final bool isReached;
  final bool isCurrent;
  final int currentStreak;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isReached
                  ? milestone.backgroundColor
                  : isCurrent
                  ? AppColors.surfaceContainerHighest
                  : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: isReached
                    ? milestone.badgeColor
                    : isCurrent
                    ? AppColors.primary
                    : AppColors.outlineVariant,
                width: isCurrent ? 2 : 1,
              ),
            ),
            child: Icon(
              isReached ? Icons.check : milestone.icon,
              size: 18,
              color: isReached
                  ? milestone.badgeColor
                  : isCurrent
                  ? AppColors.primary
                  : AppColors.outline,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isReached
                    ? milestone.backgroundColor.withValues(alpha: 0.3)
                    : isCurrent
                    ? AppColors.primary.withValues(alpha: 0.05)
                    : AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                border: isCurrent
                    ? Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                      )
                    : null,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          milestone.localizedLabel(context.l10n),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isReached
                                ? milestone.badgeColor
                                : AppColors.onSurface,
                          ),
                        ),
                        if (isCurrent)
                          Text(
                            context.l10n.streakDaysToGo(
                              milestone.days - currentStreak,
                            ),
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Text(
                    '${milestone.days}d',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: isReached
                          ? milestone.badgeColor
                          : AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityStreakCard extends StatelessWidget {
  const _ActivityStreakCard({required this.activity});

  final Activity activity;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              activity.currentStreak > 0
                  ? Icons.local_fire_department
                  : Icons.schedule,
              color: activity.currentStreak > 0
                  ? AppColors.primary
                  : AppColors.outline,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                if (activity.lastCompletedAt != null)
                  Text(
                    context.l10n.streakLastCompleted(
                      _formatDate(context, activity.lastCompletedAt!),
                    ),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.local_fire_department,
                    size: 14,
                    color: activity.currentStreak > 0
                        ? AppColors.primary
                        : AppColors.outline,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${activity.currentStreak}d',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: activity.currentStreak > 0
                          ? AppColors.primary
                          : AppColors.outline,
                    ),
                  ),
                ],
              ),
              Text(
                context.l10n.streakBestShort(activity.longestStreak),
                style: const TextStyle(
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

  String _formatDate(BuildContext context, DateTime dt) {
    final now = DateTime.now();
    final diff = DateTime(
      now.year,
      now.month,
      now.day,
    ).difference(DateTime(dt.year, dt.month, dt.day)).inDays;
    if (diff == 0) return context.l10n.streakTodayShort;
    if (diff == 1) return context.l10n.streakYesterdayShort;
    if (diff > 1 && diff < 7) {
      return context.l10n.streakDaysAgo(diff);
    }
    return DateFormat.yMMMd(
      Localizations.localeOf(context).toLanguageTag(),
    ).format(dt);
  }
}
