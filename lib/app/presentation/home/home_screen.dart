import 'dart:io';

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
      return LayoutBuilder(
        builder: (context, constraints) {
          final spec = DDResponsiveSpec.of(context);
          final tabContent = DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.surface, AppColors.surfaceContainerLow],
              ),
            ),
            child: DDConnectivityBanner(
              child: DDResponsiveCenter(
                maxWidth: spec.pageMaxWidth(
                  compact: 600,
                  medium: 920,
                  expanded: 1120,
                ),
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
          );

          final scaffold = spec.useRailNavigation
              ? Scaffold(
                  backgroundColor: AppColors.surface,
                  body: SafeArea(
                    child: Row(
                      children: [
                        _HomeNavigationRail(
                          currentIndex: currentIndex,
                          onTap: (index) {
                            HapticFeedback.selectionClick();
                            nav.setTab(index);
                          },
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              _HomeWideHeader(currentIndex: currentIndex),
                              Expanded(child: tabContent),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  floatingActionButton: const _CaptureFab(),
                )
              : Scaffold(
                  backgroundColor: AppColors.surface,
                  appBar: _HomeAppBar(currentIndex: currentIndex),
                  body: tabContent,
                  floatingActionButtonLocation:
                      FloatingActionButtonLocation.centerDocked,
                  floatingActionButton: const _CaptureFab(),
                  bottomNavigationBar: DDBottomNavBar(
                    currentIndex: currentIndex,
                    onTap: (index) {
                      HapticFeedback.selectionClick();
                      nav.setTab(index);
                    },
                  ),
                );

          return Stack(
            children: [
              scaffold,
              if (Get.isRegistered<StreakController>()) _MilestoneOverlay(),
            ],
          );
        },
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSizes.space2),
          Text(
            _subtitles[currentIndex],
            style: AppTypography.bodySmall(color: AppColors.onSurfaceVariant),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
  const _CaptureFab();

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

class _HomeWideHeader extends StatelessWidget {
  const _HomeWideHeader({required this.currentIndex});

  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    final spec = DDResponsiveSpec.of(context);

    return Container(
      color: AppColors.surface.withValues(alpha: 0.92),
      padding: spec.pagePadding(
        top: AppSizes.space16,
        bottom: AppSizes.space12,
      ),
      child: DDResponsiveCenter(
        maxWidth: spec.pageMaxWidth(compact: 600, medium: 920, expanded: 1120),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _HomeAppBar._titles[currentIndex],
                    style: AppTypography.headlineSmall(
                      color: AppColors.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSizes.space2),
                  Text(
                    _HomeAppBar._subtitles[currentIndex],
                    style: AppTypography.bodySmall(
                      color: AppColors.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSizes.space12),
            IconButton(
              onPressed: () => Get.toNamed(AppRoutes.notificationSettings),
              icon: const Icon(
                Icons.notifications_none_rounded,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeNavigationRail extends StatelessWidget {
  const _HomeNavigationRail({required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final spec = DDResponsiveSpec.of(context);
    final extended = spec.isExpanded;

    return Container(
      width: extended ? 220 : 92,
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.96),
        border: Border(
          right: BorderSide(
            color: AppColors.outlineVariant.withValues(alpha: 0.6),
          ),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.space16,
              AppSizes.space20,
              AppSizes.space16,
              AppSizes.space12,
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: AppSizes.borderRadiusMd,
                  ),
                  child: const Icon(
                    Icons.camera_alt_outlined,
                    color: AppColors.onPrimary,
                    size: 20,
                  ),
                ),
                if (extended) ...[
                  const SizedBox(width: AppSizes.space12),
                  Expanded(
                    child: Text(
                      'DoneDrop',
                      style: AppTypography.titleMedium(
                        color: AppColors.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: NavigationRail(
              selectedIndex: currentIndex,
              onDestinationSelected: onTap,
              labelType: extended
                  ? NavigationRailLabelType.none
                  : NavigationRailLabelType.all,
              extended: extended,
              minWidth: extended ? 220 : 92,
              minExtendedWidth: 220,
              backgroundColor: Colors.transparent,
              indicatorColor: AppColors.primaryFixed,
              selectedIconTheme: const IconThemeData(
                color: AppColors.primary,
                size: 24,
              ),
              unselectedIconTheme: const IconThemeData(
                color: AppColors.outline,
                size: 22,
              ),
              selectedLabelTextStyle: AppTypography.labelMedium(
                color: AppColors.primary,
              ),
              unselectedLabelTextStyle: AppTypography.bodySmall(
                color: AppColors.outline,
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.today_outlined),
                  selectedIcon: Icon(Icons.today),
                  label: Text('Today'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.favorite_outline_rounded),
                  selectedIcon: Icon(Icons.favorite_rounded),
                  label: Text('Buddy'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.photo_library_outlined),
                  selectedIcon: Icon(Icons.photo_library_rounded),
                  label: Text('Wall'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.person_outline_rounded),
                  selectedIcon: Icon(Icons.person_rounded),
                  label: Text('Me'),
                ),
              ],
            ),
          ),
        ],
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
