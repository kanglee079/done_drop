import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/theme.dart';
import '../../core/widgets/widgets.dart';
import '../../../core/models/leaderboard_entry.dart';
import 'leaderboard_controller.dart';

class LeaderboardScreen extends GetView<LeaderboardController> {
  const LeaderboardScreen({super.key});

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
        title: const Text(
          'Leaderboard',
          style: TextStyle(
            fontFamily: AppTypography.serifFamily,
            fontStyle: FontStyle.italic,
            fontSize: 18,
            color: AppColors.primary,
          ),
        ),
        centerTitle: true,
        actions: [
          Obx(
            () => IconButton(
              icon: Icon(
                controller.isStale.value ? Icons.sync_problem : Icons.sync,
                color: AppColors.primary,
              ),
              onPressed: () =>
                  controller.setPeriod(controller.selectedPeriod.value),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: DDResponsiveCenter(
          maxWidth: 920,
          child: Column(
            children: [
              _PeriodSelector(),
              Expanded(child: _LeaderboardList()),
            ],
          ),
        ),
      ),
    );
  }
}

class _PeriodSelector extends GetView<LeaderboardController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final textScale = MediaQuery.textScalerOf(context).scale(1);
      final useScrollable =
          MediaQuery.sizeOf(context).width < 380 || textScale > 1.15;

      final chips = LeaderboardPeriod.values.map((period) {
        final isSelected = controller.selectedPeriod.value == period;
        return GestureDetector(
          onTap: () => controller.setPeriod(period),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            constraints: BoxConstraints(minWidth: useScrollable ? 92 : 0),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.transparent,
              borderRadius: AppSizes.borderRadiusFull,
            ),
            child: Text(
              _periodLabel(period),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
              ),
            ),
          ),
        );
      }).toList();

      return Container(
        margin: const EdgeInsets.all(AppSizes.space16),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHighest,
          borderRadius: AppSizes.borderRadiusFull,
        ),
        child: useScrollable
            ? SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (var i = 0; i < chips.length; i++) ...[
                      if (i > 0) const SizedBox(width: 4),
                      chips[i],
                    ],
                  ],
                ),
              )
            : Row(
                children: LeaderboardPeriod.values.map((period) {
                  final isSelected = controller.selectedPeriod.value == period;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => controller.setPeriod(period),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.transparent,
                          borderRadius: AppSizes.borderRadiusFull,
                        ),
                        child: Text(
                          _periodLabel(period),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
      );
    });
  }

  String _periodLabel(LeaderboardPeriod p) => switch (p) {
    LeaderboardPeriod.today => 'Today',
    LeaderboardPeriod.thisWeek => 'Week',
    LeaderboardPeriod.thisMonth => 'Month',
    LeaderboardPeriod.allTime => 'All',
  };
}

class _LeaderboardList extends GetView<LeaderboardController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        );
      }

      if (controller.entries.isEmpty) {
        return _EmptyLeaderboard();
      }

      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.space16),
        itemCount: controller.entries.length + 1,
        itemBuilder: (_, i) {
          if (i == 0) {
            // Top 3 podium
            final top3 = controller.entries.take(3).toList();
            return _Top3Podium(
              entries: top3,
              currentUserId: controller.currentUserEntry?.userId,
            );
          }
          final entry = controller.entries[i - 1];
          return _LeaderboardRow(
            entry: entry,
            isCurrentUser: entry.userId == controller.currentUserEntry?.userId,
          );
        },
      );
    });
  }
}

class _Top3Podium extends StatelessWidget {
  const _Top3Podium({required this.entries, required this.currentUserId});
  final List<LeaderboardEntry> entries;
  final String? currentUserId;

  @override
  Widget build(BuildContext context) {
    final useWrap = MediaQuery.sizeOf(context).width < 400;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.space24),
      padding: const EdgeInsets.symmetric(vertical: AppSizes.space16),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.end,
        spacing: useWrap ? AppSizes.space12 : 0,
        runSpacing: useWrap ? AppSizes.space12 : 0,
        children: [
          if (entries.length > 1)
            _PodiumPlace(
              entry: entries[1],
              place: 2,
              isCurrentUser: entries[1].userId == currentUserId,
            ),
          if (entries.isNotEmpty)
            _PodiumPlace(
              entry: entries[0],
              place: 1,
              isCurrentUser: entries[0].userId == currentUserId,
            ),
          if (entries.length > 2)
            _PodiumPlace(
              entry: entries[2],
              place: 3,
              isCurrentUser: entries[2].userId == currentUserId,
            ),
        ],
      ),
    );
  }
}

