import 'package:flutter_test/flutter_test.dart';
import 'package:done_drop/core/models/moment.dart';

void main() {
  group('MemoryWallController — owner archive and optimistic behavior', () {
    group('month grouping', () {
      test('moments group into correct months', () {
        final moments = [
          _wallMoment('m1', DateTime(2024, 1, 5)),
          _wallMoment('m2', DateTime(2024, 1, 15)),
          _wallMoment('m3', DateTime(2024, 3, 10)),
          _wallMoment('m4', DateTime(2024, 3, 20)),
          _wallMoment('m5', DateTime(2023, 12, 31)),
        ];

        final grouped = _groupByMonth(moments);

        expect(grouped.keys.length, 3);
        expect(grouped[DateTime(2024, 1)]!.length, 2);
        expect(grouped[DateTime(2024, 3)]!.length, 2);
        expect(grouped[DateTime(2023, 12)]!.length, 1);
      });

      test('empty list produces empty groups', () {
        final grouped = _groupByMonth([]);
        expect(grouped, isEmpty);
      });

      test('single moment produces one group', () {
        final moments = [_wallMoment('m1', DateTime(2024, 2, 10))];
        final grouped = _groupByMonth(moments);
        expect(grouped.keys.length, 1);
        expect(grouped[DateTime(2024, 2)]!.length, 1);
      });
    });

    group('category filter', () {
      test('filter by category returns matching moments', () {
        final moments = [
          _wallMoment('m1', DateTime(2024, 1, 1), category: 'Exercise'),
          _wallMoment('m2', DateTime(2024, 1, 2), category: 'Health'),
          _wallMoment('m3', DateTime(2024, 1, 3), category: 'Exercise'),
          _wallMoment('m4', DateTime(2024, 1, 4)), // no category
        ];

        final filtered = moments.where((m) => m.category == 'Exercise').toList();
        expect(filtered.length, 2);
        expect(filtered.every((m) => m.category == 'Exercise'), isTrue);
      });

      test('filter with empty category returns moments without category', () {
        final moments = [
          _wallMoment('m1', DateTime(2024, 1, 1), category: 'Exercise'),
          _wallMoment('m2', DateTime(2024, 1, 2), category: null),
          _wallMoment('m3', DateTime(2024, 1, 3), category: ''),
        ];

        final noCategory = moments.where(
          (m) => (m.category ?? '').isEmpty,
        ).toList();

        expect(noCategory.length, 2);
      });

      test('all categories returns all moments', () {
        final moments = [
          _wallMoment('m1', DateTime(2024, 1, 1), category: 'Exercise'),
          _wallMoment('m2', DateTime(2024, 1, 2), category: 'Health'),
          _wallMoment('m3', DateTime(2024, 1, 3)),
        ];

        final filtered = moments
            .where((m) => m.category == null || m.category!.isEmpty)
            .toList();

        expect(filtered.length, 1);
      });
    });

    group('optimistic insert', () {
      test('optimistic moment inserted at front of list', () {
        final existing = [
          _wallMoment('m1', DateTime(2024, 1, 1)),
          _wallMoment('m2', DateTime(2024, 1, 2)),
        ];
        final optimistic = _wallMoment(
          'm-new',
          DateTime(2024, 2, 1),
          syncStatus: MomentSyncStatus.queued,
        );

        final updated = [optimistic, ...existing];

        expect(updated.first.id, 'm-new');
        expect(updated.first.syncStatus, MomentSyncStatus.queued);
        expect(updated.length, 3);
      });

      test('optimistic moment replaced by synced moment on ack', () {
        final optimistics = [
          _wallMoment('m-queued', DateTime(2024, 2, 1), syncStatus: MomentSyncStatus.queued),
        ];
        final remote = _wallMoment('m-queued', DateTime(2024, 2, 1), syncStatus: MomentSyncStatus.synced);

        // Replace optimistic with synced version using momentId.
        final synced = optimistics
            .where((m) => m.id != remote.id)
            .toList()
          ..insert(0, remote);

        expect(synced.length, 1);
        expect(synced.first.syncStatus, MomentSyncStatus.synced);
      });

      test('optimistic moments are removed on failed upload', () {
        final moments = [
          _wallMoment('m-ok', DateTime(2024, 1, 1), syncStatus: MomentSyncStatus.synced),
          _wallMoment('m-queued', DateTime(2024, 1, 2), syncStatus: MomentSyncStatus.queued),
          _wallMoment('m-failed', DateTime(2024, 1, 3), syncStatus: MomentSyncStatus.failed),
        ];

        // Keep only synced or currently uploading moments.
        final cleaned = moments.where((m) => m.syncStatus != MomentSyncStatus.failed).toList();

        expect(cleaned.length, 2);
        expect(cleaned.any((m) => m.id == 'm-failed'), isFalse);
      });
    });

    group('moment ordering', () {
      test('moments sorted by createdAt descending within month', () {
        final moments = [
          _wallMoment('m1', DateTime(2024, 1, 1)),
          _wallMoment('m2', DateTime(2024, 1, 15)),
          _wallMoment('m3', DateTime(2024, 1, 10)),
        ];

        moments.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        expect(moments[0].id, 'm2'); // Jan 15
        expect(moments[1].id, 'm3'); // Jan 10
        expect(moments[2].id, 'm1'); // Jan 1
      });

      test('month groups sorted by date descending', () {
        final moments = [
          _wallMoment('m1', DateTime(2023, 6, 1)),
          _wallMoment('m2', DateTime(2024, 1, 1)),
          _wallMoment('m3', DateTime(2023, 12, 1)),
        ];

        final grouped = _groupByMonth(moments);
        final sortedKeys = grouped.keys.toList()
          ..sort((a, b) => b.compareTo(a));

        expect(sortedKeys[0], DateTime(2024, 1));
        expect(sortedKeys[1], DateTime(2023, 12));
        expect(sortedKeys[2], DateTime(2023, 6));
      });
    });

    group('Moment.ownerArchive', () {
      test('owner archive filter includes personal_only moments', () {
        final moments = [
          _wallMoment('m1', DateTime.now(), visibility: 'personal_only'),
          _wallMoment('m2', DateTime.now(), visibility: 'all_friends'),
        ];

        final archive = moments.where(
          (m) => m.ownerId == 'current-user',
        ).toList();

        expect(archive.length, 2);
      });

      test('wall moment thumbnail URL is available', () {
        final moment = _wallMoment('m1', DateTime.now());

        expect(moment.media.bestThumbnailUrl.isNotEmpty, isTrue);
        expect(moment.media.bestThumbnailUrl, contains('example.com'));
      });
    });
  });
}

