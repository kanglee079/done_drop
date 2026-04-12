import 'package:get/get.dart';
import 'package:done_drop/features/auth/presentation/controllers/auth_controller.dart';
import 'package:done_drop/firebase/repositories/friend_repository.dart';
import 'package:done_drop/core/models/friend_request.dart';
import 'package:done_drop/core/models/friendship.dart';
import 'package:done_drop/core/errors/result.dart';
import 'package:done_drop/core/services/analytics_service.dart';

/// Controller for friend management screens.
class FriendsController extends GetxController {
  FriendsController(this._friendRepo);
  final FriendRepository _friendRepo;

  /// Expose repository for screens that need direct access.
  FriendRepository get friendRepo => _friendRepo;

  String? get _userId => Get.find<AuthController>().firebaseUser?.uid;
  String? get currentUserId => _userId;

  /// Accepted friendships.
  final RxList<Friendship> friendships = <Friendship>[].obs;

  /// Incoming pending requests.
  final RxList<FriendRequest> incomingRequests = <FriendRequest>[].obs;

  /// Outgoing pending requests.
  final RxList<FriendRequest> outgoingRequests = <FriendRequest>[].obs;

  /// Pending request count (for badge).
  final RxInt pendingRequestCount = 0.obs;

  /// Current friend count.
  final RxInt friendCount = 0.obs;

  /// Whether the user has reached the friend cap.
  bool get isAtFriendCap => friendCount.value >= FriendRepository.maxFriendsFree;

  int get maxFriends => FriendRepository.maxFriendsFree;

  bool get hasPendingRequests => incomingRequests.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    _watchFriendships();
    _watchIncomingRequests();
    _watchOutgoingRequests();
  }

  void _watchFriendships() {
    final uid = _userId;
    if (uid == null) return;
    _friendRepo.watchFriendships(uid).listen((list) {
      friendships.value = list;
      friendCount.value = list.length;
    });
  }

  void _watchIncomingRequests() {
    final uid = _userId;
    if (uid == null) return;
    incomingRequests.bindStream(_friendRepo.watchIncomingRequests(uid));
    pendingRequestCount.bindStream(_friendRepo.watchIncomingRequestCount(uid));
  }

  void _watchOutgoingRequests() {
    final uid = _userId;
    if (uid == null) return;
    outgoingRequests.bindStream(_friendRepo.watchOutgoingRequests(uid));
  }

  /// Accept an incoming friend request.
  Future<void> acceptRequest(FriendRequest request) async {
    final result = await _friendRepo.acceptRequest(request.id);
    result.fold(
      onSuccess: (_) {
        AnalyticsService.instance.inviteAccepted();
        Get.snackbar(
          'Friend Added',
          '${request.senderDisplayName ?? 'User'} is now your friend',
          snackPosition: SnackPosition.BOTTOM,
        );
      },
      onFailure: (failure) {
        Get.snackbar('Error', failure.message, snackPosition: SnackPosition.BOTTOM);
      },
    );
  }

  /// Decline an incoming friend request.
  Future<void> declineRequest(FriendRequest request) async {
    await _friendRepo.declineRequest(request.id);
  }

  /// Cancel an outgoing friend request.
  Future<void> cancelRequest(FriendRequest request) async {
    await _friendRepo.cancelRequest(request.id);
  }

  /// Remove an existing friendship.
  Future<void> removeFriend(Friendship friendship) async {
    final uid = _userId;
    if (uid == null) return;

    final result = await _friendRepo.removeFriend(friendship.id, uid);
    result.fold(
      onSuccess: (_) {
        Get.snackbar('Friend Removed', 'The friendship has been removed',
            snackPosition: SnackPosition.BOTTOM);
      },
      onFailure: (failure) {
        Get.snackbar('Error', failure.message, snackPosition: SnackPosition.BOTTOM);
      },
    );
  }

  /// Check if a user can add more friends (under cap).
  Future<bool> canAddMoreFriends() async {
    final uid = _userId;
    if (uid == null) return false;
    return _friendRepo.canAddFriend(uid);
  }
}
