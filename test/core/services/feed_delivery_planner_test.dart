import 'package:flutter_test/flutter_test.dart';
import 'package:done_drop/core/constants/app_constants.dart';
import 'package:done_drop/core/services/feed_delivery_planner.dart';

void main() {
  group('FeedDeliveryPlanner', () {
    const planner = FeedDeliveryPlanner();

    test('resolves recipients deterministically for all friends', () {
      final recipients = planner.resolveRecipientIds(
        visibility: AppConstants.visibilityAllFriends,
        allFriendIds: ['b', 'a', 'b'],
        selectedFriendIds: const [],
      );

      expect(recipients, ['a', 'b']);
    });

    test('builds stable delivery ids for queued moments', () {
      final deliveries = planner.buildDeliveries(
        momentId: 'moment-1',
        ownerId: 'owner-1',
        visibility: AppConstants.visibilitySelectedFriends,
        createdAt: DateTime(2026, 4, 14),
        recipientIds: ['friend-2', 'friend-1', 'friend-1'],
      );

      expect(deliveries.map((delivery) => delivery.id), [
        'fd_moment-1_friend-1',
        'fd_moment-1_friend-2',
      ]);
    });
  });
}
