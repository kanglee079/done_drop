import 'package:flutter/material.dart';
import 'package:done_drop/app/presentation/home/home_controller.dart';
import 'package:done_drop/core/models/activity.dart';
import 'package:done_drop/core/models/activity_instance.dart';
import 'package:done_drop/core/theme/theme.dart';

enum HabitCardVariant { hero, content }

class HabitActionCard extends StatelessWidget {
  const HabitActionCard({
    super.key,
    required this.activity,
    required this.instance,
    required this.variant,
    required this.actionState,
    required this.isCompleted,
    required this.isOverdue,
    this.onCompleteNow,
    this.onCompleteWithProof,
  });

  final Activity activity;
  final ActivityInstance? instance;
  final HabitCardVariant variant;
  final HabitActionState actionState;
  final bool isCompleted;
  final bool isOverdue;
  final Future<void> Function()? onCompleteNow;
  final Future<void> Function()? onCompleteWithProof;

  bool get isBusy => actionState != HabitActionState.none;
  bool get hasProof => (instance?.momentId ?? '').isNotEmpty;

  @override
  Widget build(BuildContext context) {
    if (variant == HabitCardVariant.hero) {
      return _HeroHabitCard(
        activity: activity,
        isCompleted: isCompleted,
        isOverdue: isOverdue,
        hasProof: hasProof,
        actionState: actionState,
        onCompleteNow: onCompleteNow,
        onCompleteWithProof: onCompleteWithProof,
      );
    }

    return _ContentHabitCard(
      activity: activity,
      isCompleted: isCompleted,
      isOverdue: isOverdue,
      hasProof: hasProof,
      actionState: actionState,
      onCompleteNow: onCompleteNow,
      onCompleteWithProof: onCompleteWithProof,
    );
  }
}

class _HeroHabitCard extends StatelessWidget {
  const _HeroHabitCard({
    required this.activity,
    required this.isCompleted,
    required this.isOverdue,
    required this.hasProof,
    required this.actionState,
    required this.onCompleteNow,
    required this.onCompleteWithProof,
  });

  final Activity activity;
  final bool isCompleted;
  final bool isOverdue;
  final bool hasProof;
  final HabitActionState actionState;
  final Future<void> Function()? onCompleteNow;
  final Future<void> Function()? onCompleteWithProof;

