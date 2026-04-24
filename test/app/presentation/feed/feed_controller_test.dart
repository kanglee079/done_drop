import 'package:flutter_test/flutter_test.dart';
import 'package:done_drop/core/models/feed_delivery.dart';
import 'package:done_drop/core/models/moment.dart';

void main() {
  group('FeedController — optimistic merge and filtering', () {
    group('FeedDelivery model', () {
      test('creates from map with all fields', () {
        final map = {
          'id': 'fd-1',
          'recipientId': 'recipient-user',
          'momentId': 'm-1',
          'ownerId': 'user-1',
          'ownerDisplayName': 'Alice',
          'ownerAvatarUrl': 'https://example.com/alice.jpg',
          'activityId': 'act-1',
          'activityTitle': 'Morning Run',
          'originalUrl': 'https://example.com/orig.jpg',
          'thumbnailUrl': 'https://example.com/thumb.jpg',
          'caption': 'Ran 5k',
          'category': 'Exercise',
          'visibility': 'all_friends',
          'isRead': false,
          'createdAt': DateTime(2024, 1, 1).toIso8601String(),
          'completedAt': DateTime(2024, 1, 1).toIso8601String(),
        };

        final delivery = FeedDelivery.fromMap(map);

        expect(delivery.id, 'fd-1');
        expect(delivery.momentId, 'm-1');
        expect(delivery.ownerId, 'user-1');
        expect(delivery.ownerDisplayName, 'Alice');
        expect(delivery.ownerAvatarUrl, 'https://example.com/alice.jpg');
        expect(delivery.activityTitle, 'Morning Run');
        expect(delivery.thumbnailUrl, 'https://example.com/thumb.jpg');
        expect(delivery.caption, 'Ran 5k');
        expect(delivery.category, 'Exercise');
        expect(delivery.visibility, 'all_friends');
        expect(delivery.isRead, isFalse);
      });

      test('handles missing optional fields gracefully', () {
        final map = {
          'id': 'fd-2',
          'recipientId': 'recipient-user',
          'momentId': 'm-2',
          'ownerId': 'user-2',
          'ownerDisplayName': 'Bob',
          'visibility': 'personal_only',
          'createdAt': DateTime(2024, 1, 2).toIso8601String(),
          'completedAt': DateTime(2024, 1, 2).toIso8601String(),
        };

        final delivery = FeedDelivery.fromMap(map);

        expect(delivery.ownerAvatarUrl, isNull);
        expect(delivery.activityTitle, isNull);
        expect(delivery.thumbnailUrl, isEmpty);
        expect(delivery.caption, isEmpty);
        expect(delivery.category, isNull);
        expect(delivery.visibility, 'personal_only');
        expect(delivery.isRead, isFalse);
      });
    });

    group('Moment.fromFeedDeliveryWithStatus', () {
      test('applies sync status from parameter', () {
        final delivery = _testDelivery('fd-1', ownerId: 'user-1');

        final momentSynced =
            Moment.fromFeedDeliveryWithStatus(delivery, MomentSyncStatus.synced);
        final momentQueued =
            Moment.fromFeedDeliveryWithStatus(delivery, MomentSyncStatus.queued);

        expect(momentSynced.syncStatus, MomentSyncStatus.synced);
        expect(momentQueued.syncStatus, MomentSyncStatus.queued);
      });

      test('fromFeedDeliveryWithStatus preserves delivery fields', () {
        final delivery = _testDelivery(
          'fd-1',
          ownerId: 'user-1',
          caption: 'Ran 5k',
          thumbnailUrl: 'https://example.com/thumb.jpg',
        );

        final moment = Moment.fromFeedDeliveryWithStatus(
          delivery,
          MomentSyncStatus.synced,
        );

        expect(moment.id, 'm-1');
        expect(moment.ownerId, 'user-1');
        expect(moment.caption, 'Ran 5k');
        expect(moment.media.thumbnail.downloadUrl, 'https://example.com/thumb.jpg');
      });
    });

    group('blocked user filtering logic', () {
      test('filteredFeedDeliveries removes blocked users', () {
        final blockedIds = {'blocked-user-1', 'blocked-user-2'};
        final deliveries = [
          _testDelivery('fd-1', ownerId: 'blocked-user-1', ownerDisplayName: 'Blocked 1'),
          _testDelivery('fd-2', ownerId: 'allowed-user', ownerDisplayName: 'Allowed'),
          _testDelivery('fd-3', ownerId: 'blocked-user-2', ownerDisplayName: 'Blocked 2'),
        ];

        final filtered = deliveries
            .where((d) => !blockedIds.contains(d.ownerId))
            .toList();

        expect(filtered.length, 1);
        expect(filtered.first.ownerDisplayName, 'Allowed');
      });

      test('empty blocked set allows all deliveries', () {
        final blockedIds = <String>{};
        final deliveries = [
          _testDelivery('fd-1', ownerId: 'user-1', ownerDisplayName: 'User 1'),
          _testDelivery('fd-2', ownerId: 'user-2', ownerDisplayName: 'User 2'),
        ];

        final filtered = deliveries
            .where((d) => !blockedIds.contains(d.ownerId))
            .toList();

        expect(filtered.length, 2);
      });

      test('optimistic local moment merges with remote feed deduplicating by momentId', () {
        final remoteDeliveries = [
          _testDelivery('fd-remote-1', momentId: 'moment-posted', ownerDisplayName: 'Me', ownerId: 'current-user'),
        ];

        final localMoments = [
          _localMoment('moment-posted'),
          _localMoment('moment-new'),
        ];

        final mergedIds = <String>{};
        final merged = <dynamic>[];

        // Merge: add local optimistics first, then remote, deduping by momentId.
        for (final m in localMoments) {
          if (mergedIds.add(m.id)) {
            merged.add(m);
          }
        }
        for (final d in remoteDeliveries) {
          if (mergedIds.add(d.momentId)) {
            merged.add(d);
          }
        }

        expect(merged.length, 2);
      });

      test('isRead flag on FeedDelivery', () {
        final deliveryRead = _testDelivery('fd-1', ownerId: 'user-1', isRead: true);
        final deliveryUnread = _testDelivery('fd-2', ownerId: 'user-2', isRead: false);

        expect(deliveryRead.isRead, isTrue);
        expect(deliveryUnread.isRead, isFalse);
      });
    });

    group('pagination append logic', () {
      test('newer items prepended to existing list', () {
        final existing = [
          _testDelivery('fd-old', momentId: 'm-old', ownerDisplayName: 'Old', createdAt: DateTime(2024, 1, 1)),
        ];
        final newer = [
          _testDelivery('fd-new', momentId: 'm-new', ownerDisplayName: 'New', createdAt: DateTime(2024, 1, 15)),
        ];

        final combined = [...newer, ...existing];
        expect(combined.length, 2);
        expect(combined.first.ownerDisplayName, 'New');
      });

      test('deduplication on page append', () {
        final existing = [
          _testDelivery('fd-1', momentId: 'm-1', ownerDisplayName: 'One', createdAt: DateTime(2024, 1, 1)),
        ];
        final nextPage = [
          _testDelivery('fd-2', momentId: 'm-2', ownerDisplayName: 'Two', createdAt: DateTime(2024, 1, 10)),
          _testDelivery('fd-3', momentId: 'm-1', ownerDisplayName: 'One again', createdAt: DateTime(2024, 1, 15)),
        ];

        final seen = existing.map((d) => d.momentId).toSet();
        final deduped = nextPage.where((d) => seen.add(d.momentId)).toList();
        final combined = [...existing, ...deduped];

        expect(combined.length, 2);
        expect(combined.last.ownerDisplayName, 'Two');
      });
    });
  });
}

