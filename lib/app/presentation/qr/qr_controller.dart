import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import 'package:done_drop/core/errors/result.dart';
import 'package:done_drop/features/auth/presentation/controllers/auth_controller.dart';
import 'package:done_drop/features/auth/repositories/user_profile_repository.dart';
import 'package:done_drop/core/models/user_profile.dart';
import 'package:done_drop/l10n/l10n.dart';

class QrController extends GetxController {
  final Rx<UserProfile?> profile = Rx<UserProfile?>(null);
  final RxBool isLoading = true.obs;
  final RxBool isSharing = false.obs;

  String? get _currentUid => Get.find<AuthController>().firebaseUser?.uid;

  String get _displayName {
    final profileName = profile.value?.displayName.trim() ?? '';
    if (profileName.isNotEmpty) return profileName;

    final authName =
        Get.find<AuthController>().firebaseUser?.displayName?.trim() ?? '';
    if (authName.isNotEmpty) return authName;

    return currentL10n.memberFallbackName;
  }

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
    await result.fold(
      onSuccess: (p) async {
        final ensuredResult = await repo.ensureUserCode(p);
        profile.value = ensuredResult.dataOrNull ?? p;
      },
      onFailure: (_) async {},
    );
    isLoading.value = false;
  }

  String get myCode {
    final code = profile.value?.userCode?.trim().toUpperCase() ?? '';
    if (code.isNotEmpty) return code;
    return _currentUid?.trim() ?? '';
  }

  bool get hasCode => myCode.trim().isNotEmpty;

  /// Formats a long UID into a readable short form: first 4 + space + last 4.
  /// Falls back to the full code if it's short enough.
  String formatId(String code) {
    if (code.length <= 12) return code;
    return '${code.substring(0, 4)} ${code.substring(code.length - 4)}';
  }

  /// Display label shown above the ID, e.g. "Your ID".
  String get yourUserIdLabel => currentL10n.yourUserId;

  String get qrData {
    final uid = _currentUid?.trim();
    if (uid == null || uid.isEmpty) return '';

    return Uri(
      scheme: 'donedrop',
      host: 'add',
      queryParameters: {
        'uid': uid,
        'name': _displayName,
        if ((profile.value?.userCode?.trim().isNotEmpty ?? false))
          'code': profile.value!.userCode!.trim().toUpperCase(),
      },
    ).toString();
  }

  Future<void> copyCode() async {
    if (!hasCode) return;
    await Clipboard.setData(ClipboardData(text: myCode));
    Get.snackbar(
      currentL10n.myCodeTitle,
      currentL10n.myCodeCopied,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> shareCode(BuildContext context) async {
    if (!hasCode || isSharing.value) return;

    isSharing.value = true;
    final box = context.findRenderObject() as RenderBox?;
    try {
      await Share.share(
        '${currentL10n.userIdLabel}: $myCode\n$qrData\n\n${currentL10n.myCodeSubtitle}',
        subject: currentL10n.myCodeTitle,
        sharePositionOrigin: box == null
            ? null
            : box.localToGlobal(Offset.zero) & box.size,
      );
    } finally {
      isSharing.value = false;
    }
  }

  Future<void> reloadCode() async {
    if (isLoading.value) return;
    isLoading.value = true;
    profile.value = null;
    await _loadProfile();
  }
}
