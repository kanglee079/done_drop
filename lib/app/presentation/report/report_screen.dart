import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:done_drop/core/theme/theme.dart';
import 'package:done_drop/app/core/widgets/widgets.dart';
import 'package:done_drop/app/presentation/report/report_controller.dart';

/// DoneDrop Report Screen
class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ReportController>(
      init: ReportController(),
      builder: (ctrl) {
        // This screen receives reportedUserId and momentId via Get.arguments
        final args = Get.arguments as Map<String, dynamic>?;
        final reportedUserId = args?['reportedUserId'] as String? ?? '';
        final momentId = args?['momentId'] as String?;

        return Scaffold(
          backgroundColor: AppColors.surface,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close, color: AppColors.primary),
              onPressed: () => Get.back(),
            ),
            title: const Text('Report'),
            centerTitle: true,
          ),
          body: Obx(() {
            if (ctrl.hasSubmitted.value) {
              return DDResponsiveScrollBody(
                maxWidth: 520,
                child: _SuccessState(onDone: () => Get.back()),
              );
            }

            return DDResponsiveScrollBody(
              maxWidth: 560,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Report Content',
                    style: TextStyle(
                      fontFamily: AppTypography.serifFamily,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppSizes.space8),
                  Text(
                    'Help us keep DoneDrop safe. Select a reason for reporting.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSizes.space32),
                  ...ctrl.reasons.map(
                    (reason) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSizes.space8),
                      child: _ReasonTile(
                        label: reason,
                        isSelected: ctrl.selectedReason.value == reason,
                        onTap: () => ctrl.selectReason(reason),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.space16),
                  TextField(
                    controller: ctrl.additionalDetails,
                    maxLines: 3,
                    maxLength: 300,
                    decoration: InputDecoration(
                      hintText: 'Additional details (optional)',
                      hintStyle: TextStyle(
                        color: AppColors.outline.withValues(alpha: 0.5),
                      ),
                      filled: true,
                      fillColor: AppColors.surfaceContainerHighest,
                      border: OutlineInputBorder(
                        borderRadius: AppSizes.borderRadiusMd,
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(AppSizes.space16),
                    ),
                  ),
                  const SizedBox(height: AppSizes.space16),
                  SizedBox(
                    width: double.infinity,
                    child: ctrl.isSubmitting.value
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          )
                        : DDPrimaryButton(
                            label: 'Submit Report',
                            onPressed: () => ctrl.submitReport(
                              reportedUserId: reportedUserId,
                              momentId: momentId,
                            ),
                          ),
                  ),
                  const SizedBox(height: AppSizes.space24),
                ],
              ),
            );
          }),
        );
      },
    );
  }
}

class _ReasonTile extends StatelessWidget {
  const _ReasonTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(AppSizes.space16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryContainer
              : AppColors.surfaceContainerLow,
          borderRadius: AppSizes.borderRadiusMd,
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? AppColors.primary : AppColors.onSurface,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: AppColors.primary, size: 20)
            else
              Icon(Icons.circle_outlined, color: AppColors.outline, size: 20),
          ],
        ),
      ),
    );
  }
}

class _SuccessState extends StatelessWidget {
  const _SuccessState({required this.onDone});
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.space32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.space24),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check, color: AppColors.primary, size: 48),
            ),
            const SizedBox(height: AppSizes.space24),
            Text(
              'Report Submitted',
              style: TextStyle(
                fontFamily: AppTypography.serifFamily,
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: AppSizes.space8),
            Text(
              'Thank you for helping keep DoneDrop safe. We will review your report shortly.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: AppSizes.space32),
            DDPrimaryButton(label: 'Done', onPressed: onDone),
          ],
        ),
      ),
    );
  }
}