class _PodiumPlace extends StatelessWidget {
  const _PodiumPlace({
    required this.entry,
    required this.place,
    required this.isCurrentUser,
  });
  final LeaderboardEntry entry;
  final int place;
  final bool isCurrentUser;

  static const _heights = {1: 100.0, 2: 72.0, 3: 52.0};
  static const _colors = {
    1: Color(0xFFFFD700),
    2: Color(0xFFC0C0C0),
    3: Color(0xFFCD7F32),
  };

  @override
  Widget build(BuildContext context) {
    final h = _heights[place]!;
    final color = _colors[place]!;

    return Column(
      children: [
        // Avatar
        Container(
          width: place == 1 ? 64 : 48,
          height: place == 1 ? 64 : 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 3),
            image: entry.avatarUrl != null
                ? DecorationImage(
                    image: CachedNetworkImageProvider(entry.avatarUrl!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: entry.avatarUrl == null
              ? Icon(
                  Icons.person,
                  size: place == 1 ? 32 : 24,
                  color: AppColors.primary,
                )
              : null,
        ),
        const SizedBox(height: 4),
        Text(
          entry.displayName.split(' ').first,
          style: TextStyle(
            fontSize: place == 1 ? 13 : 11,
            fontWeight: FontWeight.w700,
            color: isCurrentUser ? AppColors.primary : AppColors.onSurface,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          '${entry.completedCount}',
          style: TextStyle(
            fontSize: place == 1 ? 16 : 13,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        // Pillar
        Container(
          width: place == 1 ? 72 : 56,
          height: h,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '#$place',
                style: TextStyle(
                  fontFamily: AppTypography.serifFamily,
                  fontSize: place == 1 ? 24 : 18,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              if (entry.currentStreak > 0) ...[
                const SizedBox(height: 2),
                Icon(Icons.local_fire_department, size: 14, color: color),
                Text(
                  '${entry.currentStreak}',
                  style: TextStyle(
                    fontSize: 11,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  const _LeaderboardRow({required this.entry, required this.isCurrentUser});
  final LeaderboardEntry entry;
  final bool isCurrentUser;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.space8),
      padding: const EdgeInsets.all(AppSizes.space12),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? AppColors.primary.withValues(alpha: 0.08)
            : AppColors.surfaceContainerLow,
        borderRadius: AppSizes.borderRadiusMd,
        border: isCurrentUser
            ? Border.all(color: AppColors.primary.withValues(alpha: 0.3))
            : null,
      ),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 28,
            child: Text(
              '#${entry.rank}',
              style: TextStyle(
                fontFamily: AppTypography.serifFamily,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isCurrentUser
                    ? AppColors.primary
                    : AppColors.onSurfaceVariant,
              ),
            ),
          ),
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.outline.withValues(alpha: 0.3),
              ),
              image: entry.avatarUrl != null
                  ? DecorationImage(
                      image: CachedNetworkImageProvider(entry.avatarUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: entry.avatarUrl == null
                ? const Icon(Icons.person, size: 20, color: AppColors.primary)
                : null,
          ),
          const SizedBox(width: AppSizes.space12),
          // Name + streak
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.displayName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isCurrentUser
                        ? AppColors.primary
                        : AppColors.onSurface,
                  ),
                ),
                if (entry.currentStreak > 0)
                  Row(
                    children: [
                      const Icon(
                        Icons.local_fire_department,
                        size: 12,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${entry.currentStreak} day streak',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          // Completed count
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${entry.completedCount}',
                style: TextStyle(
                  fontFamily: AppTypography.serifFamily,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isCurrentUser
                      ? AppColors.primary
                      : AppColors.onSurface,
                ),
              ),
              const Text(
                'done',
                style: TextStyle(fontSize: 10, color: AppColors.outline),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyLeaderboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(AppSizes.space32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.leaderboard_outlined,
            size: 72,
            color: AppColors.outlineVariant,
          ),
          const SizedBox(height: AppSizes.space16),
          const Text(
            'No friends yet',
            style: TextStyle(
              fontFamily: AppTypography.serifFamily,
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add friends to compete on the leaderboard.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: AppSizes.space24),
          OutlinedButton.icon(
            onPressed: () => Get.toNamed('/friends/add'),
            icon: const Icon(Icons.person_add),
            label: const Text('Add Friends'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
            ),
          ),
        ],
      ),
    ),
  );
}
