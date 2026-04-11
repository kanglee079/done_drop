import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:done_drop/features/auth/presentation/controllers/auth_controller.dart';
import 'package:done_drop/firebase/repositories/moment_repository.dart';
import 'package:done_drop/core/models/moment.dart';
import 'package:done_drop/core/services/upload_service.dart';
import 'package:done_drop/core/services/analytics_service.dart';
import 'package:done_drop/app/routes/app_routes.dart';

class MomentController extends GetxController {
  MomentController();

  MomentRepository get _momentRepo => Get.find<MomentRepository>();
  AuthController get _authController => Get.find<AuthController>();
  UploadService get _uploadService => UploadService.instance;

  // Post form state
  final captionController = TextEditingController();
  final Rx<String> visibility = 'personal_only'.obs;
  final Rx<String?> selectedCircleId = Rx<String?>(null);
  final Rx<String> selectedCategory = ''.obs;

  // Post state
  final isPosting = false.obs;
  final RxnString errorMessage = RxnString();

  String? _imagePath;

  void setImagePath(String path) {
    _imagePath = path;
  }

  String? get _userId => _authController.firebaseUser?.uid;

  Future<void> postMoment() async {
    if (_imagePath == null) {
      errorMessage.value = 'No image selected';
      return;
    }

    final caption = captionController.text.trim();
    if (caption.isEmpty) {
      errorMessage.value = 'Please add a caption';
      return;
    }

    final uid = _userId;
    if (uid == null) {
      errorMessage.value = 'You must be signed in';
      return;
    }

    isPosting.value = true;
    errorMessage.value = null;

    try {
      final momentId = 'moment_${DateTime.now().millisecondsSinceEpoch}';
      final now = DateTime.now();

      // Upload image to Firebase Storage
      final imageUrl = await _uploadService.uploadMomentImage(
        userId: uid,
        momentId: momentId,
        localFilePath: _imagePath!,
      );

      // Create moment document in Firestore
      final moment = Moment(
        id: momentId,
        ownerId: uid,
        visibility: visibility.value,
        imageUrl: imageUrl,
        caption: caption,
        category: selectedCategory.value.isEmpty ? null : selectedCategory.value,
        circleId: visibility.value == 'circle' ? selectedCircleId.value : null,
        completedAt: now,
        createdAt: now,
        updatedAt: now,
        reactionCounts: const {},
        isDeleted: false,
        moderationStatus: 'approved',
      );

      await _momentRepo.createMoment(moment);

      // Track analytics
      AnalyticsService.instance.momentPosted(
        visibility: visibility.value,
        circleId: selectedCircleId.value,
        category: selectedCategory.value.isEmpty ? null : selectedCategory.value,
      );

      isPosting.value = false;
      Get.offNamed(AppRoutes.success);
    } catch (e) {
      isPosting.value = false;
      errorMessage.value = 'Failed to post moment: ${e.toString()}';
    }
  }

  void setVisibility(String v) {
    visibility.value = v;
    if (v == 'personal_only') {
      selectedCircleId.value = null;
    }
  }

  void setCircle(String? circleId) {
    selectedCircleId.value = circleId;
    if (circleId != null) {
      visibility.value = 'circle';
    }
  }

  void setCategory(String? cat) {
    selectedCategory.value = cat ?? '';
  }

  @override
  void onClose() {
    captionController.dispose();
    super.onClose();
  }
}
