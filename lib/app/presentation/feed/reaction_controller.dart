import 'package:get/get.dart';
import 'package:done_drop/firebase/repositories/moment_repository.dart';
import 'package:done_drop/features/auth/presentation/controllers/auth_controller.dart';
import 'package:done_drop/core/models/moment.dart';
import 'package:done_drop/core/services/analytics_service.dart';

/// Controller for managing moment reactions (love / celebrate / inspiring).
class ReactionController extends GetxController {
  ReactionController();

  MomentRepository get _momentRepo => Get.find<MomentRepository>();
  AuthController get _authController => Get.find<AuthController>();

  String? get _userId => _authController.firebaseUser?.uid;

  final reactionTypes = ['love', 'celebrate', 'inspiring'];

  /// Toggle a reaction on a moment: add if none, replace if different, remove if same.
  Future<void> toggleReaction({
    required String momentId,
    required String reactionType,
    String? currentUserReaction,
  }) async {
    final uid = _userId;
    if (uid == null) return;

    if (currentUserReaction == reactionType) {
      // Remove reaction
      await _momentRepo.removeReaction(momentId, uid);
      AnalyticsService.instance.reactionRemoved(momentId);
    } else {
      // Add / replace reaction
      final reaction = Reaction(
        id: 'reaction_${momentId}_$uid',
        momentId: momentId,
        userId: uid,
        reactionType: reactionType,
        createdAt: DateTime.now(),
      );
      await _momentRepo.addReaction(reaction);
      AnalyticsService.instance.reactionSent(momentId, reactionType);
    }
  }

  String reactionIcon(String type) {
    switch (type) {
      case 'love':       return '❤️';
      case 'celebrate':  return '🎉';
      case 'inspiring':   return '✨';
      default:           return '👍';
    }
  }
}
