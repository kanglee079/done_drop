import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:done_drop/features/auth/presentation/controllers/auth_controller.dart';
import 'package:done_drop/firebase/repositories/moment_repository.dart';
import 'package:done_drop/core/models/moment.dart';
import 'package:done_drop/core/constants/app_constants.dart';

/// Controller for Memory Wall screen — personal moments grid.
class MemoryWallController extends GetxController {
  MemoryWallController(this._momentRepo);
  final MomentRepository _momentRepo;

  String? get _userId => Get.find<AuthController>().firebaseUser?.uid;

  /// Personal moments stream.
  final RxList<Moment> moments = <Moment>[].obs;

  /// Loading state.
  final isLoading = true.obs;

  /// Selected filter category.
  final selectedCategory = ''.obs;

  /// Filtered moments (by category).
  List<Moment> get filteredMoments {
    if (selectedCategory.value.isEmpty) return moments;
    return moments.where((m) => m.category == selectedCategory.value).toList();
  }

  Map<String, List<Moment>> get groupedMomentsByMonth {
    final grouped = <String, List<Moment>>{};
    for (final moment in filteredMoments) {
      final key = DateFormat('MMMM yyyy').format(moment.createdAt);
      grouped.putIfAbsent(key, () => <Moment>[]).add(moment);
    }
    return grouped;
  }

  /// Use AppConstants moment categories — discipline-first, no reflection/journal mindset.
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
    moments.bindStream(_momentRepo.watchPersonalMoments(uid));
    isLoading.value = false;
  }

  void setFilter(String category) {
    selectedCategory.value = category == 'All Moments' ? '' : category;
  }

  void deleteMoment(String momentId) async {
    // Get the moment to find associated media and feed deliveries
    final moment = await _momentRepo.getMoment(momentId);
    if (moment != null) {
      // Delete from Storage first (covers both original + thumbnail)
      await _momentRepo.deleteMomentStorage(moment.ownerId, momentId);
      // Delete feed deliveries for this moment
      await _momentRepo.deleteFeedDeliveriesForMoment(momentId);
    }
    // Soft-delete the moment document
    await _momentRepo.deleteMoment(momentId);
  }
}
