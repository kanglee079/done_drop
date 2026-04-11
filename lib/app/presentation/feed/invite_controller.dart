import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:done_drop/firebase/repositories/circle_repository.dart';
import 'package:done_drop/core/services/analytics_service.dart';
import 'package:done_drop/core/errors/result.dart';

/// Controller for the invite screen.
class InviteController extends GetxController {
  InviteController();

  CircleRepository get _circleRepo => Get.find<CircleRepository>();

  final circleId = ''.obs;
  final RxString inviteCode = ''.obs;
  final RxBool isLoading = true.obs;
  final RxBool isCreating = false.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null && args['circleId'] != null) {
      circleId.value = args['circleId'] as String;
      _loadInviteCode();
    } else {
      isLoading.value = false;
    }
  }

  Future<void> _loadInviteCode() async {
    isLoading.value = true;
    final invite = await _circleRepo.getInviteForCircle(circleId.value);
    if (invite != null) {
      inviteCode.value = invite.inviteCode;
    } else {
      // Generate a new invite
      final result = await _circleRepo.createInvite(circleId.value);
      result.fold(
        onSuccess: (invite) => inviteCode.value = invite.inviteCode,
        onFailure: (_) {},
      );
    }
    isLoading.value = false;
  }

  String get shareLink => 'https://donedrop.app/join/$circleId/${inviteCode.value}';

  Future<void> copyLink() async {
    await Clipboard.setData(ClipboardData(text: shareLink));
    Get.snackbar(
      'Copied!',
      'Invite link copied to clipboard.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> shareLinkNative() async {
    AnalyticsService.instance.inviteSent();
    // Use system share sheet via share_plus if available, else copy
    try {
      await Clipboard.setData(ClipboardData(text: shareLink));
    } catch (_) {}
    Get.snackbar(
      'Share link ready',
      'Invite link has been copied. Paste it in your message app.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }
}
