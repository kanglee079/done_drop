import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:done_drop/app/core/widgets/widgets.dart';
import 'package:done_drop/app/routes/app_routes.dart';
import 'package:done_drop/app/presentation/friends/add_friend_controller.dart';
import 'package:done_drop/core/theme/theme.dart';
import 'package:done_drop/l10n/l10n.dart';

class AddFriendScreen extends GetView<AddFriendController> {
  const AddFriendScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return DismissKeyboard(
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
          title: Text(l10n.addBuddyTitle),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.qr_code_rounded, color: AppColors.primary),
              onPressed: () => Get.toNamed(AppRoutes.scanCode),
              tooltip: l10n.scanAction,
            ),
          ],
        ),
        body: DDResponsiveScrollBody(
          maxWidth: 560,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.space20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSizes.space4),
                _HeaderCard(l10n: l10n),
                const SizedBox(height: AppSizes.space16),
                Obx(
                  () => controller.isAtCap.value
                      ? _FriendCapBanner(limit: controller.maxFriends)
                      : const SizedBox.shrink(),
                ),
                _QuickActionRow(l10n: l10n),
                const SizedBox(height: AppSizes.space24),
                _DividerLabel(label: l10n.addByIdTitle),
                const SizedBox(height: AppSizes.space24),
                _SearchSection(controller: controller),
                const SizedBox(height: AppSizes.space24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.l10n});

  final dynamic l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.space20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryFixed, AppColors.surfaceContainerLowest],
        ),
        borderRadius: AppSizes.borderRadiusXl,
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.selectAddMethod.toUpperCase(),
                  style: AppTypography.labelSmall(
                    color: AppColors.primary.withValues(alpha: 0.72),
                  ).copyWith(letterSpacing: 1.2),
                ),
                const SizedBox(height: AppSizes.space8),
                Text(
                  l10n.addByIdSubtitle,
                  style: AppTypography.bodyMedium(color: AppColors.onSurface),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.space16),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.group_add_rounded,
              color: AppColors.primary,
              size: 26,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionRow extends StatelessWidget {
  const _QuickActionRow({required this.l10n});

  final dynamic l10n;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stackCards = constraints.maxWidth < 430;
        final scanCard = _ActionCard(
          icon: Icons.qr_code_scanner_rounded,
          title: l10n.scanAction,
          subtitle: l10n.scanCodeSubtitle,
          onTap: () => Get.toNamed(AppRoutes.scanCode),
        );
        final myCodeCard = _ActionCard(
          icon: Icons.qr_code_2_rounded,
          title: l10n.shareCodeAction,
          subtitle: l10n.myCodeSubtitle,
          onTap: () => Get.toNamed(AppRoutes.myCode),
        );

        if (stackCards) {
          return Column(
            children: [
              scanCard,
              const SizedBox(height: AppSizes.space12),
              myCodeCard,
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: scanCard),
            const SizedBox(width: AppSizes.space12),
            Expanded(child: myCodeCard),
          ],
        );
      },
    );
  }
}

class _DividerLabel extends StatelessWidget {
  const _DividerLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: AppColors.outlineVariant)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.space16),
          child: Text(
            '— ${label.toUpperCase()} —',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.outline,
              letterSpacing: 1.5,
            ),
          ),
        ),
        Expanded(child: Divider(color: AppColors.outlineVariant)),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.space16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: AppSizes.borderRadiusLg,
          boxShadow: AppColors.cardShadow,
          border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primaryFixed,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: AppSizes.space14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.outline,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchSection extends StatefulWidget {
  const _SearchSection({required this.controller});

  final AddFriendController controller;

  @override
  State<_SearchSection> createState() => _SearchSectionState();
}

