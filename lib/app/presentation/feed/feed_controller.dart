import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:done_drop/core/models/feed_delivery.dart';
import 'package:done_drop/core/models/moment.dart';
import 'package:done_drop/core/services/block_service.dart';
import 'package:done_drop/core/services/buddy_feed_cache_service.dart';
import 'package:done_drop/core/services/local_cache_service.dart';
import 'package:done_drop/features/auth/presentation/controllers/auth_controller.dart';
import 'package:done_drop/firebase/repositories/friend_repository.dart';
import 'package:done_drop/firebase/repositories/moment_repository.dart';
import 'package:done_drop/l10n/l10n.dart';

/// Controller for the private friend feed screen.
///
/// The remote source is the denormalized `feed_deliveries` collection, while
/// optimistic items are merged locally so the user sees their own shared proof
/// immediately instead of waiting for upload + Firestore + feed fan-out.
class FeedController extends GetxController {
  FeedController();

  static const int _headWindowSize = 20;
  static const int _olderPageSize = 20;
  static const int _cacheLimit = 120;

  MomentRepository get _momentRepo => Get.find<MomentRepository>();
  FriendRepository get _friendRepo => Get.find<FriendRepository>();
  AuthController get _authController => Get.find<AuthController>();
  String? get _userId => _authController.firebaseUser?.uid;
  BuddyFeedCacheService get _cache => BuddyFeedCacheService.instance;

  final isLoading = true.obs;
  final RxList<Moment> moments = <Moment>[].obs;
  final RxList<FeedDelivery> deliveries = <FeedDelivery>[].obs;
  final RxSet<String> blockedUserIds = <String>{}.obs;
  final RxInt unreadCount = 0.obs;
  final RxInt friendCount = 0.obs;
  final RxBool hasMore = true.obs;
  final RxBool isFetchingMore = false.obs;

  final List<FeedDelivery> _liveDeliveries = <FeedDelivery>[];
  final List<FeedDelivery> _olderDeliveries = <FeedDelivery>[];
  final RxList<Moment> _optimisticMoments = <Moment>[].obs;

  StreamSubscription<List<FeedDelivery>>? _feedSubscription;

  @override
  void onInit() {
    super.onInit();
    _hydrateCachedFeed();
    _watchBlockedUsers();
    _watchFriendFeed();
    _watchUnreadCount();
    _watchFriendCount();
  }

  @override
  void onClose() {
    _feedSubscription?.cancel();
    _cache.clearWarmRegistry();
    super.onClose();
  }

  void _hydrateCachedFeed() {
    final uid = _userId;
    if (uid == null) return;
    final cachedDeliveries = LocalCacheService.instance
        .loadCachedFeedDeliveries(uid)
        .map(FeedDelivery.fromFirestore)
        .toList(growable: false);
    if (cachedDeliveries.isEmpty) return;

    final liveSlice = cachedDeliveries.take(_headWindowSize).toList();
    final olderSlice = cachedDeliveries.skip(_headWindowSize).toList();

    _liveDeliveries
      ..clear()
      ..addAll(liveSlice);
    _olderDeliveries
      ..clear()
      ..addAll(olderSlice);
    hasMore.value = cachedDeliveries.length >= _headWindowSize;
    _rebuildRemoteState();
    isLoading.value = false;
  }

  void _watchBlockedUsers() {
    final blockSvc = Get.find<BlockService>();
    blockSvc.watchBlockedUserIds().listen(
      (ids) {
        blockedUserIds
          ..clear()
          ..addAll(ids);
        _mergeMoments();
      },
      onError: (error) {
        debugPrint('[_watchBlockedUsers] Error: $error');
      },
    );
  }

  void _watchFriendFeed() {
    final uid = _userId;
    if (uid == null) {
      isLoading.value = false;
      return;
    }

    _feedSubscription?.cancel();
    _feedSubscription = _momentRepo.watchFeedDeliveries(uid).listen(
      (deliveryList) async {
        _liveDeliveries
          ..clear()
          ..addAll(
            deliveryList
                .where((delivery) => !blockedUserIds.contains(delivery.ownerId)),
          );
        final liveIds = _liveDeliveries.map((delivery) => delivery.id).toSet();
        _olderDeliveries.removeWhere((delivery) => liveIds.contains(delivery.id));
        hasMore.value = _olderDeliveries.isNotEmpty ||
            deliveryList.length >= _headWindowSize;
        _rebuildRemoteState();
        await _cache.cacheDeliveries(
          uid,
          deliveries.take(_cacheLimit).toList(growable: false),
        );
        isLoading.value = false;
      },
      onError: (error) {
        debugPrint('[_watchFriendFeed] Error: $error');
        isLoading.value = false;
      },
    );
  }