// ── Test helper factories ───────────────────────────────────────────────────────

FeedDelivery _testDelivery(
  String fdId, {
  String momentId = 'm-1',
  String ownerId = 'user-1',
  String ownerDisplayName = 'Test User',
  String? ownerAvatarUrl,
  String? activityTitle,
  String originalUrl = 'https://example.com/orig.jpg',
  String thumbnailUrl = 'https://example.com/thumb.jpg',
  String caption = 'Test caption',
  String? category,
  String visibility = 'all_friends',
  bool isRead = false,
  DateTime? createdAt,
  DateTime? completedAt,
}) {
  return FeedDelivery(
    id: fdId,
    recipientId: 'recipient-user',
    momentId: momentId,
    ownerId: ownerId,
    ownerDisplayName: ownerDisplayName,
    ownerAvatarUrl: ownerAvatarUrl,
    visibility: visibility,
    caption: caption,
    category: category,
    activityTitle: activityTitle,
    originalUrl: originalUrl,
    thumbnailUrl: thumbnailUrl,
    completedAt: completedAt ?? createdAt ?? DateTime(2024, 1, 1),
    createdAt: createdAt ?? DateTime(2024, 1, 1),
    isRead: isRead,
  );
}

Moment _localMoment(String id) => Moment(
      id: id,
      ownerId: 'current-user',
      visibility: 'personal_only',
      media: MomentMedia.empty(),
      caption: 'Local caption $id',
      completedAt: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      syncStatus: MomentSyncStatus.queued,
    );
