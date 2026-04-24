import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

class _ExpandIfPossible extends StatelessWidget {
  const _ExpandIfPossible({required this.expand, required this.child});

  final bool expand;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!expand) return child;

    // Avoid forcing infinite width when the button sits in an unconstrained Row/Wrap.
    return LayoutBuilder(
      builder: (context, constraints) {
        if (!constraints.hasBoundedWidth) return child;
        return SizedBox(width: double.infinity, child: child);
      },
    );
  }
}

/// DoneDrop Primary Button — Gradient CTA
class DDPrimaryButton extends StatelessWidget {
  const DDPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isExpanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    final button = GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        height: AppSizes.buttonHeightMd,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: AppSizes.borderRadiusMd,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, color: Colors.white, size: 20),
                      const SizedBox(width: AppSizes.space8),
                    ],
                    Text(
                      label,
                      style: const TextStyle(
                        fontFamily: AppTypography.sansFamily,
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800, // Sharper bolder text
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
    return _ExpandIfPossible(expand: isExpanded, child: button);
  }
}

/// DoneDrop Secondary Button — Surface fill, no border
class DDSecondaryButton extends StatelessWidget {
  const DDSecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isExpanded = true,
    this.isLoading = false,
    this.isEnabled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isExpanded;
  final bool isLoading;

  /// When false, button appears dimmed and taps are ignored
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    final enabled = isEnabled && !isLoading;
    final button = GestureDetector(
      onTap: enabled ? onPressed : null,
      child: Container(
        height: AppSizes.buttonHeightMd,
        decoration: BoxDecoration(
          borderRadius: AppSizes.borderRadiusMd,
          color: enabled
              ? Theme.of(context).colorScheme.surfaceContainerHighest
              : Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(AppColors.onSurface),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(
                        icon,
                        color: enabled
                            ? AppColors.onSurface
                            : AppColors.outline,
                        size: 20,
                      ),
                      const SizedBox(width: AppSizes.space8),
                    ],
                    Text(
                      label,
                      style: TextStyle(
                        fontFamily: AppTypography.sansFamily,
                        color: enabled
                            ? AppColors.onSurface
                            : AppColors.outline,
                        fontSize: 14,
                        fontWeight: FontWeight.w700, // slightly bolder
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
    return _ExpandIfPossible(expand: isExpanded, child: button);
  }
}

/// DoneDrop Text Button — For tertiary actions
class DDTextButton extends StatelessWidget {
  const DDTextButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isExpanded = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    final button = GestureDetector(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.space16,
          vertical: AppSizes.space8,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontFamily: AppTypography.sansFamily,
                color: AppColors.primary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.primary,
                decorationThickness: 1,
              ),
            ),
            if (icon != null) ...[
              const SizedBox(width: AppSizes.space4),
              Icon(icon, color: AppColors.primary, size: 18),
            ],
          ],
        ),
      ),
    );
    return _ExpandIfPossible(expand: isExpanded, child: button);
  }
}

/// DoneDrop Icon Button — Circle avatar-style
class DDIconButton extends StatelessWidget {
  const DDIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = AppSizes.avatarMd,
    this.backgroundColor,
    this.foregroundColor,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.surfaceContainerHigh,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(
            icon,
            color: foregroundColor ?? AppColors.primary,
            size: size * 0.5,
          ),
        ),
      ),
    );
  }
}