  void _watchUnreadCount() {
    final uid = _userId;
    if (uid == null) return;
    _momentRepo.watchUnreadFeedCount(uid).listen(
      (count) {
        unreadCount.value = count;
      },
      onError: (error) {
        debugPrint('[_watchUnreadCount] Error: $error');
      },
    );
  }

  void _watchFriendCount() {
    final uid = _userId;
    if (uid == null) return;
    _friendRepo.watchFriendships(uid).listen(
      (list) {
        friendCount.value = list.length;
      },
      onError: (error) {
        debugPrint('[_watchFriendCount] Error: $error');
      },
    );
  }

  String getOwnerName(Moment moment) {
    return moment.ownerDisplayName ?? currentL10n.memberFallbackName;
  }

  String? getOwnerAvatar(Moment moment) {
    return moment.ownerAvatarUrl;
  }

  String? activityTitleFor(Moment moment) => moment.activityTitle;

  Future<void> markAllRead() async {
    for (final delivery in deliveries) {
      if (!delivery.isRead) {
        await _momentRepo.markDeliveryRead(delivery.id);
      }
    }
  }

  Future<void> markMomentRead(String momentId) async {
    final delivery = deliveries.firstWhereOrNull(
      (item) => item.momentId == momentId && !item.isRead,
    );
    if (delivery == null) return;
    await _momentRepo.markDeliveryRead(delivery.id);
  }

  void upsertOptimisticMoment(Moment moment) {
    final index = _optimisticMoments.indexWhere((item) => item.id == moment.id);
    if (index == -1) {
      _optimisticMoments.insert(0, moment);
    } else {
      _optimisticMoments[index] = moment;
    }
    _mergeMoments();
  }

  void updateOptimisticMoment(
    String momentId, {
    MomentMedia? media,
    MomentSyncStatus? syncStatus,
    double? uploadProgress,
  }) {
    final index = _optimisticMoments.indexWhere((item) => item.id == momentId);
    if (index == -1) return;
    final current = _optimisticMoments[index];
    _optimisticMoments[index] = current.copyWith(
      media: media,
      syncStatus: syncStatus,
      uploadProgress: uploadProgress,
    );
    _mergeMoments();
  }

  Future<void> loadMoreIfNeeded(int index) async {
    if (_userId == null ||
        isFetchingMore.value ||
        !hasMore.value ||
        index < moments.length - 4) {
      return;
    }

    final oldestLoaded = deliveries.isNotEmpty ? deliveries.last.createdAt : null;
    if (oldestLoaded == null) return;

    isFetchingMore.value = true;
    try {
      final page = await _momentRepo.fetchFeedDeliveriesPage(
        _userId!,
        startAfterCreatedAt: oldestLoaded,
        limit: _olderPageSize,
      );
      final existingIds = deliveries.map((delivery) => delivery.id).toSet();
      final uniquePage = page
          .where((delivery) => !existingIds.contains(delivery.id))
          .where((delivery) => !blockedUserIds.contains(delivery.ownerId))
          .toList(growable: false);

      if (page.length < _olderPageSize) {
        hasMore.value = false;
      }

      if (uniquePage.isNotEmpty) {
        _olderDeliveries.addAll(uniquePage);
        _rebuildRemoteState();
        await _cache.cacheDeliveries(
          _userId!,
          deliveries.take(_cacheLimit).toList(growable: false),
        );
      } else {
        hasMore.value = false;
      }
    } finally {
      isFetchingMore.value = false;
    }
  }

  void _mergeMoments() {
    final blocked = blockedUserIds;
    final remoteMoments = deliveries.map(Moment.fromFeedDelivery).toList();
    final remoteIds = remoteMoments.map((moment) => moment.id).toSet();
    final optimistic = _optimisticMoments
        .where((moment) => !remoteIds.contains(moment.id))
        .where((moment) => !blocked.contains(moment.ownerId))
        .toList(growable: false);

    final merged = <Moment>[
      ...optimistic,
      ...remoteMoments.where((moment) => !blocked.contains(moment.ownerId)),
    ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    moments.value = merged;
  }

  void _rebuildRemoteState() {
    final mergedById = <String, FeedDelivery>{};
    for (final delivery in <FeedDelivery>[..._liveDeliveries, ..._olderDeliveries]) {
      mergedById[delivery.id] = delivery;
    }

    final merged = mergedById.values.toList(growable: false)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    deliveries.value = merged;
    _mergeMoments();
  }
}
