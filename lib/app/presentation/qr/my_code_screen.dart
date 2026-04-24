import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:done_drop/app/core/widgets/widgets.dart';
import 'package:done_drop/app/presentation/qr/qr_controller.dart';
import 'package:done_drop/app/routes/app_routes.dart';
import 'package:done_drop/core/theme/theme.dart';
import 'package:done_drop/l10n/l10n.dart';

class MyCodeScreen extends GetView<QrController> {
  const MyCodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Get.back(),
        ),
        title: Text(
          l10n.myCodeTitle,
          style: AppTypography.titleMedium(color: AppColors.onSurface),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        final code = controller.myCode;
        final qrData = controller.qrData;

        return DDResponsiveScrollBody(
          maxWidth: 560,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.space20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _HeaderCard(controller: controller, l10n: l10n),
                const SizedBox(height: AppSizes.space20),
                _QrCard(
                  code: code,
                  qrData: qrData,
                  formatId: controller.formatId,
                  yourUserIdLabel: controller.yourUserIdLabel,
                  hasCode: controller.hasCode,
                  onReload: controller.reloadCode,
                ),
                const SizedBox(height: AppSizes.space20),
                _ActionButtons(controller: controller, l10n: l10n),
                const SizedBox(height: AppSizes.space12),
                _ScanPromptButton(),
                const SizedBox(height: AppSizes.space24),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.controller, required this.l10n});

  final QrController controller;
  final dynamic l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.space20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryFixed,
            AppColors.surfaceContainerLowest,
          ],
        ),
        borderRadius: AppSizes.borderRadiusXl,
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.myCodeTitle.toUpperCase(),
                  style: AppTypography.labelSmall(
                    color: AppColors.primary.withValues(alpha: 0.72),
                  ).copyWith(letterSpacing: 1.2),
                ),
                const SizedBox(height: AppSizes.space8),
                Text(
                  l10n.myCodeSubtitle,
                  style: AppTypography.bodyMedium(
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.space16),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.qr_code_2_rounded,
              color: AppColors.primary,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }
}

class _QrCard extends StatelessWidget {
  const _QrCard({
    required this.code,
    required this.qrData,
    required this.formatId,
    required this.yourUserIdLabel,
    required this.hasCode,
    required this.onReload,
  });

  final String code;
  final String qrData;
  final String Function(String) formatId;
  final String yourUserIdLabel;
  final bool hasCode;
  final VoidCallback onReload;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.space20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppSizes.borderRadiusXl,
        boxShadow: AppColors.cardShadow,
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: AnimatedSwitcher(
        duration: AppMotion.fast,
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: hasCode
            ? _QrReadyState(
                code: code,
                qrData: qrData,
                formatId: formatId,
                yourUserIdLabel: yourUserIdLabel,
              )
            : _QrMissingState(onRetry: onReload),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.controller, required this.l10n});

  final QrController controller;
  final dynamic l10n;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stackActions = constraints.maxWidth < 420;
        final copyButton = DDSecondaryButton(
          label: 'Copy',
          icon: Icons.copy_rounded,
          isEnabled: controller.hasCode,
          isExpanded: true,
          onPressed: controller.copyCode,
        );
        final shareButton = DDPrimaryButton(
          label: l10n.shareCodeAction,
          icon: Icons.share_rounded,
          isLoading: controller.isSharing.value,
          isExpanded: true,
          onPressed: controller.hasCode
              ? () => controller.shareCode(context)
              : null,
        );

        if (stackActions) {
          return Column(
            children: [
              copyButton,
              const SizedBox(height: AppSizes.space12),
              shareButton,
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: copyButton),
            const SizedBox(width: AppSizes.space12),
            Expanded(child: shareButton),
          ],
        );
      },
    );
  }
}

class _ScanPromptButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DDSecondaryButton(
      label: context.l10n.scanAction,
      icon: Icons.qr_code_scanner_rounded,
      onPressed: () => Get.toNamed(AppRoutes.scanCode),
    );
  }
}

class _QrReadyState extends StatelessWidget {
  const _QrReadyState({
    required this.code,
    required this.qrData,
    required this.formatId,
    required this.yourUserIdLabel,
  });

  final String code;
  final String qrData;
  final String Function(String) formatId;
  final String yourUserIdLabel;

  @override
  Widget build(BuildContext context) {
    final isShortCode = code.length <= 12;

    return Column(
      key: const ValueKey('qr-ready'),
      children: [
        Container(
          padding: const EdgeInsets.all(AppSizes.space20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppSizes.borderRadiusLg,
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: QrImageView(
            data: qrData,
            version: QrVersions.auto,
            size: 220,
            backgroundColor: Colors.white,
            errorCorrectionLevel: QrErrorCorrectLevel.M,
            eyeStyle: const QrEyeStyle(
              eyeShape: QrEyeShape.square,
              color: AppColors.primary,
            ),
            dataModuleStyle: const QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.square,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: AppSizes.space16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.space20,
            vertical: AppSizes.space16,
          ),
          decoration: BoxDecoration(
            color: AppColors.primaryFixed,
            borderRadius: AppSizes.borderRadiusLg,
          ),
          child: Column(
            children: [
              Text(
                yourUserIdLabel,
                style: AppTypography.labelSmall(
                  color: AppColors.primary.withValues(alpha: 0.72),
                ).copyWith(letterSpacing: 1),
              ),
              const SizedBox(height: AppSizes.space6),
              if (isShortCode)
                Text(
                  code,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 4,
                    color: AppColors.primary,
                  ),
                )
              else
                Text(
                  formatId(code),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: AppColors.primary,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QrMissingState extends StatelessWidget {
  const _QrMissingState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('qr-missing'),
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: AppColors.primaryFixed,
            borderRadius: BorderRadius.circular(28),
          ),
          child: const Icon(
            Icons.qr_code_2_rounded,
            color: AppColors.primary,
            size: 40,
          ),
        ),
        const SizedBox(height: AppSizes.space16),
        Text(
          context.l10n.myCodeSubtitle,
          textAlign: TextAlign.center,
          style: AppTypography.bodyMedium(color: AppColors.onSurfaceVariant),
        ),
        const SizedBox(height: AppSizes.space16),
        DDSecondaryButton(
          label: context.l10n.retryAction,
          icon: Icons.refresh_rounded,
          isExpanded: false,
          onPressed: onRetry,
        ),
      ],
    );
  }
}
