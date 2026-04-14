import 'package:done_drop/core/constants/app_constants.dart';
import 'package:done_drop/core/models/feed_delivery.dart';

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
    required String momentId,
    required String ownerId,
    required String visibility,
    required DateTime createdAt,
    required List<String> recipientIds,
  }) {
    return _dedupe(recipientIds)
        .map(
          (recipientId) => FeedDelivery(
            id: deliveryIdForMoment(momentId, recipientId),
            recipientId: recipientId,
            momentId: momentId,
            ownerId: ownerId,
            visibility: visibility,
            createdAt: createdAt,
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
