import 'package:flutter/material.dart';
import 'package:done_drop/app/presentation/home/home_controller.dart';
import 'package:done_drop/core/models/activity.dart';
import 'package:done_drop/core/models/activity_instance.dart';
import 'package:done_drop/core/theme/theme.dart';
import 'package:done_drop/core/utils/activity_utils.dart';
import 'package:done_drop/l10n/l10n.dart';

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
    this.onCompleteWithProof,
    this.onEdit,
    this.onArchive,
    this.onDelete,
  });

  final Activity activity;
  final ActivityInstance? instance;
  final HabitCardVariant variant;
  final HabitActionState actionState;
  final bool isCompleted;
  final bool isOverdue;
  final Future<void> Function()? onCompleteWithProof;
  final Future<void> Function()? onEdit;
  final Future<void> Function()? onArchive;
  final Future<void> Function()? onDelete;

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
        onCompleteWithProof: onCompleteWithProof,
        onEdit: onEdit,
        onArchive: onArchive,
        onDelete: onDelete,
      );
    }

    return _ContentHabitCard(
      activity: activity,
      isCompleted: isCompleted,
      isOverdue: isOverdue,
      hasProof: hasProof,
      actionState: actionState,
      onCompleteWithProof: onCompleteWithProof,
      onEdit: onEdit,
      onArchive: onArchive,
      onDelete: onDelete,
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
    required this.onCompleteWithProof,
    required this.onEdit,
    required this.onArchive,
    required this.onDelete,
  });

  final Activity activity;
  final bool isCompleted;
  final bool isOverdue;
  final bool hasProof;
  final HabitActionState actionState;
  final Future<void> Function()? onCompleteWithProof;
  final Future<void> Function()? onEdit;
  final Future<void> Function()? onArchive;
  final Future<void> Function()? onDelete;

  bool get _isBusy => actionState != HabitActionState.none;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompactHero = constraints.maxWidth < 390;
        final reminderLabel = activity.hasReminder
            ? MaterialLocalizations.of(context).formatTimeOfDay(
                parseReminderTime(activity.reminderTime),
                alwaysUse24HourFormat: false,
              )
            : isOverdue
            ? l10n.heroNeedsRecovery
            : l10n.heroOneTapToFinish;
        final reminderIcon = activity.hasReminder
            ? Icons.schedule_outlined
            : isOverdue
            ? Icons.schedule_outlined
            : Icons.bolt_outlined;

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
          padding: EdgeInsets.all(
            isCompactHero ? AppSizes.space20 : AppSizes.space24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isCompactHero)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _HeroHeadline(
                            activity: activity,
                            isCompleted: isCompleted,
                            isOverdue: isOverdue,
                            compact: true,
                          ),
                        ),
                        const SizedBox(width: AppSizes.space8),
                        _HabitManagementMenu(
                          onEdit: onEdit,
                          onArchive: onArchive,
                          onDelete: onDelete,
                          foregroundColor: isCompleted
                              ? AppColors.onSurfaceVariant
                              : AppColors.onPrimary,
                          backgroundColor: isCompleted
                              ? AppColors.surfaceContainerHigh
                              : AppColors.onPrimary.withValues(alpha: 0.12),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.space12),
                    _StreakBadge(
                      streak: activity.currentStreak,
                      isCompleted: isCompleted,
                      isInverted: !isCompleted,
                    ),
                  ],
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _HeroHeadline(
                        activity: activity,
                        isCompleted: isCompleted,
                        isOverdue: isOverdue,
                        compact: false,
                      ),
                    ),
                    const SizedBox(width: AppSizes.space8),
                    _HabitManagementMenu(
                      onEdit: onEdit,
                      onArchive: onArchive,
                      onDelete: onDelete,
                      foregroundColor: isCompleted
                          ? AppColors.onSurfaceVariant
                          : AppColors.onPrimary,
                      backgroundColor: isCompleted
                          ? AppColors.surfaceContainerHigh
                          : AppColors.onPrimary.withValues(alpha: 0.12),
                    ),
                    const SizedBox(width: AppSizes.space8),
                    _StreakBadge(
                      streak: activity.currentStreak,
                      isCompleted: isCompleted,
                      isInverted: !isCompleted,
                    ),
                  ],
                ),
              const SizedBox(height: AppSizes.space20),
              if (isCompactHero)
                Column(
                  children: [
                    _HeroMetaChip(
                      icon: hasProof
                          ? Icons.verified_outlined
                          : Icons.lock_outline,
                      label: hasProof
                          ? l10n.heroProofAttached
                          : l10n.heroPrivateByDefault,
                      inverted: !isCompleted,
                    ),
                    const SizedBox(height: AppSizes.space8),
                    _HeroMetaChip(
                      icon: reminderIcon,
                      label: reminderLabel,
                      inverted: !isCompleted,
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: _HeroMetaChip(
                        icon: hasProof
                            ? Icons.verified_outlined
                            : Icons.lock_outline,
                        label: hasProof
                            ? l10n.heroProofAttached
                            : l10n.heroPrivateByDefault,
                        inverted: !isCompleted,
                      ),
                    ),
                    const SizedBox(width: AppSizes.space8),
                    Expanded(
                      child: _HeroMetaChip(
                        icon: reminderIcon,
                        label: reminderLabel,
                        inverted: !isCompleted,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: AppSizes.space20),
              if (isCompleted)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSizes.space16,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.onPrimary.withValues(alpha: 0.12),
                    borderRadius: AppSizes.borderRadiusMd,
                  ),
                  child: Text(
                    hasProof
                        ? l10n.heroCompletedWithProof
                        : l10n.heroCompletedToday,
                    textAlign: TextAlign.center,
                    style: AppTypography.labelLarge(
                      color: isCompleted
                          ? AppColors.onSurface
                          : AppColors.onPrimary,
                    ),
                  ),
                )
              else if (isCompactHero)
                Column(
                  children: [
                    _ActionButton(
                      key: const Key('complete-proof-button'),
                      label: l10n.completeWithProofAction,
                      icon: Icons.camera_alt_outlined,
                      isPrimary: true,
                      isLoading:
                          actionState == HabitActionState.completeWithProof,
                      showLoading:
                          actionState == HabitActionState.completeWithProof,
                      onTap: _isBusy ? null : onCompleteWithProof,
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        key: const Key('complete-proof-button'),
                        label: l10n.completeWithProofAction,
                        icon: Icons.camera_alt_outlined,
                        isPrimary: true,
                        isLoading:
                            actionState == HabitActionState.completeWithProof,
                        showLoading:
                            actionState == HabitActionState.completeWithProof,
                        onTap: _isBusy ? null : onCompleteWithProof,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

class _HeroHeadline extends StatelessWidget {
  const _HeroHeadline({
    required this.activity,
    required this.isCompleted,
    required this.isOverdue,
    required this.compact,
  });

  final Activity activity;
  final bool isCompleted;
  final bool isOverdue;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isOverdue ? l10n.heroOverdueNow : l10n.heroNextUp,
          style: AppTypography.labelMedium(
            color: isCompleted
                ? AppColors.tertiary
                : AppColors.onPrimary.withValues(alpha: 0.84),
          ),
        ),
        const SizedBox(height: AppSizes.space8),
        Text(
          activity.title,
          style:
              (compact
                      ? AppTypography.headlineSmall(
                          color: isCompleted
                              ? AppColors.onSurface
                              : AppColors.onPrimary,
                        )
                      : AppTypography.headlineMedium(
                          color: isCompleted
                              ? AppColors.onSurface
                              : AppColors.onPrimary,
                        ))
                  .copyWith(height: 1.05),
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
    required this.onCompleteWithProof,
    required this.onEdit,
    required this.onArchive,
    required this.onDelete,
  });

  final Activity activity;
  final bool isCompleted;
  final bool isOverdue;
  final bool hasProof;
  final HabitActionState actionState;
  final Future<void> Function()? onCompleteWithProof;
  final Future<void> Function()? onEdit;
  final Future<void> Function()? onArchive;
  final Future<void> Function()? onDelete;

  bool get _isBusy => actionState != HabitActionState.none;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 360;
        final infoBlock = Column(
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
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
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
                    l10n.proofLabel,
                    style: AppTypography.bodySmall(color: AppColors.tertiary),
                  ),
                ],
              ],
            ),
          ],
        );

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
          child: isCompact
              ? Column(
                  children: [
                    Row(
                      children: [
                        _CompletionPill(
                          isCompleted: isCompleted,
                          isBusy: _isBusy,
                          onTap: isCompleted || _isBusy
                              ? null
                              : onCompleteWithProof,
                        ),
                        const SizedBox(width: AppSizes.space12),
                        Expanded(child: infoBlock),
                        const SizedBox(width: AppSizes.space8),
                        _StreakBadge(
                          streak: activity.currentStreak,
                          isCompleted: isCompleted,
                          isInverted: false,
                        ),
                        const SizedBox(width: AppSizes.space8),
                        _HabitManagementMenu(
                          onEdit: onEdit,
                          onArchive: onArchive,
                          onDelete: onDelete,
                          foregroundColor: AppColors.onSurfaceVariant,
                          backgroundColor: AppColors.surfaceContainerHighest,
                        ),
                      ],
                    ),
                    if (!isCompleted) ...[
                      const SizedBox(height: AppSizes.space12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: _ProofButton(
                          isBusy:
                              actionState == HabitActionState.completeWithProof,
                          onTap: _isBusy ? null : onCompleteWithProof,
                        ),
                      ),
                    ],
                  ],
                )
              : Row(
                  children: [
                    _CompletionPill(
                      isCompleted: isCompleted,
                      isBusy: _isBusy,
                      onTap: isCompleted || _isBusy
                          ? null
                          : onCompleteWithProof,
                    ),
                    const SizedBox(width: AppSizes.space12),
                    Expanded(child: infoBlock),
                    const SizedBox(width: AppSizes.space8),
                    _StreakBadge(
                      streak: activity.currentStreak,
                      isCompleted: isCompleted,
                      isInverted: false,
                    ),
                    const SizedBox(width: AppSizes.space8),
                    _HabitManagementMenu(
                      onEdit: onEdit,
                      onArchive: onArchive,
                      onDelete: onDelete,
                      foregroundColor: AppColors.onSurfaceVariant,
                      backgroundColor: AppColors.surfaceContainerHighest,
                    ),
                    if (!isCompleted) ...[
                      const SizedBox(width: AppSizes.space8),
                      _ProofButton(
                        isBusy:
                            actionState == HabitActionState.completeWithProof,
                        onTap: _isBusy ? null : onCompleteWithProof,
                      ),
                    ],
                  ],
                ),
        );
      },
    );
  }
}

