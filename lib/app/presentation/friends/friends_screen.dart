import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:done_drop/app/core/widgets/widgets.dart';
import 'package:done_drop/app/presentation/friends/friends_controller.dart';
import 'package:done_drop/app/routes/app_routes.dart';
import 'package:done_drop/core/models/friend_request.dart';
import 'package:done_drop/core/models/friendship.dart';
import 'package:done_drop/core/models/user_profile.dart';
import 'package:done_drop/core/theme/theme.dart';
import 'package:done_drop/l10n/l10n.dart';

class FriendsScreen extends GetView<FriendsController> {
  const FriendsScreen({super.key});

  int _resolveInitialTabIndex() {
    final args = Get.arguments;
    if (args is int) {
      return args.clamp(0, 1);
    }
    if (args is Map<String, dynamic>) {
      final initialTab = args['initialTab'];
      if (initialTab is int) {
        return initialTab.clamp(0, 1);
      }
      if (initialTab is String && initialTab.toLowerCase() == 'requests') {
        return 1;
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spec = DDResponsiveSpec.of(context);
    final initialTabIndex = _resolveInitialTabIndex();

    return DismissKeyboard(
      child: DefaultTabController(
        length: 2,
        initialIndex: initialTabIndex,
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
                    text: controller.isAtFriendCap
                        ? l10n.crewTabCountLabel(
                            controller.friendCount.value,
                            controller.maxFriends,
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
                        if (controller.hasPendingRequests) ...[
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
                              '${controller.pendingRequestCount.value}',
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
                _FriendsList(controller: controller, spec: spec),
                _RequestsList(controller: controller, spec: spec),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FriendsList extends StatelessWidget {
  const _FriendsList({required this.controller, required this.spec});

  final FriendsController controller;
  final DDResponsiveSpec spec;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Obx(() {
      if (controller.friendships.isEmpty) {
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
        itemCount: controller.friendships.length,
        itemBuilder: (context, index) {
          final friendship = controller.friendships[index];
          final currentUid = controller.currentUserId ?? '';
          final friendId = friendship.otherUserId(currentUid);

          return _FriendTile(
            controller: controller,
            friendship: friendship,
            friendId: friendId,
          );
        },
      );
    });
  }
}

class _RequestsList extends StatelessWidget {
  const _RequestsList({required this.controller, required this.spec});

  final FriendsController controller;
  final DDResponsiveSpec spec;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Obx(() {
      final hasIncoming = controller.incomingRequests.isNotEmpty;
      final hasOutgoing = controller.outgoingRequests.isNotEmpty;

      if (!hasIncoming && !hasOutgoing) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.space24),
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
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return ListView(
        padding: EdgeInsets.fromLTRB(
          spec.horizontalPadding,
          AppSizes.space16,
          spec.horizontalPadding,
          AppSizes.space24,
        ),
        children: [
          if (hasIncoming) ...[
            _SectionLabel(l10n.incomingSectionLabel),
            ...controller.incomingRequests.map(
              (request) => _RequestTile(
                controller: controller,
                request: request,
                isIncoming: true,
              ),
            ),
          ],
          if (hasOutgoing) ...[
            const SizedBox(height: AppSizes.space16),
            _SectionLabel(l10n.sentSectionLabel),
            ...controller.outgoingRequests.map(
              (request) => _RequestTile(
                controller: controller,
                request: request,
                isIncoming: false,
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
  const _FriendTile({
    required this.controller,
    required this.friendship,
    required this.friendId,
  });

  final FriendsController controller;
  final Friendship friendship;
  final String friendId;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserProfile?>(
      future: controller.profileFutureFor(friendId),
      builder: (context, snapshot) {
        final profile = snapshot.data;
        final name = profile?.displayName ?? context.l10n.memberFallbackName;
        final avatarUrl = profile?.avatarUrl;
        final userCode = profile?.userCode?.trim() ?? '';

        return _ProfileCard(
          name: name,
          avatarUrl: avatarUrl,
          subtitle: userCode.isEmpty
              ? context.l10n.crewTabLabel
              : '${context.l10n.userIdLabel}: ${userCode.toUpperCase()}',
          trailing: PopupMenuButton<String>(
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
                controller.removeFriend(friendship);
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
          footer: Wrap(
            spacing: AppSizes.space8,
            runSpacing: AppSizes.space8,
            children: [
              _ActionPill(
                icon: Icons.chat_bubble_outline_rounded,
                label: context.l10n.chatOpenAction,
                onTap: () => Get.toNamed(
                  AppRoutes.chat,
                  arguments: {
                    'buddyId': friendId,
                    'buddyName': name,
                    'buddyAvatarUrl': avatarUrl,
                  },
                ),
              ),
              _ActionPill(
                icon: Icons.photo_library_outlined,
                label: context.l10n.buddyViewWallAction,
                onTap: () => Get.toNamed(
                  AppRoutes.buddyWall,
                  arguments: {
                    'ownerId': friendId,
                    'ownerName': name,
                    'ownerAvatarUrl': avatarUrl,
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RequestTile extends StatelessWidget {
  const _RequestTile({
    required this.controller,
    required this.request,
    required this.isIncoming,
  });

  final FriendsController controller;
  final FriendRequest request;
  final bool isIncoming;

  @override
  Widget build(BuildContext context) {
    final otherUserId = isIncoming ? request.senderId : request.receiverId;

    return FutureBuilder<UserProfile?>(
      future: controller.requestProfileFutureFor(otherUserId),
      builder: (context, snapshot) {
        final profile = snapshot.data;
        final l10n = context.l10n;
        final requestDisplayName = request.senderDisplayName?.trim();
        final fallbackName = isIncoming
            ? (requestDisplayName != null && requestDisplayName.isNotEmpty
                  ? requestDisplayName
                  : l10n.memberFallbackName)
            : request.receiverId;
        final name = profile?.displayName ?? fallbackName;
        final avatarUrl = profile?.avatarUrl ?? request.senderAvatarUrl;
        final userCode = profile?.userCode?.trim() ?? '';
        final isBusy = controller.isRequestBusy(request.id);

        return _ProfileCard(
          name: name,
          avatarUrl: avatarUrl,
          subtitle: isIncoming
              ? l10n.friendRequestIncomingSubtitle
              : l10n.friendRequestSentSubtitle,
          meta: userCode.isEmpty
              ? null
              : _MetaPill(label: userCode.toUpperCase()),
          footer: Wrap(
            spacing: AppSizes.space8,
            runSpacing: AppSizes.space8,
            children: [
              if (isIncoming && controller.isAccepting(request.id))
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSizes.space12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryFixed,
                    borderRadius: AppSizes.borderRadiusMd,
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.14),
                    ),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: AppSizes.space10),
                      Expanded(
                        child: Text(
                          l10n.acceptingBuddyRequestStatus,
                          style: AppTypography.labelLarge(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else if (isIncoming) ...[
                _ActionPill(
                  icon: Icons.check_rounded,
                  label: l10n.addFriendAction,
                  isPrimary: true,
                  isLoading: controller.isAccepting(request.id),
                  isDisabled: isBusy,
                  onTap: () async {
                    final tabController = DefaultTabController.maybeOf(context);
                    final accepted = await controller.acceptRequest(request);
                    if (!accepted) return;
                    tabController?.animateTo(0);
                  },
                ),
                _ActionPill(
                  icon: Icons.close_rounded,
                  label: l10n.declineRequestTitle,
                  isDestructive: true,
                  isLoading: controller.isDeclining(request.id),
                  isDisabled: isBusy,
                  onTap: () => controller.declineRequest(request),
                ),
              ] else
                _ActionPill(
                  icon: Icons.close_rounded,
                  label: l10n.cancelAction,
                  isLoading: controller.isCancelling(request.id),
                  isDisabled: isBusy,
                  onTap: () => controller.cancelRequest(request),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.name,
    required this.avatarUrl,
    required this.subtitle,
    required this.footer,
    this.trailing,
    this.meta,
  });

  final String name;
  final String? avatarUrl;
  final String subtitle;
  final Widget footer;
  final Widget? trailing;
  final Widget? meta;

  @override
  Widget build(BuildContext context) {
    final metaWidgets = <Widget>[
      Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
      ),
    ];
    if (meta != null) {
      metaWidgets.add(meta!);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.space10),
      padding: const EdgeInsets.all(AppSizes.space16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppSizes.borderRadiusLg,
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProfileAvatar(name: name, avatarUrl: avatarUrl),
              const SizedBox(width: AppSizes.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppSizes.space4),
                    Wrap(
                      spacing: AppSizes.space8,
                      runSpacing: AppSizes.space8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: metaWidgets,
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: AppSizes.space8),
                trailing!,
              ],
            ],
          ),
          const SizedBox(height: AppSizes.space14),
          footer,
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.name, required this.avatarUrl});

  final String name;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final safeName = name.trim();
    final fallback = safeName.isEmpty ? '?' : safeName[0].toUpperCase();

    return CircleAvatar(
      radius: 24,
      backgroundColor: AppColors.primaryFixed,
      backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
      child: avatarUrl == null
          ? Text(
              fallback,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            )
          : null,
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.space8,
        vertical: AppSizes.space4,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryFixed,
        borderRadius: AppSizes.borderRadiusFull,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _ActionPill extends StatelessWidget {
  const _ActionPill({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isPrimary = false,
    this.isDestructive = false,
    this.isLoading = false,
    this.isDisabled = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;
  final bool isDestructive;
  final bool isLoading;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isPrimary
        ? AppColors.primary
        : isDestructive
        ? AppColors.error.withValues(alpha: 0.08)
        : AppColors.surfaceContainerLow;
    final foregroundColor = isPrimary
        ? AppColors.onPrimary
        : isDestructive
        ? AppColors.error
        : AppColors.onSurface;
    final borderColor = isPrimary
        ? AppColors.primary
        : isDestructive
        ? AppColors.error.withValues(alpha: 0.18)
        : AppColors.outlineVariant;
    final disabled = isDisabled || isLoading;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: disabled ? null : onTap,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.space12,
            vertical: AppSizes.space10,
          ),
          decoration: BoxDecoration(
            color: disabled
                ? backgroundColor.withValues(alpha: 0.55)
                : backgroundColor,
            borderRadius: AppSizes.borderRadiusFull,
            border: Border.all(
              color: disabled
                  ? borderColor.withValues(alpha: 0.55)
                  : borderColor,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading)
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
                  ),
                )
              else
                Icon(
                  icon,
                  size: 16,
                  color: disabled
                      ? foregroundColor.withValues(alpha: 0.7)
                      : foregroundColor,
                ),
              const SizedBox(width: AppSizes.space6),
              Text(
                label,
                style: TextStyle(
                  color: disabled
                      ? foregroundColor.withValues(alpha: 0.7)
                      : foregroundColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
