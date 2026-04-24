import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:done_drop/app/core/widgets/widgets.dart';
import 'package:done_drop/app/presentation/feed/feed_controller.dart';
import 'package:done_drop/app/presentation/feed/reaction_controller.dart';
import 'package:done_drop/app/presentation/home/home_controller.dart';
import 'package:done_drop/app/presentation/home/navigation_controller.dart';
import 'package:done_drop/app/presentation/notifications/notification_center_controller.dart';
import 'package:done_drop/app/presentation/home/widgets/habit_action_card.dart';
import 'package:done_drop/app/presentation/memory_wall/memory_wall_controller.dart';
import 'package:done_drop/app/presentation/settings/settings_controller.dart';
import 'package:done_drop/app/presentation/streak/streak_controller.dart';
import 'package:done_drop/app/presentation/streak/streak_milestone_overlay.dart';
import 'package:done_drop/app/routes/app_routes.dart';
import 'package:done_drop/core/models/activity.dart';
import 'package:done_drop/core/models/moment.dart';
import 'package:done_drop/core/services/buddy_feed_cache_service.dart';
import 'package:done_drop/core/theme/theme.dart';
import 'package:done_drop/core/utils/activity_utils.dart';
import 'package:done_drop/l10n/l10n.dart';

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
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: IndexedStack(
                    key: ValueKey(currentIndex),
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
                  bottomNavigationBar: DDBottomNavBar(
                    currentIndex: currentIndex,
                    onTap: (index) {
                      HapticFeedback.selectionClick();
                      nav.setTab(index);
                    },
                    onCaptureTap: () => Get.toNamed(AppRoutes.capture),
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

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final titles = [
      l10n.todayTabTitle,
      l10n.buddyTabTitle,
      l10n.wallTabTitle,
      l10n.meTabTitle,
    ];
    final subtitles = [
      l10n.todayTabSubtitle,
      l10n.buddyTabSubtitle,
      l10n.wallTabSubtitle,
      l10n.meTabSubtitle,
    ];

    return AppBar(
      toolbarHeight: 76,
      backgroundColor: AppColors.surface.withValues(alpha: 0.9),
      surfaceTintColor: Colors.transparent,
      titleSpacing: AppSizes.space24,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titles[currentIndex],
            style: AppTypography.headlineSmall(color: AppColors.onSurface),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSizes.space2),
          Text(
            subtitles[currentIndex],
            style: AppTypography.bodySmall(color: AppColors.onSurfaceVariant),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      actions: [_HomeHeaderAction(currentIndex: currentIndex)],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(76);
}

class _HeaderActionButton extends StatelessWidget {
  const _HeaderActionButton({
    required this.icon,
    required this.onPressed,
    this.rightPadding = 0,
    this.badgeCount = 0,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final double rightPadding;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: rightPadding),
      child: SizedBox(
        width: 44,
        height: 44,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: IconButton(
                onPressed: onPressed,
                icon: Icon(icon, color: AppColors.primary),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.surfaceContainerLowest,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppSizes.borderRadiusMd,
                  ),
                ),
              ),
            ),
            if (badgeCount > 0)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.space4,
                    vertical: 1,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: AppSizes.borderRadiusFull,
                    border: Border.all(color: AppColors.surface, width: 2),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    badgeCount > 99 ? '99+' : '$badgeCount',
                    style: AppTypography.bodySmall(
                      color: AppColors.onPrimary,
                    ).copyWith(fontSize: 9, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HomeHeaderAction extends StatelessWidget {
  const _HomeHeaderAction({required this.currentIndex});

  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    final rightPadding = currentIndex == 1
        ? AppSizes.space16
        : AppSizes.space20;

    if (currentIndex == 1) {
      return _HeaderActionButton(
        icon: Icons.people_outline_rounded,
        onPressed: () => Get.toNamed(AppRoutes.friends),
        rightPadding: rightPadding,
      );
    }

    final controller = Get.find<NotificationCenterController>();
    return Obx(
      () => _HeaderActionButton(
        icon: Icons.notifications_none_rounded,
        onPressed: () => Get.toNamed(AppRoutes.notifications),
        rightPadding: rightPadding,
        badgeCount: controller.totalUnreadCount.value,
      ),
    );
  }
}

class _CaptureFab extends StatefulWidget {
  const _CaptureFab();

  @override
  State<_CaptureFab> createState() => _CaptureFabState();
}

class _CaptureFabState extends State<_CaptureFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _scaleController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _scaleController.reverse();
    HapticFeedback.mediumImpact();
    Get.toNamed(AppRoutes.capture);
  }

  void _onTapCancel() {
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final spec = DDResponsiveSpec.of(context);
    final outerSize = spec.isCompact
        ? AppSizes.dockedCaptureOuterSize
        : AppSizes.dockedCaptureOuterSize + 4;
    final innerSize = spec.isCompact
        ? AppSizes.dockedCaptureInnerSize
        : AppSizes.dockedCaptureInnerSize + 2;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: SizedBox(
              width: outerSize,
              height: outerSize,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.outlineVariant.withValues(alpha: 0.4),
                    width: 0.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.outline.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Container(
                    width: innerSize,
                    height: innerSize,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.primary, AppColors.primaryContainer],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.camera_alt_outlined,
                        color: AppColors.onPrimary,
                        size: spec.isCompact ? 20 : 22,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
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
    final l10n = context.l10n;
    final titles = [
      l10n.todayTabTitle,
      l10n.buddyTabTitle,
      l10n.wallTabTitle,
      l10n.meTabTitle,
    ];
    final subtitles = [
      l10n.todayTabSubtitle,
      l10n.buddyTabSubtitle,
      l10n.wallTabSubtitle,
      l10n.meTabSubtitle,
    ];

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
                    titles[currentIndex],
                    style: AppTypography.headlineSmall(
                      color: AppColors.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSizes.space2),
                  Text(
                    subtitles[currentIndex],
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
            _HomeHeaderAction(currentIndex: currentIndex),
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
              destinations: [
                NavigationRailDestination(
                  icon: Icon(Icons.today_outlined),
                  selectedIcon: Icon(Icons.today),
                  label: Text(context.l10n.todayTabTitle),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.favorite_outline_rounded),
                  selectedIcon: Icon(Icons.favorite_rounded),
                  label: Text(context.l10n.buddyTabTitle),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.photo_library_outlined),
                  selectedIcon: Icon(Icons.photo_library_rounded),
                  label: Text(context.l10n.wallTabTitle),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.person_outline_rounded),
                  selectedIcon: Icon(Icons.person_rounded),
                  label: Text(context.l10n.meTabTitle),
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
