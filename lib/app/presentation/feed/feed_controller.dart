import 'package:get/get.dart';
import 'package:done_drop/firebase/repositories/moment_repository.dart';
import 'package:done_drop/firebase/repositories/friend_repository.dart';
import 'package:done_drop/features/auth/presentation/controllers/auth_controller.dart';
import 'package:done_drop/core/models/moment.dart';
import 'package:done_drop/core/models/feed_delivery.dart';
import 'package:done_drop/core/models/user_profile.dart';
import 'package:done_drop/features/auth/repositories/user_profile_repository.dart';
import 'package:done_drop/app/presentation/feed/reaction_controller.dart';
import 'package:done_drop/core/errors/result.dart';

/// Controller for the private friend feed screen.
/// Aggregates moments shared with the current user via feed deliveries.
class FeedController extends GetxController {
  FeedController();

  MomentRepository get _momentRepo => Get.find<MomentRepository>();
  FriendRepository get _friendRepo => Get.find<FriendRepository>();
  UserProfileRepository get _userProfileRepo => Get.find<UserProfileRepository>();
  AuthController get _authController => Get.find<AuthController>();

  String? get _userId => _authController.firebaseUser?.uid;

  final isLoading = true.obs;
  final RxList<Moment> moments = <Moment>[].obs;
  final RxList<FeedDelivery> deliveries = <FeedDelivery>[].obs;
  final RxMap<String, UserProfile> ownerProfiles = <String, UserProfile>{}.obs;
  final RxInt unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _watchFriendFeed();
    _watchUnreadCount();
  }

  void _watchFriendFeed() {
    final uid = _userId;
    if (uid == null) {
      isLoading.value = false;
      return;
    }

    _momentRepo.watchFeedDeliveries(uid).listen((deliveryList) async {
      deliveries.value = deliveryList;
      isLoading.value = false;

      // Load moment details
      final momentIds = deliveryList.map((d) => d.momentId).whereType<String>().toList();
      final momentList = await _momentRepo.getMomentsForFeed(momentIds);

      // Sort by delivery order (most recent first)
      final momentMap = {for (final m in momentList) m.id: m};
      moments.value = momentIds
          .where((id) => momentMap.containsKey(id))
          .map((id) => momentMap[id]!)
          .toList();

      // Load owner profiles for display
      _loadOwnerProfiles(momentList.map((m) => m.ownerId).toSet().toList());
    });
  }

  Future<void> _loadOwnerProfiles(List<String> ownerIds) async {
    for (final id in ownerIds) {
      if (!ownerProfiles.containsKey(id)) {
        final result = await _userProfileRepo.getUserProfile(id);
        final profile = result.fold(
          onSuccess: (data) => data,
          onFailure: (_) => null,
        );
        if (profile != null) {
          ownerProfiles[id] = profile;
        }
      }
    }
  }

  void _watchUnreadCount() {
    final uid = _userId;
    if (uid == null) return;
    _momentRepo.watchUnreadFeedCount(uid).listen((count) {
      unreadCount.value = count;
    });
  }

  String getOwnerName(String ownerId) {
    return ownerProfiles[ownerId]?.displayName ?? 'Friend';
  }

  String? getOwnerAvatar(String ownerId) {
    return ownerProfiles[ownerId]?.avatarUrl;
  }

  Future<void> markAllRead() async {
    for (final delivery in deliveries) {
      if (!delivery.isRead) {
        await _momentRepo.markDeliveryRead(delivery.id);
      }
    }
  }

  ReactionController get reactionCtrl => Get.find<ReactionController>();
}
