import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:done_drop/features/auth/presentation/controllers/auth_controller.dart';
import 'package:done_drop/features/auth/repositories/user_profile_repository.dart';
import 'package:done_drop/core/models/user_profile.dart';
import 'package:done_drop/core/errors/result.dart';

class QrController extends GetxController {
  final Rx<UserProfile?> profile = Rx<UserProfile?>(null);
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final uid = Get.find<AuthController>().firebaseUser?.uid;
    if (uid == null) {
      isLoading.value = false;
      return;
    }
    final repo = Get.find<UserProfileRepository>();
    final result = await repo.getUserProfile(uid);
    result.fold(
      onSuccess: (p) => profile.value = p,
      onFailure: (_) {},
    );
    isLoading.value = false;
  }

  String get myCode => profile.value?.userCode ?? '';

  String get qrData => 'donedrop://add?code=${myCode.toUpperCase()}';

  Future<void> copyCode() async {
    await Clipboard.setData(ClipboardData(text: myCode.toUpperCase()));
    Get.snackbar('Copied!', myCode.toUpperCase(), snackPosition: SnackPosition.BOTTOM);
  }

  Future<void> shareCode() async {
    await Get.snackbar(
      'Share Code',
      'My DoneDrop code: ${myCode.toUpperCase()}',
      snackPosition: SnackPosition.BOTTOM,
      mainButton: TextButton(
        onPressed: () => Get.back(),
        child: const Text('OK', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
