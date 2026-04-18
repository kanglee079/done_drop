import 'package:flutter_test/flutter_test.dart';
import 'package:done_drop/core/constants/app_constants.dart';
import 'package:done_drop/core/models/moment.dart';
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
      final createdAt = DateTime(2026, 4, 14);
      final deliveries = planner.buildDeliveries(
        moment: Moment(
          id: 'moment-1',
          ownerId: 'owner-1',
          ownerDisplayName: 'Owner',
          ownerAvatarUrl: 'https://example.com/avatar.jpg',
          activityTitle: 'Morning Run',
          visibility: AppConstants.visibilitySelectedFriends,
          media: MomentMedia(
            original: const MediaMetadata(
              storagePath: 'moments/owner-1/moment-1/original.jpg',
              downloadUrl: 'https://example.com/original.jpg',
              mimeType: 'image/jpeg',
              width: 1080,
              height: 1080,
              bytesUploaded: 120000,
              ownerId: 'owner-1',
              momentId: 'moment-1',
            ),
            thumbnail: const MediaMetadata(
              storagePath: 'moments/owner-1/moment-1/thumb.jpg',
              downloadUrl: 'https://example.com/thumb.jpg',
              mimeType: 'image/jpeg',
              width: 400,
              height: 500,
              bytesUploaded: 24000,
              ownerId: 'owner-1',
              momentId: 'moment-1',
            ),
          ),
          caption: 'Locked in.',
          category: 'Health',
          completedAt: createdAt,
          createdAt: createdAt,
          updatedAt: createdAt,
        ),
        recipientIds: ['friend-2', 'friend-1', 'friend-1'],
      );

      expect(deliveries.map((delivery) => delivery.id), [
        'fd_moment-1_friend-1',
        'fd_moment-1_friend-2',
      ]);
      expect(deliveries.first.ownerDisplayName, 'Owner');
      expect(deliveries.first.activityTitle, 'Morning Run');
      expect(deliveries.first.thumbnailUrl, 'https://example.com/thumb.jpg');
    });

    test('falls back to original url when thumbnail is not ready yet', () {
      final createdAt = DateTime(2026, 4, 14);
      final deliveries = planner.buildDeliveries(
        moment: Moment(
          id: 'moment-2',
          ownerId: 'owner-1',
          ownerDisplayName: 'Owner',
          visibility: AppConstants.visibilityAllFriends,
          media: MomentMedia(
            original: const MediaMetadata(
              storagePath: 'moments/owner-1/moment-2/original.jpg',
              downloadUrl: 'https://example.com/original.jpg',
              mimeType: 'image/jpeg',
              width: 1080,
              height: 1080,
              bytesUploaded: 120000,
              ownerId: 'owner-1',
              momentId: 'moment-2',
            ),
            thumbnail: const MediaMetadata(
              storagePath: 'moments/owner-1/moment-2/original_280x420.jpg',
              downloadUrl: '',
              mimeType: 'image/jpeg',
              width: 280,
              height: 420,
              bytesUploaded: 0,
              ownerId: 'owner-1',
              momentId: 'moment-2',
            ),
          ),
          caption: 'Locked in.',
          completedAt: createdAt,
          createdAt: createdAt,
          updatedAt: createdAt,
        ),
        recipientIds: ['friend-1'],
      );

      expect(deliveries.single.thumbnailUrl, 'https://example.com/original.jpg');
    });
  });
}
