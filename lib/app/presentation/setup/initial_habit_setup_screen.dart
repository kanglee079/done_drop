import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/theme.dart';
import '../../../l10n/l10n.dart';
import '../../core/widgets/widgets.dart';
import 'initial_habit_setup_controller.dart';

class InitialHabitSetupScreen extends GetView<InitialHabitSetupController> {
  const InitialHabitSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spec = DDResponsiveSpec.of(context);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: DDResponsiveScrollBody(
          maxWidth: 640,
          padding: spec.pagePadding(
            top: spec.isShort ? AppSizes.space24 : AppSizes.space32,
            bottom: AppSizes.space24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.setupTitle,
                style: TextStyle(
                  fontFamily: AppTypography.serifFamily,
                  fontSize: spec.isCompact ? 34 : 38,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: AppSizes.space8),
              Text(
                l10n.setupSubtitle,
                style: AppTypography.bodyMedium(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSizes.space24),
              ...List.generate(
                3,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSizes.space16),
                  child: _HabitDraftCard(index: index),
                ),
              ),
              Obx(() {
                final message = controller.errorMessage.value;
                if (message == null) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSizes.space16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSizes.space16),
                    decoration: BoxDecoration(
                      color: AppColors.errorContainer,
                      borderRadius: AppSizes.borderRadiusMd,
                    ),
                    child: Text(
                      message,
                      style: AppTypography.bodySmall(
                        color: AppColors.onErrorContainer,
                      ),
                    ),
                  ),
                );
              }),
              Obx(
                () => DDPrimaryButton(
                  label: l10n.setupPrimaryAction,
                  onPressed: controller.isSaving.value
                      ? null
                      : controller.completeSetup,
                  isLoading: controller.isSaving.value,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HabitDraftCard extends StatelessWidget {
  const _HabitDraftCard({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<InitialHabitSetupController>();
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(AppSizes.space20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppSizes.borderRadiusLg,
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.setupHabitTitle(index + 1),
            style: AppTypography.titleMedium(color: AppColors.onSurface),
          ),
          const SizedBox(height: AppSizes.space16),
          DDTextField(
            controller: controller.titleControllers[index],
            label: l10n.setupHabitPrompt,
            hint: l10n.habitNameHint,
            prefixIcon: Icons.check_circle_outline_rounded,
            textInputAction: index == 2
                ? TextInputAction.done
                : TextInputAction.next,
          ),
          const SizedBox(height: AppSizes.space16),
          Text(
            l10n.setupHabitTimePrompt,
            style: AppTypography.labelMedium(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: AppSizes.space10),
          Obx(() {
            final time = controller.reminderTimes[index];
            return OutlinedButton.icon(
              onPressed: () => controller.pickReminderTime(context, index),
              icon: const Icon(Icons.schedule_rounded),
              label: Text(
                MaterialLocalizations.of(
                  context,
                ).formatTimeOfDay(time, alwaysUse24HourFormat: false),
              ),
            );
          }),
        ],
      ),
    );
  }
}
