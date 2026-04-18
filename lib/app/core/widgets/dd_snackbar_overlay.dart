import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:done_drop/core/theme/theme.dart';
import 'package:done_drop/l10n/l10n.dart';

/// A global snackbar overlay wrapper for GetX navigation.
/// Wraps any page widget so errors / info messages can be shown globally.
/// Usage: return GetMaterialApp(home: SnackbarOverlay(child: MyApp()));
class SnackbarOverlay extends StatelessWidget {
  const SnackbarOverlay({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

/// Show a friendly error snackbar (non-blocking).
void showAppError(String message) {
  if (!Get.isSnackbarOpen) {
    Get.rawSnackbar(
      titleText: Text(
        currentL10n.errorTitle,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
      messageText: Text(
        message,
        style: const TextStyle(color: Colors.white, fontSize: 13),
      ),
      backgroundColor: AppColors.error,
      duration: const Duration(seconds: 4),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }
}

/// Show an info snackbar.
void showAppInfo(String message, {String? title}) {
  if (!Get.isSnackbarOpen) {
    Get.rawSnackbar(
      titleText: title != null
          ? Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            )
          : const SizedBox.shrink(),
      messageText: Text(
        message,
        style: const TextStyle(color: Colors.white, fontSize: 13),
      ),
      backgroundColor: AppColors.primary,
      duration: const Duration(seconds: 3),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }
}

/// Show a success snackbar.
void showAppSuccess(String message, {String? title}) {
  if (!Get.isSnackbarOpen) {
    Get.rawSnackbar(
      titleText: Text(
        title ?? currentL10n.successTitle,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
      messageText: Text(
        message,
        style: const TextStyle(color: Colors.white, fontSize: 13),
      ),
      backgroundColor: const Color(0xFF2E7D32),
      duration: const Duration(seconds: 3),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }
}

/// A DD-branded loading overlay dialog.
void showLoadingDialog({String? message}) {
  Get.dialog(
    PopScope(
      canPop: false,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: AppSizes.borderRadiusLg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 32, height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: AppColors.primary,
                ),
              ),
              if (message != null) ...[
                const SizedBox(height: 16),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    ),
    barrierDismissible: false,
  );
}
