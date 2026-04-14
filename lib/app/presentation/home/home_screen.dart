import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

// ── Part files — each tab is in its own file for maintainability ─────────────
part 'tabs/today_tab.dart';
part 'tabs/activity_item.dart';
part 'tabs/feed_tab.dart';
part 'tabs/wall_tab.dart';
part 'tabs/settings_tab.dart';

/// DoneDrop Home Screen — Discipline-first personal accountability.
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
              onTap: (i) {
                HapticFeedback.selectionClick();
                nav.setTab(i);
              },
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
