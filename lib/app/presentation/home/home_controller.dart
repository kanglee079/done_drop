import 'package:get/get.dart';
import 'package:done_drop/features/auth/presentation/controllers/auth_controller.dart';
import 'package:done_drop/features/auth/repositories/user_profile_repository.dart';
import 'package:done_drop/firebase/repositories/circle_repository.dart';
import 'package:done_drop/firebase/repositories/moment_repository.dart';
import 'package:done_drop/core/models/user_profile.dart';
import 'package:done_drop/core/models/circle.dart';
import 'package:done_drop/core/models/moment.dart';

class HomeController extends GetxController {
  HomeController(this._circleRepo, this._momentRepo);
  final CircleRepository _circleRepo;
  final MomentRepository _momentRepo;

  /// Bottom navigation index. 0=Today, 1=Feed, 2=FAB, 3=Wall, 4=Settings.
  final navIndex = 0.obs;

  /// User profile stream (for display name, avatar, etc).
  final Rx<UserProfile?> profile = Rx<UserProfile?>(null);

  /// User's circles stream.
  final RxList<Circle> circles = <Circle>[].obs;

  /// Task templates stream.
  final RxList<TaskTemplate> tasks = <TaskTemplate>[].obs;

  /// Whether the user has any circles.
  bool get hasCircles => circles.isNotEmpty;

  /// Current user ID from AuthController.
  String? get _userId => Get.find<AuthController>().firebaseUser?.uid;

  @override
  void onInit() {
    super.onInit();
    _watchProfile();
    _watchCircles();
    _watchTasks();
  }

  void _watchProfile() {
    final uid = _userId;
    if (uid == null) return;
    Get.find<UserProfileRepository>().watchUserProfile(uid).listen((p) {
      profile.value = p;
    });
  }

  void _watchCircles() {
    final uid = _userId;
    if (uid == null) return;
    circles.bindStream(_circleRepo.watchUserCircles(uid));
  }

  void _watchTasks() {
    final uid = _userId;
    if (uid == null) return;
    tasks.bindStream(_momentRepo.watchTaskTemplates(uid));
  }

  Future<void> archiveTask(String taskId) async {
    await _momentRepo.archiveTaskTemplate(taskId);
  }

  void onNavTap(int index) {
    navIndex.value = index;
  }

  Future<void> signOut() async {
    await Get.find<AuthController>().signOut();
  }
}
