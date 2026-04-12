import 'package:flutter_test/flutter_test.dart';
import 'package:done_drop/core/models/activity.dart';
import 'package:done_drop/core/models/activity_instance.dart';
import 'package:done_drop/core/models/completion_log.dart';
import 'package:done_drop/core/models/moment.dart';
import 'package:done_drop/core/models/friend_request.dart';
import 'package:done_drop/core/models/friendship.dart';
import 'package:done_drop/core/models/feed_delivery.dart';
import 'package:done_drop/core/constants/app_constants.dart';

MediaMetadata _makeMedia({
  String path = 'test/original.jpg',
  String url = 'https://example.com/test.jpg',
  int w = 100,
  int h = 100,
  int size = 1000,
}) =>
    MediaMetadata(
      storagePath: path,
      downloadUrl: url,
      mimeType: 'image/jpeg',
      width: w,
      height: h,
      bytesUploaded: size,
      ownerId: 'user_1',
    );

void main() {
  group('Activity', () {
    test('creates with required fields', () {
      final now = DateTime.now();
      final activity = Activity(
        id: 'act_1',
        ownerId: 'user_1',
        title: 'Morning Run',
        recurrence: 'daily',
        currentStreak: 3,
        longestStreak: 7,
        updatedAt: now,
      );

      expect(activity.id, 'act_1');
      expect(activity.ownerId, 'user_1');
      expect(activity.title, 'Morning Run');
      expect(activity.currentStreak, 3);
      expect(activity.longestStreak, 7);
      expect(activity.isArchived, false);
      expect(activity.hasReminder, false);
    });

    test('hasReminder returns true when reminderTime is set', () {
      final now = DateTime.now();
      final activity = Activity(
        id: 'act_1',
        ownerId: 'user_1',
        title: 'Read',
        reminderTime: '20:00',
        updatedAt: now,
      );

      expect(activity.hasReminder, true);
      expect(activity.reminderHour, 20);
      expect(activity.reminderMinute, 0);
    });

    test('toFirestore and fromFirestore roundtrip', () {
      final now = DateTime.now();
      final activity = Activity(
        id: 'act_1',
        ownerId: 'user_1',
        title: 'Meditate',
        description: '10 minutes',
        category: 'Health',
        recurrence: 'daily',
        reminderTime: '07:00',
        currentStreak: 5,
        longestStreak: 10,
        createdAt: now,
        updatedAt: now,
      );

      final map = activity.toFirestore();
      final restored = Activity.fromFirestore(map);

      expect(restored.id, activity.id);
      expect(restored.ownerId, activity.ownerId);
      expect(restored.title, activity.title);
      expect(restored.description, activity.description);
      expect(restored.currentStreak, activity.currentStreak);
      expect(restored.recurrence, 'daily');
      expect(restored.reminderTime, '07:00');
    });

    test('copyWith creates a new instance with updated fields', () {
      final now = DateTime.now();
      final original = Activity(
        id: 'act_1',
        ownerId: 'user_1',
        title: 'Original',
        currentStreak: 1,
        updatedAt: now,
      );

      final updated = original.copyWith(
        title: 'Updated',
        currentStreak: 2,
      );

      expect(updated.title, 'Updated');
      expect(updated.currentStreak, 2);
      expect(updated.id, original.id);
      expect(updated.ownerId, original.ownerId);
    });
  });

  group('ActivityInstance', () {
    test('isPending, isCompleted, isMissed return correct values', () {
      final now = DateTime.now();
      final pending = ActivityInstance(
        id: 'inst_1',
        activityId: 'act_1',
        ownerId: 'user_1',
        date: now,
        status: 'pending',
        createdAt: now,
        updatedAt: now,
      );

      expect(pending.isPending, true);
      expect(pending.isCompleted, false);
      expect(pending.isMissed, false);

      final completed = pending.copyWith(
        status: 'completed',
        completedAt: now,
      );

      expect(completed.isPending, false);
      expect(completed.isCompleted, true);
    });

    test('isOverdue returns true when past end of day and pending', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final instance = ActivityInstance(
        id: 'inst_old',
        activityId: 'act_1',
        ownerId: 'user_1',
        date: yesterday,
        status: 'pending',
        createdAt: yesterday,
        updatedAt: yesterday,
      );

      expect(instance.isOverdue, true);
    });
  });

  group('Moment', () {
    test('toFirestore and fromFirestore roundtrip with media', () {
      final now = DateTime.now();
      final moment = Moment(
        id: 'moment_1',
        ownerId: 'user_1',
        visibility: AppConstants.visibilityAllFriends,
        selectedFriendIds: const ['friend_1', 'friend_2'],
        media: MomentMedia(
          original: _makeMedia(
            path: 'moments/user_1/moment_1/original.jpg',
            url: 'https://storage.example.com/original.jpg',
            w: 1200,
            h: 1200,
            size: 500000,
          ),
          thumbnail: _makeMedia(
            path: 'moments/user_1/moment_1/thumb.jpg',
            url: 'https://storage.example.com/thumb.jpg',
            w: 400,
            h: 400,
            size: 50000,
          ),
        ),
        caption: 'My morning run!',
        category: 'Health & Fitness',
        completedAt: now,
        createdAt: now,
        updatedAt: now,
      );

      final map = moment.toFirestore();
      final restored = Moment.fromFirestore(map);

      expect(restored.id, moment.id);
      expect(restored.visibility, AppConstants.visibilityAllFriends);
      expect(restored.selectedFriendIds.length, 2);
      expect(restored.media.thumbnail.downloadUrl, moment.media.thumbnail.downloadUrl);
      expect(restored.caption, 'My morning run!');
    });

    test('personal_only moments have empty selectedFriendIds', () {
      final now = DateTime.now();
      final moment = Moment(
        id: 'moment_1',
        ownerId: 'user_1',
        visibility: AppConstants.visibilityPersonalOnly,
        media: MomentMedia(
          original: _makeMedia(),
          thumbnail: _makeMedia(
            path: 'test/thumb.jpg',
            url: 'https://example.com/thumb.jpg',
          ),
        ),
        caption: 'Private',
        completedAt: now,
        createdAt: now,
        updatedAt: now,
      );

      expect(moment.visibility, 'personal_only');
      expect(moment.selectedFriendIds.isEmpty, true);
    });
  });

  group('Friendship', () {
    test('creates with sorted IDs for deterministic ID', () {
      final friendship = Friendship.create('zzz_user', 'aaa_user');

      // IDs should be sorted lexicographically
      expect(friendship.userId1, 'aaa_user');
      expect(friendship.userId2, 'zzz_user');
      expect(friendship.id, 'aaa_user_zzz_user');
    });

    test('otherUserId returns the correct user', () {
      final friendship = Friendship.create('user_a', 'user_b');

      expect(friendship.otherUserId('user_a'), 'user_b');
      expect(friendship.otherUserId('user_b'), 'user_a');
    });

    test('involves returns true for either party', () {
      final friendship = Friendship.create('user_a', 'user_b');

      expect(friendship.involves('user_a'), true);
      expect(friendship.involves('user_b'), true);
      expect(friendship.involves('user_c'), false);
    });
  });

  group('FriendRequest', () {
    test('status helpers work correctly', () {
      final request = FriendRequest(
        id: 'req_1',
        senderId: 'user_1',
        receiverId: 'user_2',
        status: 'pending',
        createdAt: DateTime.now(),
      );

      expect(request.isPending, true);
      expect(request.isAccepted, false);
      expect(request.isDeclined, false);
    });
  });

  group('FeedDelivery', () {
    test('roundtrip toFirestore/fromFirestore', () {
      final now = DateTime.now();
      final delivery = FeedDelivery(
        id: 'fd_m1_u2',
        recipientId: 'user_2',
        momentId: 'moment_1',
        ownerId: 'user_1',
        visibility: 'all_friends',
        createdAt: now,
        isRead: false,
      );

      final map = delivery.toFirestore();
      final restored = FeedDelivery.fromFirestore(map);

      expect(restored.id, delivery.id);
      expect(restored.recipientId, delivery.recipientId);
      expect(restored.momentId, delivery.momentId);
      expect(restored.visibility, 'all_friends');
      expect(restored.isRead, false);
    });
  });

  group('CompletionLog', () {
    test('roundtrip toFirestore/fromFirestore', () {
      final now = DateTime.now();
      final log = CompletionLog(
        id: 'log_1',
        activityId: 'act_1',
        activityInstanceId: 'inst_1',
        ownerId: 'user_1',
        completedAt: now,
        momentId: 'moment_1',
        createdAt: now,
      );

      final map = log.toFirestore();
      final restored = CompletionLog.fromFirestore(map);

      expect(restored.id, log.id);
      expect(restored.activityId, log.activityId);
      expect(restored.momentId, 'moment_1');
    });
  });
}
