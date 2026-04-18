import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:done_drop/app/core/widgets/widgets.dart';
import 'package:done_drop/app/routes/app_routes.dart';
import 'package:done_drop/app/presentation/friends/add_friend_controller.dart';
import 'package:done_drop/core/theme/theme.dart';
import 'package:done_drop/l10n/l10n.dart';

class AddFriendScreen extends StatelessWidget {
  const AddFriendScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return GetBuilder<AddFriendController>(
      init: AddFriendController(Get.find()),
      builder: (ctrl) {
        final spec = DDResponsiveSpec.of(context);

        // Handle prefill code from QR scan
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final args = Get.arguments as Map<String, dynamic>?;
          final prefillCode = args?['prefillCode'] as String?;
          if (prefillCode != null && prefillCode.isNotEmpty) {
            ctrl.searchController.text = prefillCode;
            ctrl.searchByCode(prefillCode);
          }
        });

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Friend cap indicator
                  Obx(
                    () => ctrl.isAtCap.value
                        ? _FriendCapBanner(limit: ctrl.maxFriends)
                        : const SizedBox.shrink(),
                  ),

                  // Action cards (QR & My Code)
                  Row(
                    children: [
                      Expanded(
                        child: _ActionCard(
                          icon: Icons.qr_code_scanner_rounded,
                          title: l10n.scanAction,
                          subtitle: l10n.scanCodeSubtitle,
                          onTap: () => Get.toNamed(AppRoutes.scanCode),
                        ),
                      ),
                      const SizedBox(width: AppSizes.space12),
                      Expanded(
                        child: _ActionCard(
                          icon: Icons.qr_code_2_rounded,
                          title: l10n.shareCodeAction,
                          subtitle: l10n.myCodeSubtitle,
                          onTap: () => Get.toNamed(AppRoutes.myCode),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.space24),

                  // Divider with "or"
                  Row(
                    children: [
                      Expanded(child: Divider(color: AppColors.outlineVariant)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSizes.space16),
                        child: Text(
                          '— ${l10n.addByIdTitle.toUpperCase()} —',
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
                  ),
                  const SizedBox(height: AppSizes.space24),

                  // Search field with tabs
                  _SearchSection(controller: ctrl, spec: spec),
                ],
              ),
            ),
          ),
        );
      },
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
          color: AppColors.surfaceContainerLow,
          borderRadius: AppSizes.borderRadiusLg,
          border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: Column(
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
            const SizedBox(height: AppSizes.space10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: AppSizes.space4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchSection extends StatefulWidget {
  const _SearchSection({required this.controller, required this.spec});

  final AddFriendController controller;
  final DDResponsiveSpec spec;

  @override
  State<_SearchSection> createState() => _SearchSectionState();
}

class _SearchSectionState extends State<_SearchSection>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _performSearch() {
    final query = widget.controller.searchController.text.trim();
    if (query.isEmpty) return;
    if (_tabController.index == 0) {
      widget.controller.searchByCode(query);
    } else {
      widget.controller.searchByEmail();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Tab bar
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
                    Text(l10n.userIdLabel, style: const TextStyle(fontSize: 13)),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.email_outlined, size: 16),
                    const SizedBox(width: 6),
                    Text(l10n.emailLabel, style: const TextStyle(fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.space16),

        // Search field
        Row(
          children: [
            Expanded(
              child: Obx(
                () => DDTextField(
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
                  onFieldSubmitted: (_) => _performSearch(),
                  enabled: !widget.controller.isSearching.value &&
                      !widget.controller.isAtCap.value,
                ),
              ),
            ),
            const SizedBox(width: AppSizes.space12),
            Obx(
              () => SizedBox(
                width: 120,
                child: DDPrimaryButton(
                  label: l10n.findByIdAction,
                  icon: Icons.search_rounded,
                  isLoading: widget.controller.isSearching.value,
                  onPressed: (widget.controller.isSearching.value ||
                          widget.controller.isAtCap.value)
                      ? null
                      : _performSearch,
                ),
              ),
            ),
          ],
        ),

        // Error
        Obx(() {
          final msg = widget.controller.errorMessage.value;
          if (msg == null) return const SizedBox(height: 0);
          return Padding(
            padding: const EdgeInsets.only(top: AppSizes.space12),
            child: Container(
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
                      msg,
                      style: TextStyle(
                        color: AppColors.onErrorContainer,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),

        const SizedBox(height: AppSizes.space24),

        // Found user
        Obx(() {
          final user = widget.controller.foundUser.value;
          if (user == null) return const SizedBox.shrink();
          if (widget.controller.requestSent.value) {
            return _RequestSentCard(
              name: user.displayName,
              onReset: widget.controller.reset,
            );
          }
          return _FoundUserCard(
            name: user.displayName,
            avatarUrl: user.avatarUrl,
            onSendRequest: widget.controller.sendRequest,
            isLoading: widget.controller.isSearching.value,
          );
        }),
      ],
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
                  style: TextStyle(
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
