import 'dart:async';

import 'package:get/get.dart';

import 'package:done_drop/core/models/feed_delivery.dart';
import 'package:done_drop/core/models/moment.dart';
import 'package:done_drop/core/services/block_service.dart';
import 'package:done_drop/features/auth/presentation/controllers/auth_controller.dart';
import 'package:done_drop/firebase/repositories/friend_repository.dart';
import 'package:done_drop/firebase/repositories/moment_repository.dart';

/// Controller for the private friend feed screen.
///
/// The remote source is the denormalized `feed_deliveries` collection, while
/// optimistic items are merged locally so the user sees their own shared proof
/// immediately instead of waiting for upload + Firestore + feed fan-out.
class FeedController extends GetxController {
  FeedController();

  MomentRepository get _momentRepo => Get.find<MomentRepository>();
  FriendRepository get _friendRepo => Get.find<FriendRepository>();
  AuthController get _authController => Get.find<AuthController>();
  String? get _userId => _authController.firebaseUser?.uid;

  final isLoading = true.obs;
  final RxList<Moment> moments = <Moment>[].obs;
  final RxList<FeedDelivery> deliveries = <FeedDelivery>[].obs;
  final RxSet<String> blockedUserIds = <String>{}.obs;
  final RxInt unreadCount = 0.obs;
  final RxInt friendCount = 0.obs;

  final List<Moment> _remoteMoments = <Moment>[];
  final RxList<Moment> _optimisticMoments = <Moment>[].obs;

  StreamSubscription<List<FeedDelivery>>? _feedSubscription;

  @override
  void onInit() {
    super.onInit();
    _watchBlockedUsers();
    _watchFriendFeed();
    _watchUnreadCount();
    _watchFriendCount();
  }

  @override
  void onClose() {
    _feedSubscription?.cancel();
    super.onClose();
  }

  void _watchBlockedUsers() {
    final blockSvc = Get.find<BlockService>();
    blockSvc.watchBlockedUserIds().listen((ids) {
      blockedUserIds
        ..clear()
        ..addAll(ids);
      _mergeMoments();
    });
  }

  void _watchFriendFeed() {
    final uid = _userId;
    if (uid == null) {
      isLoading.value = false;
      return;
    }

    _feedSubscription?.cancel();
    _feedSubscription = _momentRepo.watchFeedDeliveries(uid).listen((
      deliveryList,
    ) {
      deliveries.value = deliveryList;
      _remoteMoments
        ..clear()
        ..addAll(
          deliveryList
              .where((delivery) => !blockedUserIds.contains(delivery.ownerId))
              .map(Moment.fromFeedDelivery),
        );
      _mergeMoments();
      isLoading.value = false;
    });
  }

  void _watchUnreadCount() {
    final uid = _userId;
    if (uid == null) return;
    _momentRepo.watchUnreadFeedCount(uid).listen((count) {
      unreadCount.value = count;
    });
  }

  void _watchFriendCount() {
    final uid = _userId;
    if (uid == null) return;
    _friendRepo.watchFriendships(uid).listen((list) {
      friendCount.value = list.length;
    });
  }

  String getOwnerName(Moment moment) {
    return moment.ownerDisplayName ?? 'Friend';
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

  void _mergeMoments() {
    final blocked = blockedUserIds;
    final remoteIds = _remoteMoments.map((moment) => moment.id).toSet();
    final optimistic = _optimisticMoments
        .where((moment) => !remoteIds.contains(moment.id))
        .where((moment) => !blocked.contains(moment.ownerId))
        .toList(growable: false);

    final merged = <Moment>[
      ...optimistic,
      ..._remoteMoments.where((moment) => !blocked.contains(moment.ownerId)),
    ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    moments.value = merged;
  }
}
