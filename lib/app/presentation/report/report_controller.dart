import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:done_drop/features/auth/presentation/controllers/auth_controller.dart';
import 'package:done_drop/firebase/repositories/report_repository.dart';
import 'package:done_drop/core/services/analytics_service.dart';

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
    'Inappropriate content',
    'Harassment or bullying',
    'Spam or misleading',
    'Privacy concern',
    'Something else',
  ];

  void selectReason(String reason) {
    selectedReason.value = reason;
  }

  Future<void> submitReport({required String reportedUserId, String? momentId}) async {
    final reason = selectedReason.value;
    if (reason == null) {
      Get.snackbar('Please select a reason', '',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900);
      return;
    }

    isSubmitting.value = true;

    try {
      await _reportRepo.submitReport(
        reporterId: _userId ?? 'unknown',
        reporterEmail: _userEmail ?? 'unknown',
        reportedUserId: reportedUserId,
        reason: reason,
        additionalDetails: additionalDetails.text.trim().isEmpty
            ? null
            : additionalDetails.text.trim(),
        momentId: momentId,
      );
      AnalyticsService.instance.reportSubmitted();
      hasSubmitted.value = true;
    } catch (e) {
      Get.snackbar('Failed to submit report', 'Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900);
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
