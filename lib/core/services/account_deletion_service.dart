import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:done_drop/core/constants/app_constants.dart';
import 'package:done_drop/core/errors/failures.dart';
import 'package:done_drop/core/errors/result.dart';
import 'package:done_drop/core/services/local_cache_service.dart';
import 'package:done_drop/core/services/local_database_service.dart';
import 'package:done_drop/core/services/media_service.dart';
import 'package:done_drop/core/services/notification_service.dart';
import 'package:done_drop/core/services/storage_service.dart';

class AccountDeletionService {
  AccountDeletionService({
    FirebaseFirestore? firestore,
    MediaService? mediaService,
    StorageService? storageService,
    LocalCacheService? localCacheService,
    LocalDatabaseService? localDatabaseService,
    NotificationService? notificationService,
  }) : _db = firestore ?? FirebaseFirestore.instance,
       _media = mediaService ?? MediaService.instance,
       _storage = storageService ?? StorageService.instance,
       _localCache = localCacheService ?? LocalCacheService.instance,
       _localDatabase = localDatabaseService ?? LocalDatabaseService.instance,
       _notifications = notificationService ?? NotificationService.instance;

  final FirebaseFirestore _db;
  final MediaService _media;
  final StorageService _storage;
  final LocalCacheService _localCache;
  final LocalDatabaseService _localDatabase;
  final NotificationService _notifications;

  static const _batchLimit = 200;

  Future<Result<void>> deleteUserData(String userId) async {
    try {
      await _deleteOwnedMoments(userId);
      await _deleteCollectionWhere(
        collectionPath: AppConstants.colReactions,
        field: 'userId',
        value: userId,
      );
      await _deleteCollectionWhere(
        collectionPath: AppConstants.colActivities,
        field: 'ownerId',
        value: userId,
      );
      await _deleteCollectionWhere(
        collectionPath: AppConstants.colActivityInstances,
        field: 'ownerId',
        value: userId,
      );
      await _deleteCollectionWhere(
        collectionPath: AppConstants.colCompletionLogs,
        field: 'ownerId',
        value: userId,
      );
      await _deleteCollectionWhere(
        collectionPath: AppConstants.colWeeklyRecaps,
        field: 'ownerId',
        value: userId,
      );
      await _deleteCollectionWhere(
        collectionPath: 'task_templates',
        field: 'ownerId',
        value: userId,
      );
      await _deleteCollectionWhere(
        collectionPath: AppConstants.colFeedDeliveries,
        field: 'recipientId',
        value: userId,
      );
      await _deleteCollectionWhere(
        collectionPath: AppConstants.colFriendRequests,
        field: 'senderId',
        value: userId,
      );
      await _deleteCollectionWhere(
        collectionPath: AppConstants.colFriendRequests,
        field: 'receiverId',
        value: userId,
      );
      await _deleteCollectionWhere(
        collectionPath: AppConstants.colFriendships,
        field: 'userId1',
        value: userId,
      );
      await _deleteCollectionWhere(
        collectionPath: AppConstants.colFriendships,
        field: 'userId2',
        value: userId,
      );
      await _deleteSubcollection(
        parentPath: '${AppConstants.colUsers}/$userId',
        subcollection: 'blockedUsers',
      );
      await _media.deleteAvatar(userId);
      await _db.collection(AppConstants.colUsers).doc(userId).delete();
      return Result.success(null);
    } catch (e) {
      return Result.failure(
        AppFailure.unexpected('Failed to delete account data: $e'),
      );
    }
  }

  Future<void> clearLocalState() async {
    await clearSessionState();
    await _storage.clear();
  }

  Future<void> clearSessionState() async {
    await _notifications.cancelAll();
    await _localCache.clearAll();
    await _localDatabase.clearAll();
    await _media.clearCache();
    await _storage.remove(AppConstants.keyUserId);
  }

  Future<void> _deleteOwnedMoments(String userId) async {
    while (true) {
      final snap = await _db
          .collection(AppConstants.colMoments)
          .where('ownerId', isEqualTo: userId)
          .limit(_batchLimit)
          .get();
      if (snap.docs.isEmpty) return;

      final batch = _db.batch();
      for (final doc in snap.docs) {
        final momentId = doc.id;
        await _media.deleteMomentImages(userId, momentId);
        await _deleteCollectionWhere(
          collectionPath: AppConstants.colFeedDeliveries,
          field: 'momentId',
          value: momentId,
        );
        await _deleteCollectionWhere(
          collectionPath: AppConstants.colReactions,
          field: 'momentId',
          value: momentId,
        );
        batch.delete(doc.reference);
      }
      await batch.commit();

      if (snap.docs.length < _batchLimit) return;
    }
  }

  Future<void> _deleteSubcollection({
    required String parentPath,
    required String subcollection,
  }) async {
    while (true) {
      final snap = await _db
          .doc(parentPath)
          .collection(subcollection)
          .limit(_batchLimit)
          .get();
      if (snap.docs.isEmpty) return;

      final batch = _db.batch();
      for (final doc in snap.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      if (snap.docs.length < _batchLimit) return;
    }
  }

  Future<void> _deleteCollectionWhere({
    required String collectionPath,
    required String field,
    required Object? value,
  }) async {
    while (true) {
      final snap = await _db
          .collection(collectionPath)
          .where(field, isEqualTo: value)
          .limit(_batchLimit)
          .get();
      if (snap.docs.isEmpty) return;

      final batch = _db.batch();
      for (final doc in snap.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      if (snap.docs.length < _batchLimit) return;
    }
  }
}
