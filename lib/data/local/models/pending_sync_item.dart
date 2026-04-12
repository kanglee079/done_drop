import 'dart:convert';
import 'package:hive/hive.dart';

part 'pending_sync_item.g.dart';

/// Queued sync item stored locally when offline.
@HiveType(typeId: 0)
class PendingSyncItem extends HiveObject {
  PendingSyncItem();

  /// Unique auto-increment key assigned by Hive.
  int get id => key as int? ?? -1;

  /// Type of sync action: 'create_moment', 'update_moment', 'delete_moment',
  /// 'create_activity', 'update_activity', 'delete_activity',
  /// 'complete_activity_instance', 'upload_media'.
  @HiveField(0)
  late String actionType;

  /// JSON payload of the sync action.
  @HiveField(1)
  late String payloadJson;

  /// When this item was created (queued).
  @HiveField(2)
  late DateTime createdAt;

  /// Number of retry attempts.
  @HiveField(3)
  int retryCount = 0;

  /// Last error message if failed.
  @HiveField(4)
  String? lastError;

  /// Status: 'pending', 'in_progress', 'failed', 'completed'.
  @HiveField(5)
  String status = 'pending';

  /// For media uploads: the local file path.
  @HiveField(6)
  String? localFilePath;

  /// For media uploads: the target storage path.
  @HiveField(7)
  String? storagePath;

  /// Priority (higher = processed first).
  @HiveField(8)
  int priority = 0;

  /// Document ID this action targets (for deduplication).
  @HiveField(9)
  String? targetId;

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
