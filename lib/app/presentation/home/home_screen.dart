import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/theme.dart';
import '../../routes/app_routes.dart';
import '../../core/widgets/widgets.dart';
import 'home_controller.dart';
import '../friends/friends_controller.dart';
import 'task_controller.dart';

/// DoneDrop Home Screen — Today view
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
      _SettingsTab(),
    ];

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withValues(alpha: 0.85),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
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
            icon: const Icon(Icons.notifications_outlined,
                color: AppColors.primary),
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
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _TodayTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (ctrl) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.space24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Streak indicator
              Container(
                padding: const EdgeInsets.all(AppSizes.space20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: AppSizes.borderRadiusLg,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Reflection Journey',
                            style: TextStyle(
                              fontFamily: AppTypography.serifFamily,
                              fontSize: 18,
                              fontStyle: FontStyle.italic,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Build your daily habit',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: List.generate(7, (i) {
                        return Container(
                          width: 8,
                          height: 32,
                          margin: const EdgeInsets.only(left: 4),
                          decoration: BoxDecoration(
                            color: i < 3
                                ? AppColors.primary
                                : AppColors.primaryContainer.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.space32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Today's Focus",
                    style: TextStyle(
                      fontFamily: AppTypography.serifFamily,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.space12,
                      vertical: AppSizes.space4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.tertiaryFixed,
                      borderRadius: AppSizes.borderRadiusFull,
                    ),
                    child: Text(
                      'May 24',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onTertiaryFixed,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.space24),

              // Task list from Firestore
              Obx(() {
                final tasks = ctrl.tasks;
                if (tasks.isEmpty) {
                  return Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSizes.space20),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: AppSizes.borderRadiusMd,
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.lightbulb_outline, color: AppColors.primary),
                            const SizedBox(width: AppSizes.space12),
                            Expanded(
                              child: Text(
                                'No tasks yet. Capture your first moment to start building your streak!',
                                style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }
                return Column(
                  children: tasks.map((task) => _TaskItem(
                    title: task.title,
                    desc: task.category ?? '',
                    isDone: false,
                    onDone: () {
                      ctrl.archiveTask(task.id);
                      Get.toNamed(AppRoutes.capture);
                    },
                  )).toList(),
                );
              }),
              const SizedBox(height: AppSizes.space24),
              GestureDetector(
                onTap: () => Get.toNamed(AppRoutes.recap),
                child: Container(
                  padding: const EdgeInsets.all(AppSizes.space20),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: AppSizes.borderRadiusLg,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.auto_awesome, color: AppColors.primary, size: 24),
                      const SizedBox(width: AppSizes.space12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your Week in Moments',
                              style: TextStyle(
                                fontFamily: AppTypography.serifFamily,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.onSurface,
                              ),
                            ),
                            Text(
                              'View your weekly recap',
                              style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: AppColors.outline),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TaskItem extends StatelessWidget {
  const _TaskItem({
    required this.title,
    required this.desc,
    required this.isDone,
    this.onToggle,
    required this.onDone,
  });

  final String title;
  final String desc;
  final bool isDone;
  final VoidCallback? onToggle;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.space8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: (isDone && onToggle != null) ? onToggle : onDone,
            child: Container(
              width: 24,
              height: 24,
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                color: isDone ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isDone
                      ? AppColors.primary
                      : AppColors.outlineVariant,
                  width: 2,
                ),
              ),
              child: isDone
                  ? const Icon(Icons.check,
                      size: 14, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: AppSizes.space16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDone
                        ? AppColors.onSurfaceVariant
                        : AppColors.onSurface,
                    decoration:
                        isDone ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.onSurfaceVariant,
                    decoration:
                        isDone ? TextDecoration.lineThrough : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get or create a FriendsController to watch request count
    final friendsCtrl = Get.put(FriendsController(Get.find()));

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.group_outlined,
              size: 56, color: AppColors.outlineVariant),
          const SizedBox(height: AppSizes.space16),
          Text(
            'Circle Feed',
            style: TextStyle(
              fontFamily: AppTypography.serifFamily,
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Share moments privately with\nfriends or circles.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSizes.space24),
          DDPrimaryButton(
            label: 'Create a Circle',
            icon: Icons.add,
            onPressed: () => Get.toNamed(AppRoutes.createCircle),
            isExpanded: false,
          ),
          const SizedBox(height: AppSizes.space12),
          DDSecondaryButton(
            label: 'Join with Code',
            icon: Icons.qr_code,
            onPressed: () => Get.toNamed(AppRoutes.joinCircle),
            isExpanded: false,
          ),
          const SizedBox(height: AppSizes.space12),
          Obx(() => DDSecondaryButton(
            label: friendsCtrl.hasPendingRequests
                ? 'Friends (${friendsCtrl.pendingRequestCount.value} pending)'
                : 'Friends',
            icon: Icons.people_outline,
            onPressed: () => Get.toNamed(AppRoutes.friends),
            isExpanded: false,
          )),
        ],
      ),
    );
  }
}

class _WallTab extends StatelessWidget {
  const _WallTab();

  @override
  Widget build(BuildContext context) {
    // Navigate to the full MemoryWallScreen with real data
    return Center(
      child: DDEmptyState(
        title: 'Your Memory Wall',
        description: 'Your personal museum of moments will appear here.',
        icon: Icons.auto_awesome_mosaic_outlined,
        actionLabel: 'View your moments',
        onAction: () => Get.toNamed(AppRoutes.memoryWall),
      ),
    );
  }
}

class _SettingsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.settings_outlined,
              size: 56, color: AppColors.outlineVariant),
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
