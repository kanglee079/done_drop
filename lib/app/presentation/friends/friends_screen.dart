import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:done_drop/core/theme/theme.dart';
import 'package:done_drop/app/core/widgets/widgets.dart';
import 'package:done_drop/app/routes/app_routes.dart';
import 'package:done_drop/app/presentation/friends/friends_controller.dart';
import 'package:done_drop/l10n/l10n.dart';

class FriendsScreen extends StatelessWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spec = DDResponsiveSpec.of(context);
    return GetBuilder<FriendsController>(
      init: FriendsController(Get.find()),
      builder: (ctrl) {
        return DismissKeyboard(
          child: DefaultTabController(
            length: 2,
            child: Scaffold(
              backgroundColor: AppColors.surface,
              appBar: AppBar(
                backgroundColor: AppColors.surface,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                leadingWidth: 64,
                leading: Padding(
                  padding: const EdgeInsets.only(left: AppSizes.space8),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: AppColors.primary,
                    ),
                    onPressed: () => Get.back(),
                  ),
                ),
                titleSpacing: 0,
                title: Text(
                  l10n.buddyCrewTitle,
                  style: TextStyle(
                    fontFamily: AppTypography.serifFamily,
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                    color: AppColors.primary,
                  ),
                ),
                centerTitle: true,
                actions: [
                  SizedBox(
                    width: 64,
                    child: Padding(
                      padding: const EdgeInsets.only(right: AppSizes.space8),
                      child: IconButton(
                        icon: const Icon(
                          Icons.person_add_alt_1_rounded,
                          color: AppColors.primary,
                        ),
                        onPressed: () => Get.toNamed(AppRoutes.addFriend),
                      ),
                    ),
                  ),
                ],
                bottom: TabBar(
                  isScrollable: false,
                  indicatorColor: AppColors.primary,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.onSurfaceVariant,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                  tabs: [
                    Obx(
                      () => Tab(
                        text: ctrl.isAtFriendCap
                            ? l10n.crewTabCountLabel(
                                ctrl.friendCount.value,
                                ctrl.maxFriends,
                              )
                            : l10n.crewTabLabel,
                      ),
                    ),
                    Obx(
                      () => Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(l10n.requestsTabLabel),
                            if (ctrl.hasPendingRequests) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${ctrl.pendingRequestCount.value}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              body: DDResponsiveCenter(
                maxWidth: 760,
                child: TabBarView(
                  children: [
                    _FriendsList(ctrl: ctrl, spec: spec),
                    _RequestsList(ctrl: ctrl),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FriendsList extends StatelessWidget {
  const _FriendsList({required this.ctrl, required this.spec});
  final FriendsController ctrl;
  final DDResponsiveSpec spec;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Obx(() {
      if (ctrl.friendships.isEmpty) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = spec.horizontalPadding
                .clamp(20.0, 28.0)
                .toDouble();
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                AppSizes.space24,
                horizontalPadding,
                AppSizes.space24,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - AppSizes.space48,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSizes.space24),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: AppSizes.borderRadiusLg,
                        boxShadow: AppColors.cardShadow,
                        border: Border.all(color: AppColors.outlineVariant),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.group_outlined,
                            size: 56,
                            color: AppColors.outlineVariant,
                          ),
                          const SizedBox(height: AppSizes.space16),
                          Text(
                            l10n.noFriendsYetTitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: AppTypography.serifFamily,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(height: AppSizes.space8),
                          Text(
                            l10n.noFriendsYetSubtitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: AppSizes.space24),
                          SizedBox(
                            width: double.infinity,
                            child: DDSecondaryButton(
                              label: l10n.addFriendAction,
                              icon: Icons.person_add_alt_1_outlined,
                              onPressed: () => Get.toNamed(AppRoutes.addFriend),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }

      return ListView.builder(
        padding: EdgeInsets.fromLTRB(
          spec.horizontalPadding,
          AppSizes.space16,
          spec.horizontalPadding,
          AppSizes.space24,
        ),
        itemCount: ctrl.friendships.length,
        itemBuilder: (context, i) {
          final friendship = ctrl.friendships[i];
          final currentUid = ctrl.currentUserId ?? '';
          final friendId = friendship.otherUserId(currentUid);

          return _FriendTile(
            friendId: friendId,
          );
        },
      );
    });
  }
}

class _RequestsList extends StatelessWidget {
  const _RequestsList({required this.ctrl});
  final FriendsController ctrl;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Obx(() {
      final hasIncoming = ctrl.incomingRequests.isNotEmpty;
      final hasOutgoing = ctrl.outgoingRequests.isNotEmpty;

      if (!hasIncoming && !hasOutgoing) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 56,
                color: AppColors.outlineVariant,
              ),
              const SizedBox(height: AppSizes.space16),
              Text(
                l10n.noPendingRequestsTitle,
                style: TextStyle(
                  fontFamily: AppTypography.serifFamily,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: AppSizes.space8),
              Text(
                l10n.noPendingRequestsSubtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
      }

      return ListView(
        padding: const EdgeInsets.all(AppSizes.space16),
        children: [
          if (hasIncoming) ...[
            _SectionLabel(l10n.incomingSectionLabel),
            ...ctrl.incomingRequests.map(
              (req) => _RequestTile(
                name: req.senderDisplayName ?? l10n.memberFallbackName,
                avatarUrl: req.senderAvatarUrl,
                isIncoming: true,
                onAccept: () => ctrl.acceptRequest(req),
                onDecline: () => ctrl.declineRequest(req),
              ),
            ),
          ],
          if (hasOutgoing) ...[
            const SizedBox(height: AppSizes.space16),
            _SectionLabel(l10n.sentSectionLabel),
            ...ctrl.outgoingRequests.map(
              (req) => _RequestTile(
                name: req.receiverId,
                avatarUrl: null,
                isIncoming: false,
                onCancel: () => ctrl.cancelRequest(req),
              ),
            ),
          ],
        ],
      );
    });
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
  const _FriendTile({required this.friendId});

  final String friendId;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Get.find<FriendsController>().friendRepo.getFriendProfile(friendId),
      builder: (context, snapshot) {
        final profile = snapshot.data;
        final name = profile?.displayName ?? context.l10n.memberFallbackName;
        final avatarUrl = profile?.avatarUrl;

        return Container(
          margin: const EdgeInsets.only(bottom: AppSizes.space8),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSizes.space16,
              vertical: AppSizes.space4,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: AppSizes.borderRadiusMd,
            ),
            tileColor: AppColors.surfaceContainerLow,
            leading: CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.primaryFixed,
              backgroundImage: avatarUrl != null
                  ? NetworkImage(avatarUrl)
                  : null,
              child: avatarUrl == null
                  ? Icon(Icons.person, color: AppColors.primary, size: 20)
                  : null,
            ),
            title: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  onPressed: () => Get.toNamed(
                    AppRoutes.chat,
                    arguments: {
                      'buddyId': friendId,
                      'buddyName': name,
                      'buddyAvatarUrl': avatarUrl,
                    },
                  ),
                  tooltip: context.l10n.chatOpenAction,
                ),
                IconButton(
                  icon: Icon(
                    Icons.photo_library_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  onPressed: () => Get.toNamed(
                    AppRoutes.buddyWall,
                    arguments: {
                      'ownerId': friendId,
                      'ownerName': name,
                      'ownerAvatarUrl': avatarUrl,
                    },
                  ),
                  tooltip: context.l10n.buddyViewWallAction,
                ),
                PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value != 'remove') return;
                    final l10n = context.l10n;
                    final confirmed = await Get.dialog<bool>(
                      AlertDialog(
                        title: Text(l10n.removeFriendTitle),
                        content: Text(l10n.removeFriendMessage),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(result: false),
                            child: Text(l10n.cancelAction),
                          ),
                          TextButton(
                            onPressed: () => Get.back(result: true),
                            child: Text(
                              l10n.removeAction,
                              style: TextStyle(color: AppColors.error),
                            ),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      final ctrl = Get.find<FriendsController>();
                      final friendship = ctrl.friendships.firstWhere(
                        (f) => f.otherUserId(ctrl.currentUserId ?? '') == friendId,
                      );
                      ctrl.removeFriend(friendship);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem<String>(
                      value: 'remove',
                      child: Text(context.l10n.removeAction),
                    ),
                  ],
                  icon: const Icon(
                    Icons.more_horiz_rounded,
                    color: AppColors.onSurfaceVariant,
                    size: 20,
                  ),
                ),
              ],
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
    final l10n = context.l10n;
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
            backgroundImage: avatarUrl != null
                ? NetworkImage(avatarUrl!)
                : null,
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
                  isIncoming
                      ? l10n.friendRequestIncomingSubtitle
                      : l10n.friendRequestSentSubtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (isIncoming) ...[
            IconButton(
              icon: Icon(Icons.check_circle, color: AppColors.primary),
              onPressed: onAccept,
            ),
            IconButton(
              icon: Icon(Icons.cancel, color: AppColors.error),
              onPressed: onDecline,
            ),
          ] else
            IconButton(
              icon: Icon(Icons.cancel_outlined, color: AppColors.outline),
              onPressed: onCancel,
            ),
        ],
      ),
    );
  }
}
