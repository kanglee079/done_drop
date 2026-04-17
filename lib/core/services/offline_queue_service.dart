import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:done_drop/core/services/local_database_service.dart';
import 'package:done_drop/core/services/connectivity_service.dart';
import 'package:done_drop/core/services/activity_completion_service.dart';
import 'package:done_drop/core/services/feed_delivery_planner.dart';
import 'package:done_drop/data/local/models/pending_sync_item.dart';
import 'package:done_drop/core/models/moment.dart';
import 'package:done_drop/core/models/completion_log.dart';
import 'package:done_drop/core/services/media_service.dart';

/// OfflineQueueService — queues Firestore/Storage operations when offline,
/// and syncs them when connectivity is restored.
///
/// Supported actions:
/// - create_moment: Create moment doc + upload media + create feed deliveries
/// - complete_activity: Mark instance completed + create CompletionLog + update streak
///
/// Queued items are stored in Isar via LocalDatabaseService.
/// Sync is triggered automatically when ConnectivityService detects online status.
class OfflineQueueService extends GetxService implements HabitCompletionQueue {
  OfflineQueueService();

  LocalDatabaseService get _db => LocalDatabaseService.instance;
  ConnectivityService get _connectivity => Get.find<ConnectivityService>();
  final FeedDeliveryPlanner _deliveryPlanner = const FeedDeliveryPlanner();
  MediaService get _mediaService => MediaService.instance;

  /// Whether currently syncing
  final RxBool isSyncing = false.obs;

  /// Number of pending items in queue
  final RxInt pendingCount = 0.obs;

  /// Subscribe token for connectivity changes
  void Function()? _connectivityUnsubscribe;

  @override
  void onInit() {
    super.onInit();
    _watchPendingCount();
    _listenForConnectivity();
  }

  @override
  void onClose() {
    _connectivityUnsubscribe?.call();
    super.onClose();
  }

  void _watchPendingCount() {
    _db.watchPendingCount().listen((n) {
      pendingCount.value = n;
    });
  }

  void _listenForConnectivity() {
    _connectivityUnsubscribe = _connectivity.onConnectivityChanged((isOnline) {
      if (isOnline) {
        syncQueue();
      }
    });
  }

  // ── Public API ───────────────────────────────────────────────────────────

  /// Queue a moment creation for sync when online.
  /// Stores both the moment data and local media path for upload.
  Future<void> queueCreateMoment({
    required String momentId,
    required String ownerId,
    required Map<String, dynamic> momentData,
    required String localMediaPath,
    required List<String> recipientIds,
    String? activityId,
    String? activityInstanceId,
    String? completionLogId,
  }) async {
    await _db.addSyncItem(
      PendingSyncItem.create(
        actionType: 'create_moment',
        payload: {
          'momentId': momentId,
          'ownerId': ownerId,
          'momentData': momentData,
          'recipientIds': recipientIds,
          'activityId': activityId,
          'activityInstanceId': activityInstanceId,
          'completionLogId': completionLogId,
          'createdAt': DateTime.now().toIso8601String(),
        },
        localFilePath: localMediaPath,
        storagePath: 'moments/$ownerId/$momentId/original.jpg',
        targetId: momentId,
        priority: 10,
      ),
    );
  }

  /// Queue an activity completion for sync when online.
  @override
  Future<void> queueCompleteHabit({
    required String activityId,
    required String instanceId,
    required String ownerId,
    required String completionLogId,
    required DateTime completedAt,
  }) async {
    await _db.addSyncItem(
      PendingSyncItem.create(
        actionType: 'complete_activity',
        payload: {
          'activityId': activityId,
          'instanceId': instanceId,
          'ownerId': ownerId,
          'completionLogId': completionLogId,
          'completedAt': completedAt.toIso8601String(),
        },
        targetId: instanceId,
        priority: 5,
      ),
    );
  }

  /// Attempt to sync the entire pending queue.
  /// Called automatically when connectivity is restored, or manually by the user.
  Future<void> syncQueue() async {
    if (isSyncing.value) return;
    if (!_connectivity.isOnline.value) return;

    isSyncing.value = true;

    final items = await _db.getPendingItems();
    for (final item in items) {
      try {
        await _processItem(item);
        await _db.completeSyncItem(item.id);
      } catch (e) {
        await _db.failSyncItem(item.id, e.toString());
        if (item.retryCount >= 3) {
          await _db.completeSyncItem(item.id);
        }
      }
    }

    isSyncing.value = false;
  }

  // ── Internal Processing ──────────────────────────────────────────────────

  Future<void> _processItem(PendingSyncItem item) async {
    switch (item.actionType) {
      case 'create_moment':
        await _processCreateMoment(item);
        break;
      case 'complete_activity':
        await _processCompleteActivity(item);
        break;
      default:
        throw UnsupportedError('Unknown action type: ${item.actionType}');
    }
  }

