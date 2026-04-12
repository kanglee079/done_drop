import 'dart:convert';
import 'package:isar/isar.dart';

part 'pending_sync_item.g.dart';

/// Queued sync item stored locally when offline.
@collection
class PendingSyncItem {
  Id id = Isar.autoIncrement;

  /// Type of sync action: 'create_moment', 'update_moment', 'delete_moment',
  /// 'create_activity', 'update_activity', 'delete_activity',
  /// 'complete_activity_instance', 'upload_media'.
  @Index()
  late String actionType;

  /// JSON payload of the sync action.
  late String payloadJson;

  /// When this item was created (queued).
  late DateTime createdAt;

  /// Number of retry attempts.
  int retryCount = 0;

  /// Last error message if failed.
  String? lastError;

  /// Status: 'pending', 'in_progress', 'failed', 'completed'.
  @Index()
  String status = 'pending';

  /// For media uploads: the local file path.
  String? localFilePath;

  /// For media uploads: the target storage path.
  String? storagePath;

  /// Priority (higher = processed first).
  int priority = 0;

  /// Document ID this action targets (for deduplication).
  @Index()
  String? targetId;

  PendingSyncItem();

  factory PendingSyncItem.create({
    required String actionType,
    required Map<String, dynamic> payload,
    String? localFilePath,
    String? storagePath,
    String? targetId,
    int priority = 0,
  }) {
    return PendingSyncItem()
      ..actionType = actionType
      ..payloadJson = jsonEncode(payload)
      ..createdAt = DateTime.now()
      ..localFilePath = localFilePath
      ..storagePath = storagePath
      ..targetId = targetId
      ..priority = priority
      ..status = 'pending'
      ..retryCount = 0;
  }

  Map<String, dynamic> get payload =>
      jsonDecode(payloadJson) as Map<String, dynamic>;
}
