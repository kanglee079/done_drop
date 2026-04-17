import 'package:flutter/material.dart';
import 'package:done_drop/core/theme/theme.dart';

class DDBottomNavBar extends StatelessWidget {
  const DDBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _navItems = [
    _NavItem(
      index: 0,
      icon: Icons.today_outlined,
      activeIcon: Icons.today,
      label: 'Today',
    ),
    _NavItem(
      index: 1,
      icon: Icons.favorite_outline_rounded,
      activeIcon: Icons.favorite_rounded,
      label: 'Buddy',
    ),
    _NavItem(
      index: 2,
      icon: Icons.photo_library_outlined,
      activeIcon: Icons.photo_library_rounded,
      label: 'Wall',
    ),
    _NavItem(
      index: 3,
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Me',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.94),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSizes.navBarRadius),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.outline.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: AppSizes.navBarHeight + 8,
          child: Row(
            children: [
              for (final item in _navItems.take(2))
                Expanded(
                  child: _NavBarButton(
                    item: item,
                    isActive: currentIndex == item.index,
                    onTap: () => onTap(item.index),
                  ),
                ),
              const Spacer(),
              for (final item in _navItems.skip(2))
                Expanded(
                  child: _NavBarButton(
                    item: item,
                    isActive: currentIndex == item.index,
                    onTap: () => onTap(item.index),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavBarButton extends StatelessWidget {
  const _NavBarButton({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  final _NavItem item;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: SizedBox(
          height: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: AppMotion.fast,
                curve: AppMotion.standard,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.space12,
                  vertical: AppSizes.space8,
                ),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primaryFixed : Colors.transparent,
                  borderRadius: AppSizes.borderRadiusFull,
                ),
                child: Icon(
                  isActive ? item.activeIcon : item.icon,
                  color: isActive ? AppColors.primary : AppColors.outline,
                  size: 22,
                ),
              ),
              const SizedBox(height: AppSizes.space4),
              Text(
                item.label,
                style: AppTypography.bodySmall(
                  color: isActive ? AppColors.primary : AppColors.outline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.index,
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final int index;
  final IconData icon;
  final IconData activeIcon;
  final String label;
}
