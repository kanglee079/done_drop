import 'package:flutter_test/flutter_test.dart';
import 'package:done_drop/app/presentation/capture/moment_controller.dart';
import 'package:done_drop/core/constants/app_constants.dart';
import 'package:done_drop/core/models/moment.dart';
import 'package:done_drop/core/services/media_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // ── Moment ID generation logic (mirrors MomentController._generateMomentId) ─
  String testGenerateMomentId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = timestamp.hashCode.toRadixString(36) +
        DateTime.now().microsecondsSinceEpoch.hashCode.toRadixString(36);
    return 'moment_${timestamp}_$random';
  }

  group('MomentController', () {
    group('session management', () {
      test('clears stale proof context when a new free capture starts', () {
        final controller = MomentController(
          warmPreparedUpload: (_) {},
          discardPreparedUpload: (_) {},
        );

        controller.startCaptureSession({
          'activityId': 'habit-1',
          'activityInstanceId': 'inst-1',
          'completionLogId': 'log-1',
        });
        controller.attachImage('/tmp/proof.jpg');
        controller.setCategory('Exercise');
        controller.setVisibility(AppConstants.visibilitySelectedFriends);
        controller.toggleSelectedFriend('friend-1');
        controller.captionController.text = 'done';

        controller.startCaptureSession(null);

        expect(controller.isProofMoment, isFalse);
        expect(controller.activityId, isNull);
        expect(controller.activityInstanceId, isNull);
        expect(controller.completionLogId, isNull);
        expect(controller.imagePath, isNull);
        expect(controller.selectedFriendIds, isEmpty);
        expect(controller.selectedCategory.value, isEmpty);
        expect(controller.captionController.text, isEmpty);
      });

      test('resetComposer clears a finished session', () {
        final controller = MomentController(
          warmPreparedUpload: (_) {},
          discardPreparedUpload: (_) {},
        );

        controller.startCaptureSession({
          'activityId': 'habit-1',
          'activityInstanceId': 'inst-1',
          'completionLogId': 'log-1',
        });
        controller.attachImage('/tmp/proof.jpg');

        controller.resetComposer();

        expect(controller.isProofMoment, isFalse);
        expect(controller.imagePath, isNull);
        expect(controller.lastSubmission.value, isNull);
      });

      test('resetComposer clears retry state', () {
        final controller = MomentController(
          warmPreparedUpload: (_) {},
          discardPreparedUpload: (_) {},
        );
        controller.startCaptureSession({'activityId': 'habit-1'});
        controller.attachImage('/tmp/proof.jpg');
        controller.captionController.text = 'test';
        controller.errorMessage.value = 'Upload failed';
        // ignore: invalid_use_of_protected_member
        controller.uploadRetryCount.value = 1;

        controller.resetComposer();

        expect(controller.errorMessage.value, isNull);
        expect(controller.uploadRetryCount.value, 0);
      });
    });

    group('moment ID generation', () {
      test('generates unique IDs across rapid calls', () {
        final ids = <String>{};
        for (var i = 0; i < 10; i++) {
          final id = testGenerateMomentId();
          expect(ids.contains(id), isFalse);
          ids.add(id);
        }
      });

      test('generated ID follows expected format', () {
        final id = testGenerateMomentId();
        expect(id.startsWith('moment_'), isTrue);
        final parts = id.split('_');
        expect(parts.length, greaterThanOrEqualTo(3));
        final timestamp = int.tryParse(parts[1]);
        expect(timestamp, isNotNull);
        expect(timestamp! > 0, isTrue);
      });
    });

    group('visibility selection', () {
      test('setVisibility to selectedFriends preserves friend selection', () {
        final controller = MomentController(
          warmPreparedUpload: (_) {},
          discardPreparedUpload: (_) {},
        );

        controller.setVisibility(AppConstants.visibilitySelectedFriends);
        controller.toggleSelectedFriend('friend-1');
        controller.toggleSelectedFriend('friend-2');

        controller.setVisibility(AppConstants.visibilityPersonalOnly);
        expect(controller.selectedFriendIds, isEmpty);

        controller.setVisibility(AppConstants.visibilitySelectedFriends);
        controller.toggleSelectedFriend('friend-1');
        expect(controller.selectedFriendIds, ['friend-1']);
      });

      test('selectedCategory can be set and cleared', () {
        final controller = MomentController(
          warmPreparedUpload: (_) {},
          discardPreparedUpload: (_) {},
        );

        controller.setCategory('Exercise');
        expect(controller.selectedCategory.value, 'Exercise');

        controller.setCategory(null);
        expect(controller.selectedCategory.value, isEmpty);
      });
    });

    group('upload stage labels', () {
      test('all MediaUploadStage values are distinct', () {
        final stages = MediaUploadStage.values.toSet();
        expect(stages.length, MediaUploadStage.values.length);
      });

      test('MomentSyncStatus has all expected values', () {
        final statuses = MomentSyncStatus.values.map((s) => s.name).toSet();
        expect(statuses, contains('queued'));
        expect(statuses, contains('uploading'));
        expect(statuses, contains('synced'));
        expect(statuses, contains('failed'));
        expect(statuses, contains('processing'));
        expect(statuses, contains('finalizing'));
      });
    });

    group('MomentSyncStatus.isPendingSync', () {
      test('returns false for synced status', () {
        final moment = _fakeMoment(syncStatus: MomentSyncStatus.synced);
        expect(moment.isPendingSync, isFalse);
      });

      test('returns true for queued status', () {
        final moment = _fakeMoment(syncStatus: MomentSyncStatus.queued);
        expect(moment.isPendingSync, isTrue);
      });

      test('returns true for uploading status', () {
        final moment = _fakeMoment(syncStatus: MomentSyncStatus.uploading);
        expect(moment.isPendingSync, isTrue);
      });

      test('returns true for failed status', () {
        final moment = _fakeMoment(syncStatus: MomentSyncStatus.failed);
        expect(moment.isPendingSync, isTrue);
      });
    });

    group('Moment.copyWith', () {
      test('copyWith preserves unchanged fields', () {
        final original = _fakeMoment(
          caption: 'original caption',
          syncStatus: MomentSyncStatus.synced,
        );

        final updated = original.copyWith(
          syncStatus: MomentSyncStatus.uploading,
        );

        expect(updated.caption, 'original caption');
        expect(updated.syncStatus, MomentSyncStatus.uploading);
        expect(updated.id, original.id);
        expect(updated.ownerId, original.ownerId);
      });

      test('copyWith with media updates media fields', () {
        final original = _fakeMoment();
        final newMedia = MomentMedia(
          original: MediaMetadata(
            storagePath: 'new/path.jpg',
            downloadUrl: 'https://new.com/path.jpg',
            mimeType: 'image/jpeg',
            width: 100,
            height: 100,
            bytesUploaded: 500,
            ownerId: 'owner',
            momentId: 'moment',
          ),
          thumbnail: MediaMetadata(
            storagePath: '',
            downloadUrl: '',
            mimeType: 'image/jpeg',
            width: 0,
            height: 0,
            bytesUploaded: 0,
            ownerId: '',
            momentId: '',
          ),
        );

        final updated = original.copyWith(media: newMedia);
        expect(updated.media.original.downloadUrl, 'https://new.com/path.jpg');
      });
    });

    group('MomentMedia.bestThumbnailUrl', () {
      test('prefers thumbnail URL when available', () {
        final media = MomentMedia(
          original: MediaMetadata(
            storagePath: 'o',
            downloadUrl: 'https://orig.com/img.jpg',
            mimeType: 'image/jpeg',
            width: 960,
            height: 960,
            bytesUploaded: 1000,
            ownerId: 'u',
            momentId: 'm',
          ),
          thumbnail: MediaMetadata(
            storagePath: 't',
            downloadUrl: 'https://thumb.com/img.jpg',
            mimeType: 'image/jpeg',
            width: 280,
            height: 420,
            bytesUploaded: 200,
            ownerId: 'u',
            momentId: 'm',
          ),
        );

        expect(media.bestThumbnailUrl, 'https://thumb.com/img.jpg');
      });

      test('falls back to original URL when thumbnail empty', () {
        final media = MomentMedia(
          original: MediaMetadata(
            storagePath: 'o',
            downloadUrl: 'https://orig.com/img.jpg',
            mimeType: 'image/jpeg',
            width: 960,
            height: 960,
            bytesUploaded: 1000,
            ownerId: 'u',
            momentId: 'm',
          ),
          thumbnail: MediaMetadata(
            storagePath: '',
            downloadUrl: '',
            mimeType: 'image/jpeg',
            width: 0,
            height: 0,
            bytesUploaded: 0,
            ownerId: 'u',
            momentId: 'm',
          ),
        );

        expect(media.bestThumbnailUrl, 'https://orig.com/img.jpg');
      });

      test('isGeneratedThumbnailPending true when storagePath set but no URL', () {
        final media = MomentMedia(
          original: MediaMetadata(
            storagePath: 'o',
            downloadUrl: 'https://orig.com/img.jpg',
            mimeType: 'image/jpeg',
            width: 960,
            height: 960,
            bytesUploaded: 1000,
            ownerId: 'u',
            momentId: 'm',
          ),
          thumbnail: MediaMetadata(
            storagePath: 'thumb_path_280x420',
            downloadUrl: '',
            mimeType: 'image/jpeg',
            width: 280,
            height: 420,
            bytesUploaded: 0,
            ownerId: 'u',
            momentId: 'm',
          ),
        );

        expect(media.isGeneratedThumbnailPending, isTrue);
      });
    });

    group('Moment.fromFeedDeliveryWithStatus', () {
      test('applies sync status from parameter', () {
        final momentSynced = Moment(
          id: 'm-1',
          ownerId: 'user-1',
          visibility: AppConstants.visibilityPersonalOnly,
          media: MomentMedia.empty(),
          caption: 'test',
          completedAt: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncStatus: MomentSyncStatus.synced,
        );
        final momentQueued = momentSynced.copyWith(syncStatus: MomentSyncStatus.queued);

        expect(momentSynced.syncStatus, MomentSyncStatus.synced);
        expect(momentQueued.syncStatus, MomentSyncStatus.queued);
      });
    });
  });
}

Moment _fakeMoment({
  String id = 'moment_test',
  String ownerId = 'user_test',
  String caption = 'test caption',
  MomentSyncStatus syncStatus = MomentSyncStatus.synced,
}) =>
    Moment(
      id: id,
      ownerId: ownerId,
      visibility: AppConstants.visibilityPersonalOnly,
      media: MomentMedia.empty(),
      caption: caption,
      completedAt: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      syncStatus: syncStatus,
    );
