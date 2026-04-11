import 'package:get/get.dart';
import 'package:done_drop/features/auth/presentation/controllers/auth_controller.dart';
import 'package:done_drop/firebase/repositories/moment_repository.dart';
import 'package:done_drop/core/models/moment.dart';

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

  static const categories = [
    'All Moments',
    'Daily Wins',
    'Travel',
    'Reflections',
    'Health & Fitness',
    'Creative',
    'Learning',
    'Relationships',
    'Nature',
    'Food',
    'Work',
    'Monthly Highlights',
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

  void deleteMoment(String momentId) {
    _momentRepo.deleteMoment(momentId);
  }
}