  bool get _isBusy => actionState != HabitActionState.none;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppMotion.medium,
      curve: AppMotion.standard,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isCompleted
              ? [AppColors.tertiaryFixed, AppColors.surfaceContainerLowest]
              : [AppColors.primary, AppColors.primaryContainer],
        ),
        borderRadius: AppSizes.borderRadiusLg,
        boxShadow: AppColors.elevatedShadow,
      ),
      padding: const EdgeInsets.all(AppSizes.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isOverdue ? 'Overdue now' : 'Next up',
                      style: AppTypography.labelMedium(
                        color: isCompleted
                            ? AppColors.tertiary
                            : AppColors.onPrimary.withValues(alpha: 0.84),
                      ),
                    ),
                    const SizedBox(height: AppSizes.space8),
                    Text(
                      activity.title,
                      style: AppTypography.headlineMedium(
                        color: isCompleted
                            ? AppColors.onSurface
                            : AppColors.onPrimary,
                      ),
                    ),
                    if ((activity.category ?? '').isNotEmpty) ...[
                      const SizedBox(height: AppSizes.space8),
                      Text(
                        activity.category!,
                        style: AppTypography.bodyMedium(
                          color: isCompleted
                              ? AppColors.onSurfaceVariant
                              : AppColors.onPrimary.withValues(alpha: 0.78),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              _StreakBadge(
                streak: activity.currentStreak,
                isCompleted: isCompleted,
                isInverted: !isCompleted,
              ),
            ],
          ),
          const SizedBox(height: AppSizes.space24),
          Row(
            children: [
              Expanded(
                child: _HeroMetaChip(
                  icon: hasProof ? Icons.verified_outlined : Icons.lock_outline,
                  label: hasProof ? 'Proof attached' : 'Private by default',
                  inverted: !isCompleted,
                ),
              ),
              const SizedBox(width: AppSizes.space8),
              Expanded(
                child: _HeroMetaChip(
                  icon: isOverdue ? Icons.schedule_outlined : Icons.bolt_outlined,
                  label: isOverdue ? 'Needs recovery' : 'One tap to finish',
                  inverted: !isCompleted,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.space24),
          if (isCompleted)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: AppSizes.space16),
              decoration: BoxDecoration(
                color: AppColors.onPrimary.withValues(alpha: 0.12),
                borderRadius: AppSizes.borderRadiusMd,
              ),
              child: Text(
                hasProof ? 'Completed with proof today' : 'Completed today',
                textAlign: TextAlign.center,
                style: AppTypography.labelLarge(
                  color: isCompleted
                      ? AppColors.onSurface
                      : AppColors.onPrimary,
                ),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    key: const Key('complete-now-button'),
                    label: 'Complete now',
                    icon: Icons.check_rounded,
                    isPrimary: false,
                    isLoading: actionState == HabitActionState.quickComplete,
                    onTap: _isBusy ? null : onCompleteNow,
                  ),
                ),
                const SizedBox(width: AppSizes.space12),
                Expanded(
                  child: _ActionButton(
                    key: const Key('complete-proof-button'),
                    label: 'Complete + proof',
                    icon: Icons.camera_alt_outlined,
                    isPrimary: true,
                    isLoading:
                        actionState == HabitActionState.completeWithProof,
                    onTap: _isBusy ? null : onCompleteWithProof,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _ContentHabitCard extends StatelessWidget {
  const _ContentHabitCard({
    required this.activity,
    required this.isCompleted,
    required this.isOverdue,
    required this.hasProof,
    required this.actionState,
    required this.onCompleteNow,
    required this.onCompleteWithProof,
  });

  final Activity activity;
  final bool isCompleted;
  final bool isOverdue;
  final bool hasProof;
  final HabitActionState actionState;
  final Future<void> Function()? onCompleteNow;
  final Future<void> Function()? onCompleteWithProof;

  bool get _isBusy => actionState != HabitActionState.none;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppMotion.medium,
      curve: AppMotion.standard,
      padding: const EdgeInsets.all(AppSizes.space16),
      decoration: BoxDecoration(
        color: isCompleted
            ? AppColors.surfaceContainerLowest
            : AppColors.surfaceContainerLow,
        borderRadius: AppSizes.borderRadiusLg,
        border: Border.all(
          color: isOverdue
              ? AppColors.error.withValues(alpha: 0.28)
              : AppColors.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          _CompletionPill(
            isCompleted: isCompleted,
            isBusy: actionState == HabitActionState.quickComplete,
            onTap: isCompleted || _isBusy ? null : onCompleteNow,
          ),
          const SizedBox(width: AppSizes.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style:
                      AppTypography.titleMedium(
                        color: isCompleted
                            ? AppColors.onSurfaceVariant
                            : AppColors.onSurface,
                      ).copyWith(
                        decoration: isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                ),
                const SizedBox(height: AppSizes.space6),
                Row(
                  children: [
                    if ((activity.category ?? '').isNotEmpty)
                      Flexible(
                        child: Text(
                          activity.category!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodySmall(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    if (hasProof) ...[
                      const SizedBox(width: AppSizes.space8),
                      const Icon(
                        Icons.verified_outlined,
                        size: 14,
                        color: AppColors.tertiary,
                      ),
                      const SizedBox(width: AppSizes.space4),
                      Text(
                        'Proof',
                        style: AppTypography.bodySmall(
                          color: AppColors.tertiary,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.space8),
          _StreakBadge(
            streak: activity.currentStreak,
            isCompleted: isCompleted,
            isInverted: false,
          ),
          if (!isCompleted) ...[
            const SizedBox(width: AppSizes.space8),
            _ProofButton(
              isBusy: actionState == HabitActionState.completeWithProof,
              onTap: _isBusy ? null : onCompleteWithProof,
            ),
          ],
        ],
      ),
    );
  }
}

class _CompletionPill extends StatelessWidget {
  const _CompletionPill({
    required this.isCompleted,
    required this.isBusy,
    required this.onTap,
  });

  final bool isCompleted;
  final bool isBusy;
  final Future<void> Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: const Key('list-complete-pill'),
        borderRadius: BorderRadius.circular(14),
        onTap: onTap == null ? null : () => onTap!.call(),
        child: Ink(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: isCompleted ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isCompleted ? AppColors.primary : AppColors.outline,
              width: 1.6,
            ),
          ),
          child: Center(
            child: isBusy
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                : isCompleted
                ? const Icon(
                    Icons.check_rounded,
                    size: 18,
                    color: AppColors.onPrimary,
                  )
                : null,
          ),
        ),
      ),
    );
  }
}

class _ProofButton extends StatelessWidget {
  const _ProofButton({required this.isBusy, required this.onTap});

  final bool isBusy;
  final Future<void> Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: const Key('list-proof-button'),
        borderRadius: AppSizes.borderRadiusFull,
        onTap: onTap == null ? null : () => onTap!.call(),
        child: Ink(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.space12,
            vertical: AppSizes.space10,
          ),
          decoration: BoxDecoration(
            color: AppColors.primaryFixed,
            borderRadius: AppSizes.borderRadiusFull,
          ),
          child: isBusy
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                )
              : const Icon(
                  Icons.camera_alt_outlined,
                  size: 16,
                  color: AppColors.primary,
                ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.isPrimary,
    required this.isLoading,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isPrimary;
  final bool isLoading;
  final Future<void> Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: key,
        borderRadius: AppSizes.borderRadiusMd,
        onTap: onTap == null ? null : () => onTap!.call(),
        child: Ink(
          padding: const EdgeInsets.symmetric(vertical: AppSizes.space16),
          decoration: BoxDecoration(
            color: isPrimary
                ? AppColors.surfaceContainerLowest
                : Colors.white.withValues(alpha: 0.14),
            borderRadius: AppSizes.borderRadiusMd,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: isPrimary ? AppColors.primary : AppColors.onPrimary,
                  ),
                )
              else ...[
                Icon(
                  icon,
                  size: 16,
                  color: isPrimary ? AppColors.primary : AppColors.onPrimary,
                ),
                const SizedBox(width: AppSizes.space8),
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.labelLarge(
                      color: isPrimary
                          ? AppColors.primary
                          : AppColors.onPrimary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StreakBadge extends StatelessWidget {
  const _StreakBadge({
    required this.streak,
    required this.isCompleted,
    required this.isInverted,
  });

  final int streak;
  final bool isCompleted;
  final bool isInverted;

  @override
  Widget build(BuildContext context) {
    if (streak <= 0) return const SizedBox.shrink();

    final backgroundColor = isInverted
        ? Colors.white.withValues(alpha: 0.14)
        : AppColors.primaryFixed;
    final foregroundColor = isInverted
        ? AppColors.onPrimary
        : AppColors.primary;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.space12,
        vertical: AppSizes.space8,
      ),
      decoration: BoxDecoration(
        color: isCompleted ? AppColors.tertiaryFixed : backgroundColor,
        borderRadius: AppSizes.borderRadiusFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department_outlined,
            size: 15,
            color: isCompleted ? AppColors.tertiary : foregroundColor,
          ),
          const SizedBox(width: AppSizes.space4),
          Text(
            '$streak',
            style: AppTypography.labelMedium(
              color: isCompleted ? AppColors.tertiary : foregroundColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroMetaChip extends StatelessWidget {
  const _HeroMetaChip({
    required this.icon,
    required this.label,
    required this.inverted,
  });

  final IconData icon;
  final String label;
  final bool inverted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.space12,
        vertical: AppSizes.space8,
      ),
      decoration: BoxDecoration(
        color: inverted
            ? Colors.white.withValues(alpha: 0.14)
            : AppColors.surfaceContainerLow,
        borderRadius: AppSizes.borderRadiusFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: inverted ? AppColors.onPrimary : AppColors.onSurfaceVariant,
          ),
          const SizedBox(width: AppSizes.space6),
          Flexible(
            child: Text(
              label,
              style: AppTypography.bodySmall(
                color: inverted
                    ? AppColors.onPrimary
                    : AppColors.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
