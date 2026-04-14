import 'dart:async';
import 'package:get/get.dart';
import 'package:done_drop/firebase/repositories/moment_repository.dart';
import 'package:done_drop/firebase/repositories/friend_repository.dart';
import 'package:done_drop/firebase/repositories/activity_repository.dart';
import 'package:done_drop/features/auth/presentation/controllers/auth_controller.dart';
import 'package:done_drop/core/models/moment.dart';
import 'package:done_drop/core/models/feed_delivery.dart';
import 'package:done_drop/core/models/user_profile.dart';
import 'package:done_drop/core/services/block_service.dart';
import 'package:done_drop/features/auth/repositories/user_profile_repository.dart';
import 'package:done_drop/app/presentation/feed/reaction_controller.dart';

/// Controller for the private friend feed screen.
/// Aggregates moments shared with the current user via feed deliveries.
class FeedController extends GetxController {
  FeedController(this._activityRepo);

  MomentRepository get _momentRepo => Get.find<MomentRepository>();
  FriendRepository get _friendRepo => Get.find<FriendRepository>();
  UserProfileRepository get _userProfileRepo =>
      Get.find<UserProfileRepository>();
  AuthController get _authController => Get.find<AuthController>();
  final ActivityRepository _activityRepo;
  String? get _userId => _authController.firebaseUser?.uid;

  final isLoading = true.obs;
  final RxList<Moment> moments = <Moment>[].obs;
  final RxList<FeedDelivery> deliveries = <FeedDelivery>[].obs;
  final RxMap<String, UserProfile> ownerProfiles = <String, UserProfile>{}.obs;
  final RxMap<String, String> activityTitles = <String, String>{}.obs;
  final RxSet<String> blockedUserIds = <String>{}.obs;
  final RxInt unreadCount = 0.obs;
  final RxInt friendCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _watchBlockedUsers();
    _watchFriendFeed();
    _watchUnreadCount();
    _watchFriendCount();
  }

  void _watchBlockedUsers() {
    final blockSvc = Get.find<BlockService>();
    blockSvc.watchBlockedUserIds().listen((ids) {
      blockedUserIds.clear();
      blockedUserIds.addAll(ids);
      // Re-filter feed when blocked list changes (removes orphaned moments)
      _reapplyBlockFilter();
    });
  }

  void _reapplyBlockFilter() {
    // Re-run block filter on current moments without re-fetching Firestore
    if (moments.isEmpty) return;
    final filtered = moments
        .where((m) => !blockedUserIds.contains(m.ownerId))
        .toList();
    moments.value = filtered;
  }

  StreamSubscription<List<FeedDelivery>>? _feedSubscription;

  void _watchFriendFeed() {
    final uid = _userId;
    if (uid == null) {
      isLoading.value = false;
      return;
    }

    _feedSubscription?.cancel();
    _feedSubscription = _momentRepo.watchFeedDeliveries(uid).listen((
      deliveryList,
    ) async {
      deliveries.value = deliveryList;

      // Load moment details
      final momentIds = deliveryList
          .map((d) => d.momentId)
          .whereType<String>()
          .toList();
      final momentList = await _momentRepo.getMomentsForFeed(momentIds);

      // Filter out moments from blocked users (client-side safety net)
      final visibleMoments = momentList
          .where((m) => !blockedUserIds.contains(m.ownerId))
          .toList();

      // Sort by delivery order (most recent first), preserving delivery sequence
      final momentMap = {for (final m in visibleMoments) m.id: m};
      final visibleIds = momentIds
          .where((id) => momentMap.containsKey(id))
          .toList();
      moments.value = visibleIds.map((id) => momentMap[id]!).toList();

      // Load owner profiles for display — batch fetch in parallel
      final ownerIds = visibleMoments.map((m) => m.ownerId).toSet().toList();
      final profiles = await _userProfileRepo.getUserProfiles(ownerIds);
      ownerProfiles.value = profiles;
      await _loadActivityTitles(visibleMoments);

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

  String getOwnerName(String ownerId) {
    return ownerProfiles[ownerId]?.displayName ?? 'Friend';
  }

  String? getOwnerAvatar(String ownerId) {
    return ownerProfiles[ownerId]?.avatarUrl;
  }

  String? activityTitleFor(Moment moment) {
    final activityId = moment.activityId;
    if (activityId == null) return null;
    return activityTitles[activityId];
  }

  Future<void> markAllRead() async {
    for (final delivery in deliveries) {
      if (!delivery.isRead) {
        await _momentRepo.markDeliveryRead(delivery.id);
      }
    }
  }

  Future<void> _loadActivityTitles(List<Moment> moments) async {
    final ids = moments
        .map((moment) => moment.activityId)
        .whereType<String>()
        .toSet()
        .toList(growable: false);
    if (ids.isEmpty) {
      activityTitles.clear();
      return;
    }

    final resolvedTitles = <String, String>{};
    for (final activityId in ids) {
      final activity = await _activityRepo.getActivity(activityId);
      if (activity != null) {
        resolvedTitles[activityId] = activity.title;
      }
    }
    activityTitles.value = resolvedTitles;
  }

  ReactionController get reactionCtrl => Get.find<ReactionController>();
}
