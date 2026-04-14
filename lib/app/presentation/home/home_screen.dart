import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:done_drop/app/core/widgets/widgets.dart';
import 'package:done_drop/app/presentation/feed/feed_controller.dart';
import 'package:done_drop/app/presentation/feed/reaction_controller.dart';
import 'package:done_drop/app/presentation/home/home_controller.dart';
import 'package:done_drop/app/presentation/home/navigation_controller.dart';
import 'package:done_drop/app/presentation/home/widgets/habit_action_card.dart';
import 'package:done_drop/app/presentation/memory_wall/memory_wall_controller.dart';
import 'package:done_drop/app/presentation/settings/settings_controller.dart';
import 'package:done_drop/app/presentation/streak/streak_controller.dart';
import 'package:done_drop/app/presentation/streak/streak_milestone_overlay.dart';
import 'package:done_drop/app/routes/app_routes.dart';
import 'package:done_drop/core/constants/app_constants.dart';
import 'package:done_drop/core/models/moment.dart';
import 'package:done_drop/core/theme/theme.dart';

part 'tabs/today_tab.dart';
part 'tabs/feed_tab.dart';
part 'tabs/wall_tab.dart';
part 'tabs/settings_tab.dart';

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
            appBar: _HomeAppBar(currentIndex: currentIndex),
            body: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.surface, AppColors.surfaceContainerLow],
                ),
              ),
              child: DDConnectivityBanner(
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
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            floatingActionButton: _CaptureFab(),
            bottomNavigationBar: DDBottomNavBar(
              currentIndex: currentIndex,
              onTap: (index) {
                HapticFeedback.selectionClick();
                nav.setTab(index);
              },
            ),
          ),
          if (Get.isRegistered<StreakController>()) _MilestoneOverlay(),
        ],
      );
    });
  }
}

class _HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _HomeAppBar({required this.currentIndex});

  final int currentIndex;

  static const _titles = ['Today', 'Buddy', 'Wall', 'Me'];
  static const _subtitles = [
    'Discipline stays visible.',
    'Private proof from your circle.',
    'Your archive, grouped by memory.',
    'Stats, reminders, and settings.',
  ];

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 76,
      backgroundColor: AppColors.surface.withValues(alpha: 0.9),
      surfaceTintColor: Colors.transparent,
      titleSpacing: AppSizes.space24,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _titles[currentIndex],
            style: AppTypography.headlineSmall(color: AppColors.onSurface),
          ),
          const SizedBox(height: AppSizes.space2),
          Text(
            _subtitles[currentIndex],
            style: AppTypography.bodySmall(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: AppSizes.space12),
          child: IconButton(
            onPressed: () => Get.toNamed(AppRoutes.notificationSettings),
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(76);
}

class _CaptureFab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      height: 72,
      child: FloatingActionButton(
        heroTag: 'capture-fab',
        onPressed: () {
          HapticFeedback.mediumImpact();
          Get.toNamed(AppRoutes.capture);
        },
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primaryContainer],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.28),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.camera_alt_outlined,
              color: AppColors.onPrimary,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}

class _MilestoneOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final streakController = Get.find<StreakController>();
      final milestone = streakController.pendingMilestone.value;
      if (!streakController.isShowingMilestoneOverlay.value ||
          milestone == null) {
        return const SizedBox.shrink();
      }

      return StreakMilestoneOverlay(
        milestone: milestone,
        activityTitle: streakController.activityTitleForMilestone.value,
        previousStreak: streakController.streakCountBefore.value,
        newStreak: streakController.streakCountAfter.value,
        onDismiss: streakController.dismissMilestoneOverlay,
      );
    });
  }
}