class _SearchSectionState extends State<_SearchSection>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey _feedbackAnchorKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) return;
    setState(() {});
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    final query = widget.controller.searchController.text.trim();
    if (query.isEmpty) return;
    FocusManager.instance.primaryFocus?.unfocus();
    if (_tabController.index == 0) {
      await widget.controller.searchByCode(query);
    } else {
      await widget.controller.searchByEmail();
    }
    _scrollToFeedback();
  }

  Future<void> _sendRequest() async {
    FocusManager.instance.primaryFocus?.unfocus();
    await widget.controller.sendRequest();
    _scrollToFeedback();
  }

  void _scrollToFeedback() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final feedbackContext = _feedbackAnchorKey.currentContext;
      if (!mounted || feedbackContext == null) return;
      Scrollable.ensureVisible(
        feedbackContext,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        alignment: 0.0,
        alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Obx(() {
      final isSearching = widget.controller.isSearching.value;
      final isSendingRequest = widget.controller.isSendingRequest.value;
      final isAtCap = widget.controller.isAtCap.value;
      final errorMessage = widget.controller.errorMessage.value;
      final user = widget.controller.foundUser.value;
      final requestSent = widget.controller.requestSent.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHighest,
              borderRadius: AppSizes.borderRadiusMd,
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.onSurfaceVariant,
              dividerColor: Colors.transparent,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.tag_rounded, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        l10n.userIdLabel,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.email_outlined, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        l10n.emailLabel,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.space16),
          LayoutBuilder(
            builder: (context, constraints) {
              final stackAction = constraints.maxWidth < 420;
              final searchField = DDTextField(
                controller: widget.controller.searchController,
                label: '',
                hint: _tabController.index == 0
                    ? l10n.userIdHint
                    : l10n.emailHint,
                prefixIcon: _tabController.index == 0
                    ? Icons.tag_rounded
                    : Icons.email_outlined,
                keyboardType: _tabController.index == 0
                    ? TextInputType.text
                    : TextInputType.emailAddress,
                textInputAction: TextInputAction.search,
                autocorrect: false,
                enableSuggestions: false,
                textCapitalization: _tabController.index == 0
                    ? TextCapitalization.characters
                    : TextCapitalization.none,
                onFieldSubmitted: (_) => _performSearch(),
                enabled: !isSearching && !isSendingRequest && !isAtCap,
              );
              final searchButton = SizedBox(
                width: stackAction ? double.infinity : 136,
                child: DDPrimaryButton(
                  label: l10n.searchAction,
                  icon: Icons.search_rounded,
                  isLoading: isSearching,
                  onPressed: (isSearching || isSendingRequest || isAtCap)
                      ? null
                      : _performSearch,
                ),
              );

              if (stackAction) {
                return Column(
                  children: [
                    searchField,
                    const SizedBox(height: AppSizes.space12),
                    searchButton,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: searchField),
                  const SizedBox(width: AppSizes.space12),
                  searchButton,
                ],
              );
            },
          ),
          SizedBox(key: _feedbackAnchorKey),
          if (errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: AppSizes.space12),
              child: _ErrorBanner(message: errorMessage),
            ),
          const SizedBox(height: AppSizes.space20),
          if (user != null)
            requestSent
                ? _RequestSentCard(
                    name: user.displayName,
                    onReset: widget.controller.reset,
                  )
                : _FoundUserCard(
                    name: user.displayName,
                    avatarUrl: user.avatarUrl,
                    onSendRequest: _sendRequest,
                    isLoading: isSendingRequest,
                  ),
        ],
      );
    });
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.space12),
      decoration: BoxDecoration(
        color: AppColors.errorContainer,
        borderRadius: AppSizes.borderRadiusMd,
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.error, size: 18),
          const SizedBox(width: AppSizes.space8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: AppColors.onErrorContainer, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _FriendCapBanner extends StatelessWidget {
  const _FriendCapBanner({required this.limit});

  final int limit;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.space16),
      padding: const EdgeInsets.all(AppSizes.space16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: AppSizes.borderRadiusMd,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.group_outlined, color: AppColors.primary),
          const SizedBox(width: AppSizes.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.buddyLimitReachedTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  l10n.buddyLimitReachedSubtitle(limit),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FoundUserCard extends StatelessWidget {
  const _FoundUserCard({
    required this.name,
    required this.avatarUrl,
    required this.onSendRequest,
    required this.isLoading,
  });

  final String name;
  final String? avatarUrl;
  final VoidCallback onSendRequest;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(AppSizes.space20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: AppSizes.borderRadiusLg,
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: AppColors.primaryFixed,
            backgroundImage: avatarUrl != null
                ? NetworkImage(avatarUrl!)
                : null,
            child: avatarUrl == null
                ? Icon(Icons.person, color: AppColors.primary, size: 32)
                : null,
          ),
          const SizedBox(height: AppSizes.space12),
          Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.sendBuddyRequestPrompt,
            style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: AppSizes.space16),
          DDPrimaryButton(
            label: l10n.sendBuddyRequestAction,
            icon: Icons.person_add_rounded,
            isLoading: isLoading,
            onPressed: isLoading ? null : onSendRequest,
            isExpanded: true,
          ),
        ],
      ),
    );
  }
}

class _RequestSentCard extends StatelessWidget {
  const _RequestSentCard({required this.name, required this.onReset});

  final String name;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(AppSizes.space24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: AppSizes.borderRadiusLg,
      ),
      child: Column(
        children: [
          Icon(Icons.check_circle, color: AppColors.primary, size: 56),
          const SizedBox(height: AppSizes.space16),
          Text(
            l10n.requestSentSuccessTitle,
            style: TextStyle(
              fontFamily: AppTypography.serifFamily,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.requestSentSuccessMessage(name),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: AppSizes.space16),
          DDSecondaryButton(
            label: l10n.addAnotherBuddyAction,
            icon: Icons.add_rounded,
            onPressed: onReset,
            isExpanded: true,
          ),
        ],
      ),
    );
  }
}