enum _HabitCardMenuAction { edit, archive, delete }

class _HabitManagementMenu extends StatelessWidget {
  const _HabitManagementMenu({
    required this.onEdit,
    required this.onArchive,
    required this.onDelete,
    required this.foregroundColor,
    required this.backgroundColor,
  });

  final Future<void> Function()? onEdit;
  final Future<void> Function()? onArchive;
  final Future<void> Function()? onDelete;
  final Color foregroundColor;
  final Color backgroundColor;

  bool get _hasActions =>
      onEdit != null || onArchive != null || onDelete != null;

  @override
  Widget build(BuildContext context) {
    if (!_hasActions) {
      return const SizedBox.shrink();
    }

    final l10n = context.l10n;
    return PopupMenuButton<_HabitCardMenuAction>(
      tooltip: l10n.habitActionMenuTooltip,
      color: AppColors.surfaceContainerLowest,
      onSelected: (value) {
        switch (value) {
          case _HabitCardMenuAction.edit:
            onEdit?.call();
            break;
          case _HabitCardMenuAction.archive:
            onArchive?.call();
            break;
          case _HabitCardMenuAction.delete:
            onDelete?.call();
            break;
        }
      },
      itemBuilder: (context) => [
        if (onEdit != null)
          PopupMenuItem<_HabitCardMenuAction>(
            value: _HabitCardMenuAction.edit,
            child: Row(
              children: [
                const Icon(Icons.edit_outlined, size: 18),
                const SizedBox(width: AppSizes.space10),
                Text(l10n.editAction),
              ],
            ),
          ),
        if (onArchive != null)
          PopupMenuItem<_HabitCardMenuAction>(
            value: _HabitCardMenuAction.archive,
            child: Row(
              children: [
                const Icon(Icons.archive_outlined, size: 18),
                const SizedBox(width: AppSizes.space10),
                Text(l10n.archiveAction),
              ],
            ),
          ),
        if (onDelete != null)
          PopupMenuItem<_HabitCardMenuAction>(
            value: _HabitCardMenuAction.delete,
            child: Row(
              children: [
                const Icon(
                  Icons.delete_outline_rounded,
                  size: 18,
                  color: AppColors.error,
                ),
                const SizedBox(width: AppSizes.space10),
                Text(
                  l10n.deleteAction,
                  style: const TextStyle(color: AppColors.error),
                ),
              ],
            ),
          ),
      ],
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.more_horiz_rounded, color: foregroundColor, size: 18),
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
    required this.showLoading,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isPrimary;
  final bool isLoading;
  final bool showLoading;
  final Future<void> Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final isDisabled = onTap == null || (isLoading && !showLoading);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppSizes.borderRadiusMd,
        onTap: isDisabled ? null : () => onTap?.call(),
        child: Opacity(
          opacity: isDisabled ? 0.5 : 1.0,
          child: Ink(
            width: double.infinity,
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
                if (showLoading)
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isPrimary ? AppColors.primary : AppColors.onPrimary,
                      ),
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
      width: double.infinity,
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
        children: [
          Icon(
            icon,
            size: 14,
            color: inverted ? AppColors.onPrimary : AppColors.onSurfaceVariant,
          ),
          const SizedBox(width: AppSizes.space6),
          Expanded(
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
