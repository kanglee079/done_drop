import 'package:done_drop/core/constants/app_constants.dart';
import 'package:done_drop/core/models/feed_delivery.dart';
import 'package:done_drop/core/models/moment.dart';

class FeedDeliveryPlanner {
  const FeedDeliveryPlanner();

  List<String> resolveRecipientIds({
    required String visibility,
    required List<String> allFriendIds,
    required List<String> selectedFriendIds,
  }) {
    switch (visibility) {
      case AppConstants.visibilityAllFriends:
        return _dedupe(allFriendIds);
      case AppConstants.visibilitySelectedFriends:
        return _dedupe(selectedFriendIds);
      default:
        return const <String>[];
    }
  }

  List<FeedDelivery> buildDeliveries({
    required Moment moment,
    required List<String> recipientIds,
  }) {
    return _dedupe(recipientIds)
        .map(
          (recipientId) => FeedDelivery(
            id: deliveryIdForMoment(moment.id, recipientId),
            recipientId: recipientId,
            momentId: moment.id,
            ownerId: moment.ownerId,
            ownerDisplayName: moment.ownerDisplayName ?? 'Friend',
            ownerAvatarUrl: moment.ownerAvatarUrl,
            visibility: moment.visibility,
            caption: moment.caption,
            category: moment.category,
            activityTitle: moment.activityTitle,
            originalUrl: moment.media.bestOriginalUrl,
            thumbnailUrl: moment.media.bestThumbnailUrl,
            completedAt: moment.completedAt,
            createdAt: moment.createdAt,
            isRead: recipientId == moment.ownerId,
          ),
        )
        .toList(growable: false);
  }

  static String deliveryIdForMoment(String momentId, String recipientId) =>
      'fd_${momentId}_$recipientId';

  List<String> _dedupe(List<String> ids) {
    return ids.where((id) => id.isNotEmpty).toSet().toList()..sort();
  }
}