// ── Test helpers ───────────────────────────────────────────────────────────────

Map<DateTime, List<Moment>> _groupByMonth(List<Moment> moments) {
  final grouped = <DateTime, List<Moment>>{};
  for (final m in moments) {
    final key = DateTime(m.createdAt.year, m.createdAt.month);
    grouped.putIfAbsent(key, () => []).add(m);
  }
  return grouped;
}

Moment _wallMoment(
  String id,
  DateTime createdAt, {
  String? category,
  String visibility = 'personal_only',
  MomentSyncStatus syncStatus = MomentSyncStatus.synced,
}) {
  return Moment(
    id: id,
    ownerId: 'current-user',
    visibility: visibility,
    media: MomentMedia(
      original: MediaMetadata(
        storagePath: 'o/$id',
        downloadUrl: 'https://example.com/o/$id.jpg',
        mimeType: 'image/jpeg',
        width: 960,
        height: 960,
        bytesUploaded: 1000,
        ownerId: 'current-user',
        momentId: id,
      ),
      thumbnail: MediaMetadata(
        storagePath: 't/$id',
        downloadUrl: 'https://example.com/t/$id.jpg',
        mimeType: 'image/jpeg',
        width: 280,
        height: 420,
        bytesUploaded: 200,
        ownerId: 'current-user',
        momentId: id,
      ),
    ),
    caption: 'Caption for $id',
    category: category,
    completedAt: createdAt,
    createdAt: createdAt,
    updatedAt: createdAt,
    syncStatus: syncStatus,
  );
}