  Future<void> _processCreateMoment(PendingSyncItem item) async {
    final payload = item.payload;
    final ownerId = payload['ownerId'] as String;
    final momentId = payload['momentId'] as String;
    final momentData = payload['momentData'] as Map<String, dynamic>;
    final recipientIds =
        (payload['recipientIds'] as List<dynamic>? ?? const <dynamic>[])
            .cast<String>();
    final activityId = payload['activityId'] as String?;
    final activityInstanceId = payload['activityInstanceId'] as String?;
    final completionLogId = payload['completionLogId'] as String?;

    final db = FirebaseFirestore.instance;

    MomentMedia? momentMedia;
    if (item.localFilePath != null) {
      momentMedia = await _mediaService.uploadMomentImages(
        userId: ownerId,
        momentId: momentId,
        localFilePath: item.localFilePath!,
      );
    }

    final completedAt = DateTime.parse(momentData['completedAt'] as String);
    final createdAt = DateTime.parse(momentData['createdAt'] as String);
    final updatedAt = DateTime.parse(momentData['updatedAt'] as String);

    final moment = Moment(
      id: momentId,
      ownerId: ownerId,
      ownerDisplayName: momentData['ownerDisplayName'] as String?,
      ownerAvatarUrl: momentData['ownerAvatarUrl'] as String?,
      activityId: activityId,
      activityInstanceId: activityInstanceId,
      completionLogId: completionLogId,
      activityTitle: momentData['activityTitle'] as String?,
      visibility: momentData['visibility'] as String? ?? 'personal_only',
      selectedFriendIds:
          (momentData['selectedFriendIds'] as List<dynamic>?)?.cast<String>() ??
          [],
      media: momentMedia ?? MomentMedia.empty(),
      caption: momentData['caption'] as String? ?? '',
      category: momentData['category'] as String?,
      completedAt: completedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      reactionCounts: const {},
      isDeleted: false,
      moderationStatus: 'approved',
    );

    await db.collection('moments').doc(momentId).set(moment.toFirestore());

    if (activityInstanceId != null && completionLogId != null) {
      await db.collection('activity_instances').doc(activityInstanceId).update({
        'momentId': momentId,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    }

    final visibility = momentData['visibility'] as String?;
    if (visibility != null && recipientIds.isNotEmpty) {
      await _createFeedDeliveries(
        db,
        moment: moment,
        recipientIds: recipientIds,
      );
    }

    if (completionLogId != null) {
      await db.collection('completion_logs').doc(completionLogId).update({
        'momentId': momentId,
      });
    }
  }

  Future<void> _processCompleteActivity(PendingSyncItem item) async {
    final payload = item.payload;
    final instanceId = payload['instanceId'] as String;
    final ownerId = payload['ownerId'] as String;
    final completionLogId = payload['completionLogId'] as String;
    final activityId = payload['activityId'] as String;
    final completedAt = DateTime.parse(payload['completedAt'] as String);

    final db = FirebaseFirestore.instance;

    // 1. Mark instance as completed
    await db.collection('activity_instances').doc(instanceId).update({
      'status': 'completed',
      'completedAt': completedAt.toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    });

    // 2. Create completion log
    final log = CompletionLog(
      id: completionLogId,
      activityId: activityId,
      activityInstanceId: instanceId,
      ownerId: ownerId,
      completedAt: completedAt,
      createdAt: completedAt,
    );
    await db
        .collection('completion_logs')
        .doc(completionLogId)
        .set(log.toFirestore());

    // 3. Increment streak
    final activityRef = db.collection('activities').doc(activityId);
    await db.runTransaction((tx) async {
      final snap = await tx.get(activityRef);
      if (!snap.exists) return;
      final data = snap.data()!;
      final currentStreak = (data['currentStreak'] as int?) ?? 0;
      final longestStreak = (data['longestStreak'] as int?) ?? 0;
      final newStreak = currentStreak + 1;
      tx.update(activityRef, {
        'currentStreak': newStreak,
        'longestStreak': newStreak > longestStreak ? newStreak : longestStreak,
        'lastCompletedAt': completedAt.toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
    });
  }

  Future<void> _createFeedDeliveries(
    FirebaseFirestore db, {
    required Moment moment,
    required List<String> recipientIds,
  }) async {
    final deliveries = _deliveryPlanner.buildDeliveries(
      moment: moment,
      recipientIds: recipientIds,
    );
    if (deliveries.isEmpty) return;
    final batch = db.batch();
    for (final delivery in deliveries) {
      batch.set(
        db.collection('feed_deliveries').doc(delivery.id),
        delivery.toFirestore(),
      );
    }
    await batch.commit();
  }
}
