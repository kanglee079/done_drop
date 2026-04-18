import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:done_drop/firebase/repositories/moment_repository.dart';
import 'package:done_drop/features/auth/presentation/controllers/auth_controller.dart';
import 'package:done_drop/core/models/moment.dart';
import 'package:done_drop/core/services/analytics_service.dart';
import 'package:done_drop/core/theme/theme.dart';
import 'package:done_drop/l10n/l10n.dart';

/// Controller for managing moment reactions (love / celebrate / inspiring).
class ReactionController extends GetxController {
  ReactionController();

  MomentRepository get _momentRepo => Get.find<MomentRepository>();
  AuthController get _authController => Get.find<AuthController>();

  String? get _userId => _authController.firebaseUser?.uid;

  final reactionTypes = ['love', 'celebrate'];
  final summaries = <String, MomentReactionSummary>{}.obs;
  final pendingMomentIds = <String>{}.obs;
  final Map<String, StreamSubscription<MomentReactionSummary>>
      _summarySubscriptions = {};

  @override
  void onClose() {
    for (final subscription in _summarySubscriptions.values) {
      subscription.cancel();
    }
    _summarySubscriptions.clear();
    super.onClose();
  }

  void observeMoment(String momentId) {
    if (_summarySubscriptions.containsKey(momentId)) {
      return;
    }
    final uid = _userId;
    if (uid == null) return;

    _summarySubscriptions[momentId] = _momentRepo
        .watchReactionSummary(momentId, currentUserId: uid)
        .listen(
          (summary) {
            summaries[momentId] = summary;
            pendingMomentIds.remove(momentId);
          },
          onError: (error) {
            debugPrint('[ReactionController.observeMoment] $error');
            pendingMomentIds.remove(momentId);
          },
        );
  }

  MomentReactionSummary summaryFor(Moment moment) {
    return summaries[moment.id] ??
        MomentReactionSummary(counts: moment.reactionCounts);
  }

  bool isBusy(String momentId) => pendingMomentIds.contains(momentId);

  /// Toggle a reaction on a moment: add if none, replace if different, remove if same.
  Future<void> toggleReaction({
    required String momentId,
    required String reactionType,
    String? currentUserReaction,
  }) async {
    final uid = _userId;
    if (uid == null) return;
    observeMoment(momentId);
    final activeReaction =
        currentUserReaction ?? summaries[momentId]?.currentUserReaction;
    pendingMomentIds.add(momentId);

    try {
      if (activeReaction == reactionType) {
        await _momentRepo.removeReaction(momentId, uid);
        AnalyticsService.instance.reactionRemoved(momentId);
      } else {
        final reaction = Reaction(
          id: MomentRepository.reactionDocumentId(momentId, uid),
          momentId: momentId,
          userId: uid,
          reactionType: reactionType,
          createdAt: DateTime.now(),
        );
        await _momentRepo.addReaction(reaction);
        AnalyticsService.instance.reactionSent(momentId, reactionType);
      }
    } finally {
      pendingMomentIds.remove(momentId);
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

  IconData reactionIconData(String type) {
    switch (type) {
      case 'love':
        return Icons.favorite_rounded;
      case 'celebrate':
        return Icons.celebration_rounded;
      case 'inspiring':
        return Icons.auto_awesome_rounded;
      default:
        return Icons.thumb_up_alt_rounded;
    }
  }

  Color reactionColor(String type) {
    switch (type) {
      case 'love':
        return const Color(0xFFE2497A);
      case 'celebrate':
        return const Color(0xFFF2994A);
      case 'inspiring':
        return AppColors.tertiary;
      default:
        return AppColors.primary;
    }
  }

  String reactionLabel(BuildContext context, String type) {
    final l10n = context.l10n;
    switch (type) {
      case 'love':
        return l10n.reactionLoveLabel;
      case 'celebrate':
        return l10n.reactionCelebrateLabel;
      case 'inspiring':
        return l10n.reactionInspiringLabel;
      default:
        return type;
    }
  }
}
