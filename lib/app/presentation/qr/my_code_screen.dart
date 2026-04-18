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
        return Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.space24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // QR Code Card
                Container(
                  padding: const EdgeInsets.all(AppSizes.space24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppSizes.borderRadiusXl,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: QrImageView(
                    data: controller.qrData,
                    version: QrVersions.auto,
                    size: 200,
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
                const SizedBox(height: AppSizes.space32),

                // Code display
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.space24,
                    vertical: AppSizes.space16,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryFixed,
                    borderRadius: AppSizes.borderRadiusLg,
                  ),
                  child: Column(
                    children: [
                      Text(
                        l10n.userIdLabel,
                        style: AppTypography.bodySmall(
                          color: AppColors.primary.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: AppSizes.space4),
                      Text(
                        code.isEmpty ? '------' : code,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 8,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.space12),
                Text(
                  l10n.myCodeSubtitle,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSizes.space32),

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _ActionButton(
                      icon: Icons.copy_rounded,
                      label: 'Copy',
                      onTap: controller.copyCode,
                    ),
                    const SizedBox(width: AppSizes.space16),
                    _ActionButton(
                      icon: Icons.share_rounded,
                      label: 'Share',
                      onTap: controller.shareCode,
                      isPrimary: true,
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.space24),

                // Scan action
                TextButton.icon(
                  onPressed: () => Get.toNamed(AppRoutes.scanCode),
                  icon: const Icon(Icons.qr_code_scanner_rounded, size: 20),
                  label: Text(l10n.scanAction),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isPrimary = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    if (isPrimary) {
    return DDPrimaryButton(
      label: label,
      icon: icon,
      onPressed: onTap,
    );
    }
    return DDSecondaryButton(
      label: label,
      icon: icon,
      onPressed: onTap,
    );
  }
}
