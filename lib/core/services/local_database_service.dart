import 'package:hive_flutter/hive_flutter.dart';
import 'package:done_drop/data/local/models/pending_sync_item.dart';

/// Local database service using Hive for offline support.
///
/// Hive stores:
/// - Pending sync queue (queued Firestore/Storage operations)
/// No native code dependency — fully compatible with AGP 8.x.
class LocalDatabaseService {
  LocalDatabaseService._();
  static final LocalDatabaseService _instance = LocalDatabaseService._();
  static LocalDatabaseService get instance => _instance;

  Box<PendingSyncItem>? _box;
  int _nextId = 1;

  bool get isInitialized => _box != null;

  /// Initialize Hive. Call this before runApp().
  Future<void> init() async {
    if (_box != null) return;

    await Hive.initFlutter();
    Hive.registerAdapter(PendingSyncItemAdapter());
    _box = await Hive.openBox<PendingSyncItem>('pending_sync_items');

    // Compute the next available ID from existing items
    if (_box!.isNotEmpty) {
      final maxKey = _box!.keys
          .whereType<int>()
          .fold<int>(0, (max, k) => k > max ? k : max);
      _nextId = maxKey + 1;
    }
  }

  /// Close the database.
  Future<void> close() async {
    await _box?.close();
    _box = null;
  }

  Box<PendingSyncItem> get _syncBox {
    if (_box == null) {
      throw StateError(
          'LocalDatabaseService not initialized. Call init() first.');
    }
    return _box!;
  }

  // ── Pending Sync Queue ──────────────────────────────────────────────────────

  /// Add a sync item to the queue.
  Future<int> addSyncItem(PendingSyncItem item) async {
    final key = _nextId++;
    await _syncBox.put(key, item);
    return key;
  }

  /// Get all pending sync items, ordered by createdAt.
  Future<List<PendingSyncItem>> getPendingItems() async {
    final items = _syncBox.values
        .where((item) => item.status == 'pending')
        .toList();
    items.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return items;
  }

  /// Mark a sync item as completed and remove it.
  Future<void> completeSyncItem(int id) async {
    await _syncBox.delete(id);
  }

  /// Mark a sync item as failed with retry count incremented.
  Future<void> failSyncItem(int id, String error) async {
    final item = _syncBox.get(id);
    if (item != null) {
      item.status = 'failed';
      item.retryCount = item.retryCount + 1;
      item.lastError = error;
      await item.save();
    }
  }

  /// Get total count of pending items.
  Future<int> getPendingCount() async {
    return _syncBox.values.where((item) => item.status == 'pending').length;
  }

  /// Clear all completed items.
  Future<void> clearCompleted() async {
    final completedKeys = _syncBox.keys
        .whereType<int>()
        .where((k) => _syncBox.get(k)?.status == 'completed')
        .toList();
    for (final key in completedKeys) {
      await _syncBox.delete(key);
    }
  }

  /// Clear all items for a target document.
  Future<void> clearForTarget(String targetId) async {
    final keysToDelete = _syncBox.keys
        .whereType<int>()
        .where((k) => _syncBox.get(k)?.targetId == targetId)
        .toList();
    for (final key in keysToDelete) {
      await _syncBox.delete(key);
    }
  }

  /// Watch pending count as a stream.
  Stream<int> watchPendingCount() {
    return _syncBox.watch().map((_) {
      return _syncBox.values.where((item) => item.status == 'pending').length;
    });
  }
}
