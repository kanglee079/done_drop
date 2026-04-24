import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:done_drop/core/constants/app_constants.dart';
import 'package:done_drop/core/models/moment.dart';
import 'package:done_drop/firebase/repositories/moment_repository.dart';

class BuddyWallController extends GetxController {
  BuddyWallController(this._momentRepo);

  final MomentRepository? _momentRepo;

  final moments = <Moment>[].obs;
  final isLoading = true.obs;
  final selectedCategory = ''.obs;
  StreamSubscription<List<Moment>>? _momentsSubscription;

  String get ownerId =>
      (Get.arguments as Map<String, dynamic>?)?['ownerId'] as String? ?? '';
  String get ownerName =>
      (Get.arguments as Map<String, dynamic>?)?['ownerName'] as String? ?? '';
  String? get ownerAvatarUrl =>
      (Get.arguments as Map<String, dynamic>?)?['ownerAvatarUrl'] as String?;

  static List<String> get categories => ['', ...AppConstants.momentCategories];

  List<Moment> get filteredMoments {
    if (selectedCategory.value.isEmpty) {
      return moments;
    }
    return moments
        .where((moment) => moment.category == selectedCategory.value)
        .toList(growable: false);
  }

  @override
  void onInit() {
    super.onInit();
    _watchMoments();
  }

  void setFilter(String category) {
    selectedCategory.value = category;
  }

  void _watchMoments() {
    if (ownerId.isEmpty) {
      isLoading.value = false;
      return;
    }

    final repo = _momentRepo;
    if (repo == null) {
      isLoading.value = false;
      return;
    }

    _momentsSubscription?.cancel();
    _momentsSubscription = repo
        .watchOwnerArchiveMoments(ownerId)
        .listen(
          (items) {
            moments.assignAll(items);
            isLoading.value = false;
          },
          onError: (error) {
            debugPrint('[BuddyWallController] $error');
            isLoading.value = false;
          },
        );
  }

  @override
  void onClose() {
    _momentsSubscription?.cancel();
    super.onClose();
  }
}
