import 'package:get/get.dart';
import 'package:done_drop/features/auth/presentation/controllers/auth_controller.dart';
import 'package:done_drop/firebase/repositories/friend_repository.dart';
import 'package:done_drop/core/models/friend_request.dart';
import 'package:done_drop/core/errors/result.dart';
import 'package:done_drop/core/services/analytics_service.dart';

/// Controller for the Friends tab and friend management screens.
class FriendsController extends GetxController {
  FriendsController(this._friendRepo);
  final FriendRepository _friendRepo;

  String? get _userId => Get.find<AuthController>().firebaseUser?.uid;
  /// Exposed for screens that need to know the current user ID.
  String? get currentUserId => _userId;

  /// Accepted friendships.
  final RxList<FriendRequest> friends = <FriendRequest>[].obs;

  /// Incoming pending requests.
  final RxList<FriendRequest> incomingRequests = <FriendRequest>[].obs;

  /// Outgoing pending requests.
  final RxList<FriendRequest> outgoingRequests = <FriendRequest>[].obs;

  /// Pending request count (for badge).
  final RxInt pendingRequestCount = 0.obs;

  bool get hasPendingRequests => incomingRequests.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    _watchFriends();
    _watchIncomingRequests();
    _watchOutgoingRequests();
  }

  void _watchFriends() {
    final uid = _userId;
    if (uid == null) return;
    friends.bindStream(_friendRepo.watchFriends(uid));
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
        Get.snackbar('Error', failure.toString(), snackPosition: SnackPosition.BOTTOM);
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

  /// Remove an existing friend.
  Future<void> removeFriend(FriendRequest friendship) async {
    await _friendRepo.removeFriend(friendship.id);
    Get.snackbar(
      'Friend Removed',
      'The friendship has been removed',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
