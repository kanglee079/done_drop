import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:done_drop/firebase/repositories/circle_repository.dart';
import 'package:done_drop/firebase/repositories/moment_repository.dart';
import 'package:done_drop/features/auth/repositories/user_profile_repository.dart';
import 'package:done_drop/core/models/circle.dart';
import 'package:done_drop/core/models/moment.dart';
import 'package:done_drop/core/models/user_profile.dart';
import 'package:done_drop/core/theme/theme.dart';
import 'package:done_drop/core/services/analytics_service.dart';
import 'package:done_drop/core/errors/result.dart';

/// Controller for the circle detail screen.
class CircleDetailController extends GetxController {
  CircleDetailController();

  CircleRepository get _circleRepo => Get.find<CircleRepository>();
  MomentRepository get _momentRepo => Get.find<MomentRepository>();
  UserProfileRepository get _userProfileRepo => Get.find<UserProfileRepository>();

  final circleId = ''.obs;
  final Rx<Circle?> circle = Rx<Circle?>(null);
  final RxList<Moment> moments = <Moment>[].obs;
  final RxList<UserProfile> members = <UserProfile>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null && args['circleId'] != null) {
      circleId.value = args['circleId'] as String;
      _watchCircle();
      _watchMoments();
    } else {
      isLoading.value = false;
    }
  }

  void _watchCircle() {
    _circleRepo.watchCircle(circleId.value).listen((c) {
      circle.value = c;
      if (c != null) {
        isLoading.value = false;
        _loadMemberProfiles(c.memberIds);
      }
    });
  }

  void _watchMoments() {
    _momentRepo.watchCircleMoments(circleId.value).listen((m) {
      moments.value = m;
    });
  }

  Future<void> _loadMemberProfiles(List<String> userIds) async {
    if (userIds.isEmpty) {
      members.value = [];
      return;
    }
    final profiles = <UserProfile>[];
    for (final uid in userIds) {
      final result = await _userProfileRepo.getUserProfile(uid);
      result.fold(
        onSuccess: (p) => profiles.add(p),
        onFailure: (_) {},
      );
    }
    members.value = profiles;
  }

  Future<void> leaveCircle() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Leave Circle'),
        content: const Text('Are you sure you want to leave this circle?'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text('Leave', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final result = await _circleRepo.leaveCircle(circleId.value);
    result.fold(
      onSuccess: (_) {
        AnalyticsService.instance.circleLeft(circleId.value);
        Get.back();
      },
      onFailure: (failure) {
        Get.snackbar('Error', failure.toString(),
            snackPosition: SnackPosition.BOTTOM);
      },
    );
  }
}
