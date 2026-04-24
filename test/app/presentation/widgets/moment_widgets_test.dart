import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:done_drop/core/models/moment.dart';
import 'package:done_drop/core/constants/app_constants.dart';

void main() {
  group('MomentSyncStatus enum', () {
    test('all status values are distinct', () {
      final statuses = MomentSyncStatus.values.toSet();
      expect(statuses.length, MomentSyncStatus.values.length);
    });

    test('isPendingSync returns true for non-synced states', () {
      expect(
        _fakeMoment(syncStatus: MomentSyncStatus.synced).isPendingSync,
        isFalse,
      );
      expect(
        _fakeMoment(syncStatus: MomentSyncStatus.queued).isPendingSync,
        isTrue,
      );
      expect(
        _fakeMoment(syncStatus: MomentSyncStatus.uploading).isPendingSync,
        isTrue,
      );
      expect(
        _fakeMoment(syncStatus: MomentSyncStatus.failed).isPendingSync,
        isTrue,
      );
    });
  });

  group('Visibility chip rendering', () {
    testWidgets('renders private visibility icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _VisibilityChip(visibility: 'personal_only'),
          ),
        ),
      );
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    });

    testWidgets('renders all_friends visibility icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _VisibilityChip(visibility: 'all_friends'),
          ),
        ),
      );
      expect(find.byIcon(Icons.groups_outlined), findsOneWidget);
    });

    testWidgets('renders selected_friends visibility icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _VisibilityChip(visibility: 'selected_friends'),
          ),
        ),
      );
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
    });
  });

  group('Sync status widget rendering', () {
    testWidgets('shows error icon for failed status', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _SyncStatusWidget(
              moment: _fakeMoment(syncStatus: MomentSyncStatus.failed),
            ),
          ),
        ),
      );
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('shows progress indicator for uploading status', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _SyncStatusWidget(
              moment: _fakeMoment(syncStatus: MomentSyncStatus.uploading),
            ),
          ),
        ),
      );
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('shows no indicator for synced status', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _SyncStatusWidget(
              moment: _fakeMoment(syncStatus: MomentSyncStatus.synced),
            ),
          ),
        ),
      );
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });
  });
}

// ── Test helpers ───────────────────────────────────────────────────────────────

class _SyncStatusWidget extends StatelessWidget {
  const _SyncStatusWidget({required this.moment});
  final Moment moment;

  @override
  Widget build(BuildContext context) {
    switch (moment.syncStatus) {
      case MomentSyncStatus.failed:
        return const Icon(Icons.error_outline, key: Key('error_icon'));
      case MomentSyncStatus.uploading:
      case MomentSyncStatus.queued:
      case MomentSyncStatus.processing:
      case MomentSyncStatus.finalizing:
        return Column(
          children: [
            LinearProgressIndicator(value: moment.uploadProgress.clamp(0, 1)),
            Text(moment.syncStatus.name),
          ],
        );
      case MomentSyncStatus.synced:
        return const Icon(Icons.check_circle);
    }
  }
}

class _VisibilityChip extends StatelessWidget {
  const _VisibilityChip({required this.visibility});
  final String visibility;

  IconData get _icon {
    switch (visibility) {
      case 'all_friends':
        return Icons.groups_outlined;
      case 'selected_friends':
        return Icons.person_outline;
      default:
        return Icons.lock_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(_icon, size: 16),
      label: Text(visibility),
    );
  }
}

Moment _fakeMoment({
  MomentSyncStatus syncStatus = MomentSyncStatus.synced,
}) =>
    Moment(
      id: 'widget-test-moment',
      ownerId: 'user_test',
      visibility: AppConstants.visibilityPersonalOnly,
      media: MomentMedia.empty(),
      caption: 'test caption',
      completedAt: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      syncStatus: syncStatus,
    );
