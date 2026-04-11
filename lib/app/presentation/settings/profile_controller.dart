import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:done_drop/features/auth/presentation/controllers/auth_controller.dart';
import 'package:done_drop/features/auth/repositories/user_profile_repository.dart';
import 'package:done_drop/core/models/user_profile.dart';
import 'package:done_drop/core/theme/theme.dart';
import 'package:done_drop/core/services/upload_service.dart';
import 'package:done_drop/core/services/analytics_service.dart';
import 'package:done_drop/core/errors/result.dart';

/// Controller for the profile screen.
class ProfileController extends GetxController {
  ProfileController();

  AuthController get _authController => Get.find<AuthController>();
  UserProfileRepository get _userProfileRepo => Get.find<UserProfileRepository>();
  UploadService get _uploadService => UploadService.instance;

  String? get _userId => _authController.firebaseUser?.uid;

  // Form fields
  final nameController = TextEditingController();
  final bioController = TextEditingController();

  // Reactive state
  final Rx<UserProfile?> profile = Rx<UserProfile?>(null);
  final isLoading = false.obs;
  final isSaving = false.obs;
  final RxnString errorMessage = RxnString();
  final RxnString successMessage = RxnString();
  final RxBool isUploadingAvatar = false.obs;

  @override
  void onInit() {
    super.onInit();
    _watchProfile();
  }

  void _watchProfile() {
    final uid = _userId;
    if (uid == null) return;
    _userProfileRepo.watchUserProfile(uid).listen((p) {
      profile.value = p;
      // Pre-fill form when profile loads
      if (p != null) {
        nameController.text = p.displayName;
        bioController.text = p.bio ?? '';
      }
    });
  }

  String? get _currentUserId => _authController.firebaseUser?.uid;

  Future<void> pickAndUploadAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 400,
      maxHeight: 400,
      imageQuality: 80,
    );
    if (picked == null) return;

    final uid = _currentUserId;
    if (uid == null) return;

    isUploadingAvatar.value = true;
    errorMessage.value = null;

    try {
      final url = await _uploadService.uploadAvatar(userId: uid, localFilePath: picked.path);
      final current = profile.value;
      if (current != null) {
        final updated = current.copyWith(avatarUrl: url);
        await _userProfileRepo.updateUserProfile(updated);
      }
    } catch (e) {
      errorMessage.value = 'Failed to upload avatar';
    } finally {
      isUploadingAvatar.value = false;
    }
  }

  Future<void> saveProfile() async {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      errorMessage.value = 'Name cannot be empty';
      return;
    }

    final current = profile.value;
    if (current == null) return;

    isSaving.value = true;
    errorMessage.value = null;

    final updated = current.copyWith(
      displayName: name,
      bio: bioController.text.trim().isEmpty ? null : bioController.text.trim(),
    );

    final result = await _userProfileRepo.updateUserProfile(updated);

    isSaving.value = false;

    result.fold(
      onSuccess: (_) {
        successMessage.value = 'Profile saved';
        AnalyticsService.instance.settingChanged('profile_updated', name);
        Future.delayed(const Duration(seconds: 2), () {
          successMessage.value = null;
        });
      },
      onFailure: (failure) {
        errorMessage.value = failure.toString();
      },
    );
  }

  Future<void> deleteAccount() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'This will permanently delete your account and all your data. This action cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    isLoading.value = true;
    await _authController.signOut();
    isLoading.value = false;
  }

  @override
  void onClose() {
    nameController.dispose();
    bioController.dispose();
    super.onClose();
  }
}
