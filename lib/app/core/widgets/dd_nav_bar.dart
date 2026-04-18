import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:done_drop/core/theme/theme.dart';
import 'package:done_drop/app/core/widgets/dd_responsive.dart';
import 'package:done_drop/l10n/l10n.dart';

class DDBottomNavBar extends StatelessWidget {
  const DDBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onCaptureTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onCaptureTap;

  static const _navItems = [
    _NavItem(
      index: 0,
      icon: Icons.today_outlined,
      activeIcon: Icons.today,
    ),
    _NavItem(
      index: 1,
      icon: Icons.favorite_outline_rounded,
      activeIcon: Icons.favorite_rounded,
    ),
    _NavItem(
      index: 2,
      icon: Icons.photo_library_outlined,
      activeIcon: Icons.photo_library_rounded,
    ),
    _NavItem(
      index: 3,
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.72),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppSizes.navBarRadius),
            ),
            border: Border(
              top: BorderSide(
                color: AppColors.outlineVariant.withValues(alpha: 0.24),
                width: 0.5,
              ),
            ),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withValues(alpha: 0.15),
                Colors.white.withValues(alpha: 0.05),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: AppSizes.glassNavBarHeight,
              child: Row(
                children: [
                  for (final item in _navItems.take(2))
                    Expanded(
                      child: _GlassNavButton(
                        item: item,
                        isActive: currentIndex == item.index,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          onTap(item.index);
                        },
                      ),
                    ),
                  SizedBox(
                    width: 72,
                    child: Center(
                      child: _CaptureDockButton(onTap: onCaptureTap),
                    ),
                  ),
                  for (final item in _navItems.skip(2))
                    Expanded(
                      child: _GlassNavButton(
                        item: item,
                        isActive: currentIndex == item.index,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          onTap(item.index);
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CaptureDockButton extends StatelessWidget {
  const _CaptureDockButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      height: 50,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            HapticFeedback.mediumImpact();
            onTap();
          },
          child: Ink(
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.94),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.5),
                width: 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.outline.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary,
                      AppColors.primaryContainer,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(
                    Icons.camera_alt_outlined,
                    color: AppColors.onPrimary,
                    size: 19,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassNavButton extends StatelessWidget {
  const _GlassNavButton({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  final _NavItem item;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final spec = DDResponsiveSpec.of(context);
    final textScaleFactor = MediaQuery.textScalerOf(context).scale(12) / 12;
    final hideLabel = spec.width < 360 || textScaleFactor > 1.2;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primary.withValues(alpha: 0.14)
                    : Colors.transparent,
                borderRadius: AppSizes.borderRadiusFull,
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  isActive ? item.activeIcon : item.icon,
                  key: ValueKey(isActive),
                  color: isActive ? AppColors.primary : AppColors.outline,
                  size: 22,
                ),
              ),
            ),
            if (!hideLabel) ...[
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: AppTypography.bodySmall(
                  color: isActive ? AppColors.primary : AppColors.outline,
                ).copyWith(
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  fontSize: isActive ? 11.5 : 11,
                ),
                child: Text(item.label(context)),
              ),
            ],
          ],
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
  });

  final int index;
  final IconData icon;
  final IconData activeIcon;

  String label(BuildContext context) => switch (index) {
        0 => context.l10n.todayTabTitle,
        1 => context.l10n.buddyTabTitle,
        2 => context.l10n.wallTabTitle,
        _ => context.l10n.meTabTitle,
      };
}
