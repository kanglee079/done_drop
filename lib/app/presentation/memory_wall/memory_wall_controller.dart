import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:done_drop/core/constants/app_constants.dart';
import 'package:done_drop/core/models/moment.dart';
import 'package:done_drop/features/auth/presentation/controllers/auth_controller.dart';
import 'package:done_drop/firebase/repositories/moment_repository.dart';

/// Controller for Memory Wall screen — owner archive moments grid.
class MemoryWallController extends GetxController {
  MemoryWallController(this._momentRepo);
  final MomentRepository _momentRepo;

  String? get _userId => Get.find<AuthController>().firebaseUser?.uid;

  final RxList<Moment> moments = <Moment>[].obs;
  final isLoading = true.obs;
  final selectedCategory = ''.obs;

  final List<Moment> _remoteMoments = <Moment>[];
  final RxList<Moment> _optimisticMoments = <Moment>[].obs;

  List<Moment> get filteredMoments {
    final source = moments;
    if (selectedCategory.value.isEmpty) return source;
    return source.where((m) => m.category == selectedCategory.value).toList();
  }

  Map<String, List<Moment>> get groupedMomentsByMonth {
    final grouped = <String, List<Moment>>{};
    for (final moment in filteredMoments) {
      final key = DateFormat('MMMM yyyy').format(moment.createdAt);
      grouped.putIfAbsent(key, () => <Moment>[]).add(moment);
    }
    return grouped;
  }

  static List<String> get categories => [
        'All Moments',
        ...AppConstants.momentCategories,
      ];

  @override
  void onInit() {
    super.onInit();
    _watchMoments();
  }

  void _watchMoments() {
    final uid = _userId;
    if (uid == null) {
      isLoading.value = false;
      return;
    }
    _momentRepo.watchOwnerArchiveMoments(uid).listen((remoteMoments) {
      _remoteMoments
        ..clear()
        ..addAll(remoteMoments);
      _mergeMoments();
      isLoading.value = false;
    });
  }

  void setFilter(String category) {
    selectedCategory.value = category == 'All Moments' ? '' : category;
  }

  void upsertOptimisticMoment(Moment moment) {
    final index = _optimisticMoments.indexWhere((item) => item.id == moment.id);
    if (index == -1) {
      _optimisticMoments.insert(0, moment);
    } else {
      _optimisticMoments[index] = moment;
    }
    _mergeMoments();
  }

  void updateOptimisticMoment(
    String momentId, {
    MomentMedia? media,
    MomentSyncStatus? syncStatus,
    double? uploadProgress,
  }) {
    final index = _optimisticMoments.indexWhere((item) => item.id == momentId);
    if (index == -1) return;
    final current = _optimisticMoments[index];
    _optimisticMoments[index] = current.copyWith(
      media: media,
      syncStatus: syncStatus,
      uploadProgress: uploadProgress,
    );
    _mergeMoments();
  }

  void deleteMoment(String momentId) async {
    final moment = await _momentRepo.getMoment(momentId);
    if (moment != null) {
      await _momentRepo.deleteMomentStorage(moment.ownerId, momentId);
      await _momentRepo.deleteFeedDeliveriesForMoment(momentId);
    }
    await _momentRepo.deleteMoment(momentId);
  }

  void _mergeMoments() {
    final remoteIds = _remoteMoments.map((moment) => moment.id).toSet();
    final optimistic = _optimisticMoments
        .where((moment) => !remoteIds.contains(moment.id))
        .toList(growable: false);

    final merged = <Moment>[...optimistic, ..._remoteMoments]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    moments.value = merged;
  }
}
