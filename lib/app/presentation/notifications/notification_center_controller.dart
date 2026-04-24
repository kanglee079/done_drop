import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:done_drop/app/presentation/home/home_controller.dart';
import 'package:done_drop/app/routes/app_routes.dart';
import 'package:done_drop/core/models/feed_delivery.dart';
import 'package:done_drop/core/models/friend_request.dart';
import 'package:done_drop/core/services/notification_service.dart';
import 'package:done_drop/features/auth/presentation/controllers/auth_controller.dart';
import 'package:done_drop/firebase/repositories/friend_repository.dart';
import 'package:done_drop/firebase/repositories/moment_repository.dart';
import 'package:done_drop/l10n/l10n.dart';

class NotificationCenterController extends GetxController {
  AuthController get _authController => Get.find<AuthController>();
  FriendRepository get _friendRepo => Get.find<FriendRepository>();
  MomentRepository get _momentRepo => Get.find<MomentRepository>();

  final RxBool isLoading = true.obs;
  final RxList<FriendRequest> incomingRequests = <FriendRequest>[].obs;
  final RxList<FeedDelivery> unreadDeliveries = <FeedDelivery>[].obs;
  final RxInt pendingRequestCount = 0.obs;
  final RxInt unreadBuddyCount = 0.obs;
  final RxInt totalUnreadCount = 0.obs;
  final RxBool notificationsEnabled = false.obs;
  final RxBool exactAlarmEnabled = false.obs;
  final RxInt scheduledReminderCount = 0.obs;

  StreamSubscription<User?>? _authStateSubscription;
  StreamSubscription<List<FriendRequest>>? _incomingRequestsSubscription;
  StreamSubscription<int>? _incomingRequestCountSubscription;
  StreamSubscription<List<FeedDelivery>>? _deliveriesSubscription;
  StreamSubscription<int>? _unreadCountSubscription;
  String? _boundUserId;

  @override
  void onInit() {
    super.onInit();
    _handleAuthUserChanged(_authController.firebaseUser);
    _authStateSubscription = _authController.authStateStream.listen(
      _handleAuthUserChanged,
    );
    unawaited(refreshPermissionState());
  }

  @override
  void onClose() {
    _authStateSubscription?.cancel();
    _cancelDataSubscriptions();
    super.onClose();
  }

  Future<void> refreshPermissionState() async {
    final snapshot = await NotificationService.instance.getPermissionSnapshot();
    notificationsEnabled.value = snapshot.notificationsEnabled;
    exactAlarmEnabled.value = snapshot.exactAlarmsEnabled;
    scheduledReminderCount.value = snapshot.scheduledReminderCount;
  }

  Future<void> requestPermissions() async {
    await NotificationService.instance.requestPermission(
      requestExactAlarms: true,
    );
    if (Get.isRegistered<HomeController>()) {
      await NotificationService.instance.syncActivityReminders(
        Get.find<HomeController>().activities,
      );
    }
    await refreshPermissionState();
    if (!notificationsEnabled.value) {
      Get.snackbar(
        currentL10n.notificationSettingsTitle,
        currentL10n.notificationPermissionOffSubtitle,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (!exactAlarmEnabled.value) {
      Get.snackbar(
        currentL10n.notificationSettingsTitle,
        currentL10n.notificationExactAlarmOffSubtitle,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void openSettings() {
    Get.toNamed(AppRoutes.notificationSettings);
  }

  void openFriendRequests() {
    Get.toNamed(
      AppRoutes.friends,
      arguments: {'initialTab': 'requests'},
    );
  }

  Future<void> openBuddyUpdate(FeedDelivery delivery) async {
    if (!delivery.isRead) {
      await _momentRepo.markDeliveryRead(delivery.id);
    }

    Get.toNamed(
      AppRoutes.buddyWall,
      arguments: {
        'ownerId': delivery.ownerId,
        'ownerName': delivery.ownerDisplayName,
        'ownerAvatarUrl': delivery.ownerAvatarUrl,
      },
    );
  }

  String requestSubtitle(FriendRequest request) {
    final message = request.message?.trim();
    if (message != null && message.isNotEmpty) {
      return message;
    }
    return currentL10n.friendRequestIncomingSubtitle;
  }

  String buddySubtitle(FeedDelivery delivery) {
    final activityTitle = delivery.activityTitle?.trim();
    if (activityTitle != null && activityTitle.isNotEmpty) {
      return activityTitle;
    }

    final caption = delivery.caption.trim();
    if (caption.isNotEmpty) {
      return caption;
    }

    final category = delivery.category?.trim();
    if (category != null && category.isNotEmpty) {
      return category;
    }

    return currentL10n.buddyTabSubtitle;
  }

  void _handleAuthUserChanged(User? user) {
    final uid = user?.uid;
    if (_boundUserId == uid) return;

    _boundUserId = uid;
    _cancelDataSubscriptions();
    incomingRequests.clear();
    unreadDeliveries.clear();
    pendingRequestCount.value = 0;
    unreadBuddyCount.value = 0;
    _recomputeTotalUnread();

    if (uid == null) {
      isLoading.value = false;
      return;
    }

    isLoading.value = true;

    _incomingRequestsSubscription = _friendRepo
        .watchIncomingRequests(uid)
        .listen(
          (requests) {
            incomingRequests.assignAll(requests);
            isLoading.value = false;
          },
          onError: (error) {
            debugPrint('[_incomingRequestsSubscription] Error: $error');
            isLoading.value = false;
          },
        );

    _incomingRequestCountSubscription = _friendRepo
        .watchIncomingRequestCount(uid)
        .listen(
          (count) {
            pendingRequestCount.value = count;
            _recomputeTotalUnread();
          },
          onError: (error) {
            debugPrint('[_incomingRequestCountSubscription] Error: $error');
          },
        );

    _deliveriesSubscription = _momentRepo
        .watchFeedDeliveries(uid)
        .listen(
          (deliveries) {
            unreadDeliveries.assignAll(
              deliveries
                  .where((delivery) => !delivery.isRead)
                  .take(10)
                  .toList(),
            );
            isLoading.value = false;
          },
          onError: (error) {
            debugPrint('[_deliveriesSubscription] Error: $error');
            isLoading.value = false;
          },
        );

    _unreadCountSubscription = _momentRepo
        .watchUnreadFeedCount(uid)
        .listen(
          (count) {
            unreadBuddyCount.value = count;
            _recomputeTotalUnread();
          },
          onError: (error) {
            debugPrint('[_unreadCountSubscription] Error: $error');
          },
        );
  }

  void _cancelDataSubscriptions() {
    _incomingRequestsSubscription?.cancel();
    _incomingRequestCountSubscription?.cancel();
    _deliveriesSubscription?.cancel();
    _unreadCountSubscription?.cancel();

    _incomingRequestsSubscription = null;
    _incomingRequestCountSubscription = null;
    _deliveriesSubscription = null;
    _unreadCountSubscription = null;
  }

  void _recomputeTotalUnread() {
    totalUnreadCount.value = pendingRequestCount.value + unreadBuddyCount.value;
  }
}
