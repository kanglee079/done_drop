import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:done_drop/core/theme/theme.dart';
import 'package:done_drop/app/core/widgets/widgets.dart';
import 'package:done_drop/app/routes/app_routes.dart';
import 'package:done_drop/app/presentation/friends/friends_controller.dart';

class FriendsScreen extends StatelessWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FriendsController>(
      init: FriendsController(Get.find()),
      builder: (ctrl) {
        return DefaultTabController(
          length: 2,
          child: Scaffold(
            backgroundColor: AppColors.surface,
            appBar: AppBar(
              backgroundColor: AppColors.surface,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.primary),
                onPressed: () => Get.back(),
              ),
              title: const Text(
                'Buddy Crew',
                style: TextStyle(
                  fontFamily: AppTypography.serifFamily,
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                  color: AppColors.primary,
                ),
              ),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.person_add_alt_1_outlined, color: AppColors.primary),
                  onPressed: () => Get.toNamed(AppRoutes.addFriend),
                ),
              ],
              bottom: TabBar(
                indicatorColor: AppColors.primary,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.onSurfaceVariant,
                labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                tabs: [
                  Obx(() => Tab(
                    text: ctrl.isAtFriendCap
                        ? 'Crew (${ctrl.friendCount.value}/${ctrl.maxFriends})'
                        : 'Crew',
                  )),
                  Obx(() => Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Requests'),
                        if (ctrl.hasPendingRequests) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${ctrl.pendingRequestCount.value}',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ],
                    ),
                  )),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                Obx(() => _FriendsList(ctrl: ctrl)),
                Obx(() => _RequestsList(ctrl: ctrl)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FriendsList extends StatelessWidget {
  const _FriendsList({required this.ctrl});
  final FriendsController ctrl;

  @override
  Widget build(BuildContext context) {
    if (ctrl.friendships.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.group_outlined, size: 56, color: AppColors.outlineVariant),
            const SizedBox(height: AppSizes.space16),
            Text(
              'No friends yet',
              style: TextStyle(
                fontFamily: AppTypography.serifFamily,
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: AppSizes.space8),
            Text(
              'Add some buddies to keep you accountable.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: AppSizes.space24),
            DDSecondaryButton(
              label: 'Add Friend',
              icon: Icons.person_add_alt_1_outlined,
              onPressed: () => Get.toNamed(AppRoutes.addFriend),
              isExpanded: false,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.space16),
      itemCount: ctrl.friendships.length,
      itemBuilder: (context, i) {
        final friendship = ctrl.friendships[i];
        final currentUid = ctrl.currentUserId ?? '';
        final friendId = friendship.otherUserId(currentUid);

        return _FriendTile(
          friendId: friendId,
          onRemove: () async {
            final confirmed = await Get.dialog<bool>(
              AlertDialog(
                title: const Text('Remove Friend'),
                content: const Text('Remove this friend?'),
                actions: [
                  TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
                  TextButton(
                    onPressed: () => Get.back(result: true),
                    child: Text('Remove', style: TextStyle(color: AppColors.error)),
                  ),
                ],
              ),
            );
            if (confirmed == true) ctrl.removeFriend(friendship);
          },
        );
      },
    );
  }
}

class _RequestsList extends StatelessWidget {
  const _RequestsList({required this.ctrl});
  final FriendsController ctrl;

  @override
  Widget build(BuildContext context) {
    final hasIncoming = ctrl.incomingRequests.isNotEmpty;
    final hasOutgoing = ctrl.outgoingRequests.isNotEmpty;

    if (!hasIncoming && !hasOutgoing) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 56, color: AppColors.outlineVariant),
            const SizedBox(height: AppSizes.space16),
            Text(
              'No pending requests',
              style: TextStyle(
                fontFamily: AppTypography.serifFamily,
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: AppSizes.space8),
            Text(
              'Incoming and outgoing requests appear here.',
              style: TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(AppSizes.space16),
      children: [
        if (hasIncoming) ...[
          _SectionLabel('INCOMING'),
          ...ctrl.incomingRequests.map((req) => _RequestTile(
            name: req.senderDisplayName ?? 'User',
            avatarUrl: req.senderAvatarUrl,
            isIncoming: true,
            onAccept: () => ctrl.acceptRequest(req),
            onDecline: () => ctrl.declineRequest(req),
          )),
        ],
        if (hasOutgoing) ...[
          const SizedBox(height: AppSizes.space16),
          _SectionLabel('SENT'),
          ...ctrl.outgoingRequests.map((req) => _RequestTile(
            name: req.receiverId,
            avatarUrl: null,
            isIncoming: false,
            onCancel: () => ctrl.cancelRequest(req),
          )),
        ],
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.space8),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.outline,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

class _FriendTile extends StatelessWidget {
  const _FriendTile({required this.friendId, required this.onRemove});

  final String friendId;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<FriendsController>();

    return FutureBuilder(
      future: ctrl.friendRepo.getFriendProfile(friendId),
      builder: (context, snapshot) {
        final profile = snapshot.data;
        final name = profile?.displayName ?? 'Friend';
        final avatarUrl = profile?.avatarUrl;

        return Container(
          margin: const EdgeInsets.only(bottom: AppSizes.space8),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: AppSizes.space16, vertical: AppSizes.space4),
            shape: RoundedRectangleBorder(borderRadius: AppSizes.borderRadiusMd),
            tileColor: AppColors.surfaceContainerLow,
            leading: CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.primaryFixed,
              backgroundImage:
                  avatarUrl != null ? NetworkImage(avatarUrl) : null,
              child: avatarUrl == null
                  ? Icon(Icons.person, color: AppColors.primary, size: 20)
                  : null,
            ),
            title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
            trailing: IconButton(
              icon: Icon(Icons.remove_circle_outline, color: AppColors.error, size: 20),
              onPressed: onRemove,
            ),
          ),
        );
      },
    );
  }
}

class _RequestTile extends StatelessWidget {
  const _RequestTile({
    required this.name,
    required this.avatarUrl,
    required this.isIncoming,
    this.onAccept,
    this.onDecline,
    this.onCancel,
  });

  final String name;
  final String? avatarUrl;
  final bool isIncoming;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.space8),
      padding: const EdgeInsets.all(AppSizes.space16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: AppSizes.borderRadiusMd,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primaryFixed,
            backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
            child: avatarUrl == null
                ? Icon(Icons.person, color: AppColors.primary, size: 20)
                : null,
          ),
          const SizedBox(width: AppSizes.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(
                  isIncoming ? 'Wants to be your friend' : 'Friend request sent',
                  style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          if (isIncoming) ...[
            IconButton(icon: Icon(Icons.check_circle, color: AppColors.primary), onPressed: onAccept),
            IconButton(icon: Icon(Icons.cancel, color: AppColors.error), onPressed: onDecline),
          ] else
            IconButton(icon: Icon(Icons.cancel_outlined, color: AppColors.outline), onPressed: onCancel),
        ],
      ),
    );
  }
}
