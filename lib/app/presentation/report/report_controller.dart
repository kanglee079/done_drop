import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:done_drop/features/auth/presentation/controllers/auth_controller.dart';
import 'package:done_drop/firebase/repositories/report_repository.dart';
import 'package:done_drop/core/services/analytics_service.dart';
import 'package:done_drop/core/theme/theme.dart';
import 'package:done_drop/l10n/l10n.dart';

/// Controller for the report screen.
class ReportController extends GetxController {
  ReportController();

  AuthController get _authController => Get.find<AuthController>();
  ReportRepository get _reportRepo => Get.find<ReportRepository>();

  String? get _userId => _authController.firebaseUser?.uid;
  String? get _userEmail => _authController.firebaseUser?.email;

  final selectedReason = RxnString();
  final additionalDetails = TextEditingController();
  final isSubmitting = false.obs;
  final hasSubmitted = false.obs;

  final List<String> reasons = [
    'inappropriate',
    'harassment',
    'spam',
    'privacy',
    'other',
  ];

  String reasonLabel(String reason) {
    switch (reason) {
      case 'inappropriate':
        return currentL10n.reportReasonInappropriate;
      case 'harassment':
        return currentL10n.reportReasonHarassment;
      case 'spam':
        return currentL10n.reportReasonSpam;
      case 'privacy':
        return currentL10n.reportReasonPrivacy;
      case 'other':
        return currentL10n.reportReasonOther;
      default:
        return currentL10n.reportReasonOther;
    }
  }

  String _reasonPayload(String reason) {
    switch (reason) {
      case 'inappropriate':
        return 'Inappropriate content';
      case 'harassment':
        return 'Harassment or bullying';
      case 'spam':
        return 'Spam or misleading';
      case 'privacy':
        return 'Privacy concern';
      case 'other':
        return 'Something else';
      default:
        return 'Something else';
    }
  }

  void selectReason(String reason) {
    selectedReason.value = reason;
  }

  Future<void> submitReport({required String reportedUserId, String? momentId}) async {
    final reason = selectedReason.value;
    if (reason == null) {
      Get.snackbar(
        currentL10n.reportReasonRequiredTitle,
        '',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorContainer,
        colorText: AppColors.onErrorContainer,
      );
      return;
    }

    isSubmitting.value = true;

    try {
      await _reportRepo.submitReport(
        reporterId: _userId ?? 'unknown',
        reporterEmail: _userEmail ?? 'unknown',
        reportedUserId: reportedUserId,
        reason: _reasonPayload(reason),
        additionalDetails: additionalDetails.text.trim().isEmpty
            ? null
            : additionalDetails.text.trim(),
        momentId: momentId,
      );
      AnalyticsService.instance.reportSubmitted();
      hasSubmitted.value = true;
    } catch (e) {
      Get.snackbar(
        currentL10n.reportSubmitFailedTitle,
        currentL10n.reportSubmitFailedMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorContainer,
        colorText: AppColors.onErrorContainer,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    additionalDetails.dispose();
    super.onClose();
  }
}
