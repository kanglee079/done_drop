import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

/// DoneDrop App Bar — Glassmorphism top bar
class DDAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DDAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.leading,
    this.actions,
    this.elevation = 0,
  });

  final String? title;
  final Widget? titleWidget;
  final Widget? leading;
  final List<Widget>? actions;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: (isDark ? AppColors.darkSurface : AppColors.surface)
            .withValues(alpha: 0.85),
        boxShadow: elevation > 0
            ? [
                BoxShadow(
                  color: AppColors.outline.withValues(alpha: 0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ]
            : null,
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: AppSizes.appBarHeight,
          child: Row(
            children: [
              if (leading != null)
                leading!
              else
                const SizedBox(width: AppSizes.space16),
              Expanded(
                child: titleWidget ??
                    (title != null
                        ? Text(
                            title!,
                            style: TextStyle(
                              fontFamily: AppTypography.serifFamily,
                              fontSize: 20,
                              fontStyle: FontStyle.italic,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        : const SizedBox.shrink()),
              ),
              if (actions != null)
                ...actions!
              else
                const SizedBox(width: AppSizes.space16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(AppSizes.appBarHeight);
}

/// DoneDrop Screen Scaffold — Consistent screen wrapper
class DDScreen extends StatelessWidget {
  const DDScreen({
    super.key,
    this.appBar,
    required this.body,
    this.bottomNavBar,
    this.fab,
    this.padding,
    this.backgroundColor,
  });

  final DDAppBar? appBar;
  final Widget body;
  final Widget? bottomNavBar;
  final Widget? fab;
  final EdgeInsets? padding;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? AppColors.surface,
      appBar: appBar != null ? appBar as PreferredSizeWidget? : null,
      body: SafeArea(
        child: Padding(
          padding: padding ?? EdgeInsets.zero,
          child: body,
        ),
      ),
      bottomNavigationBar: bottomNavBar,
      floatingActionButton: fab,
    );
  }
}
