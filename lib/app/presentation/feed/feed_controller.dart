import 'package:get/get.dart';
import 'package:done_drop/firebase/repositories/circle_repository.dart';
import 'package:done_drop/firebase/repositories/moment_repository.dart';
import 'package:done_drop/features/auth/presentation/controllers/auth_controller.dart';
import 'package:done_drop/core/models/circle.dart';
import 'package:done_drop/core/models/moment.dart';
import 'package:done_drop/app/presentation/feed/reaction_controller.dart';

/// Controller for the feed screen.
/// Aggregates circle moments from all circles the user belongs to.
class FeedController extends GetxController {
  FeedController();

  CircleRepository get _circleRepo => Get.find<CircleRepository>();
  MomentRepository get _momentRepo => Get.find<MomentRepository>();
  AuthController get _authController => Get.find<AuthController>();

  String? get _userId => _authController.firebaseUser?.uid;

  final isLoading = true.obs;
  final RxList<Circle> circles = <Circle>[].obs;
  final RxList<Moment> moments = <Moment>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadFeed();
  }

  void _loadFeed() {
    final uid = _userId;
    if (uid == null) {
      isLoading.value = false;
      return;
    }

    // Get user's circles
    _circleRepo.watchUserCircles(uid).listen((circleList) async {
      circles.value = circleList;
      isLoading.value = false;

      // Load moments from all circles
      final allMoments = <Moment>[];
      for (final circle in circleList) {
        final circleMoments = await _momentRepo.getCircleMomentsSync(circle.id);
        allMoments.addAll(circleMoments);
      }
      // Sort by createdAt descending
      allMoments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      moments.value = allMoments;
    });
  }

  ReactionController get reactionCtrl => Get.find<ReactionController>();
}
