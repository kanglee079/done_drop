import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:done_drop/data/local/models/pending_sync_item.dart';

/// Local database service using Isar for offline support.
///
/// Isar stores:
/// - Pending sync queue (queued Firestore/Storage operations)
/// - Cached moments, activities, friend profiles for offline read
class LocalDatabaseService {
  LocalDatabaseService._();
  static final LocalDatabaseService _instance = LocalDatabaseService._();
  static LocalDatabaseService get instance => _instance;

  Isar? _isar;

  bool get isInitialized => _isar != null;
  Isar get db {
    if (_isar == null) {
      throw StateError('LocalDatabaseService not initialized. Call init() first.');
    }
    return _isar!;
  }

  /// Initialize Isar. Call this before runApp().
  Future<void> init() async {
    if (_isar != null) return;

    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [PendingSyncItemSchema],
      directory: dir.path,
      name: 'donedrop_local',
    );
  }

  /// Close the database.
  Future<void> close() async {
    await _isar?.close();
    _isar = null;
  }

  // ── Pending Sync Queue ─────────────────────────────────────────────────

  /// Add a sync item to the queue.
  Future<int> addSyncItem(PendingSyncItem item) async {
    return db.writeTxn(() => db.pendingSyncItems.put(item));
  }

  /// Get all pending sync items, ordered by createdAt.
  Future<List<PendingSyncItem>> getPendingItems() async {
    return db.pendingSyncItems
        .where()
        .statusEqualTo('pending')
        .sortByCreatedAt()
        .findAll();
  }

  /// Mark a sync item as completed and remove it.
  Future<void> completeSyncItem(int id) async {
    await db.writeTxn(() => db.pendingSyncItems.delete(id));
  }

  /// Mark a sync item as failed with retry count incremented.
  Future<void> failSyncItem(int id, String error) async {
    await db.writeTxn(() async {
      final item = await db.pendingSyncItems.get(id);
      if (item != null) {
        item.status = 'failed';
        item.retryCount = item.retryCount + 1;
        item.lastError = error;
        await db.pendingSyncItems.put(item);
      }
    });
  }

  /// Get total count of pending items.
  Future<int> getPendingCount() async {
    return db.pendingSyncItems.where().statusEqualTo('pending').count();
  }

  /// Clear all completed items.
  Future<void> clearCompleted() async {
    await db.writeTxn(() async {
      final completed = await db.pendingSyncItems
          .where()
          .filter()
          .statusEqualTo('completed')
          .findAll();
      for (final item in completed) {
        await db.pendingSyncItems.delete(item.id);
      }
    });
  }

  /// Clear all items for a target document.
  Future<void> clearForTarget(String targetId) async {
    await db.writeTxn(() async {
      final items = await db.pendingSyncItems
          .where()
          .targetIdEqualTo(targetId)
          .findAll();
      for (final item in items) {
        await db.pendingSyncItems.delete(item.id);
      }
    });
  }

  /// Watch pending count as a stream.
  Stream<int> watchPendingCount() {
    return db.pendingSyncItems
        .filter()
        .statusEqualTo('pending')
        .watch(fireImmediately: true)
        .map((list) => list.length);
  }
}
