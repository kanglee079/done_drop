import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:done_drop/app/presentation/capture/moment_controller.dart';
import 'package:done_drop/app/routes/app_routes.dart';
import 'package:done_drop/core/services/storage_service.dart';

class CaptureRecoveryService {
  CaptureRecoveryService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  static const String _pendingCaptureSessionKey = 'pending_capture_session';

  final ImagePicker _picker;
  bool _hasAttemptedRestore = false;

  Future<void> stageCaptureSession({
    String? activityId,
    String? activityInstanceId,
    String? completionLogId,
  }) async {
    final payload = <String, String>{
      if (activityId != null && activityId.isNotEmpty) 'activityId': activityId,
      if (activityInstanceId != null && activityInstanceId.isNotEmpty)
        'activityInstanceId': activityInstanceId,
      if (completionLogId != null && completionLogId.isNotEmpty)
        'completionLogId': completionLogId,
    };

    await StorageService.instance.setString(
      _pendingCaptureSessionKey,
      jsonEncode(payload),
    );
  }

  Future<void> clearPendingCaptureSession() async {
    await StorageService.instance.remove(_pendingCaptureSessionKey);
  }

  Future<bool> restorePendingCaptureIfNeeded() async {
    if (_hasAttemptedRestore) return false;
    _hasAttemptedRestore = true;

    final stagedSession = _readPendingCaptureSession();
    final response = await _picker.retrieveLostData();
    if (response.isEmpty) {
      if (stagedSession != null) {
        await clearPendingCaptureSession();
      }
      return false;
    }

    if (response.exception != null) {
      debugPrint(
        '[CaptureRecoveryService] Lost-data recovery failed: '
        '${response.exception}',
      );
      await clearPendingCaptureSession();
      return false;
    }

    final file = response.file;
    if (file == null || file.path.isEmpty) {
      await clearPendingCaptureSession();
      return false;
    }

    if (stagedSession == null) {
      debugPrint(
        '[CaptureRecoveryService] Discarding recovered media with no '
        'staged capture session.',
      );
      return false;
    }

    if (!Get.isRegistered<MomentController>()) {
      Get.put<MomentController>(MomentController());
    }

    final controller = Get.find<MomentController>();
    controller.startCaptureSession(stagedSession);
    controller.attachImage(file.path);
    await clearPendingCaptureSession();

    Get.offAllNamed(
      AppRoutes.preview,
      arguments: {'imagePath': file.path},
    );
    return true;
  }

  Map<String, dynamic>? _readPendingCaptureSession() {
    final raw = StorageService.instance.getString(_pendingCaptureSessionKey);
    if (raw == null || raw.isEmpty) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;

      return <String, dynamic>{
        if (decoded['activityId'] is String) 'activityId': decoded['activityId'],
        if (decoded['activityInstanceId'] is String)
          'activityInstanceId': decoded['activityInstanceId'],
        if (decoded['completionLogId'] is String)
          'completionLogId': decoded['completionLogId'],
      };
    } catch (error) {
      debugPrint(
        '[CaptureRecoveryService] Failed to decode staged capture session: '
        '$error',
      );
      return null;
    }
  }
}
