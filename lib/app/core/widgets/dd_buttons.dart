import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

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
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
    return isExpanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// DoneDrop Secondary Button — Surface fill, no border
class DDSecondaryButton extends StatelessWidget {
  const DDSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isExpanded = true,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isExpanded;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final button = GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        height: AppSizes.buttonHeightMd,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: AppSizes.borderRadiusMd,
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
                      Icon(icon, color: AppColors.onSurface, size: 20),
                      const SizedBox(width: AppSizes.space8),
                    ],
                    Text(
                      label,
                      style: const TextStyle(
                        color: AppColors.onSurface,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
    return isExpanded ? SizedBox(width: double.infinity, child: button) : button;
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
                color: AppColors.primary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
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
    return isExpanded ? SizedBox(width: double.infinity, child: button) : button;
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
