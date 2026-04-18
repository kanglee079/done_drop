import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:done_drop/core/theme/theme.dart';
import 'package:done_drop/app/core/widgets/widgets.dart';
import 'package:done_drop/firebase/repositories/friend_repository.dart';
import 'package:done_drop/app/presentation/friends/add_friend_controller.dart';
import 'package:done_drop/l10n/l10n.dart';

class AddFriendScreen extends StatelessWidget {
  const AddFriendScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return GetBuilder<AddFriendController>(
      init: AddFriendController(Get.find<FriendRepository>()),
      builder: (ctrl) {
        final spec = DDResponsiveSpec.of(context);
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

                  Text(
                    l10n.findByUsernameTitle,
                    style: TextStyle(
                      fontFamily: AppTypography.serifFamily,
                      fontSize: spec.width < 360 ? 24 : 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppSizes.space8),
                  Text(
                    l10n.findByUsernameSubtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSizes.space32),

                  // Search field
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final useStackedSearch = constraints.maxWidth < 440;
                      final searchField = Expanded(
                        child: Obx(
                          () => DDTextField(
                            controller: ctrl.searchController,
                            label: l10n.usernameLabel,
                            hint: l10n.usernameHint,
                            prefixIcon: Icons.alternate_email,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.search,
                            onFieldSubmitted: (_) => ctrl.searchByUsername(),
                            enabled:
                                !ctrl.isSearching.value && !ctrl.isAtCap.value,
                          ),
                        ),
                      );
                      final searchButton = Obx(
                        () => SizedBox(
                          width: useStackedSearch ? double.infinity : 132,
                          child: DDPrimaryButton(
                            label: l10n.searchAction,
                            isLoading: ctrl.isSearching.value,
                            onPressed:
                                (ctrl.isSearching.value || ctrl.isAtCap.value)
                                ? null
                                : ctrl.searchByUsername,
                          ),
                        ),
                      );

                      if (useStackedSearch) {
                        return Column(
                          children: [
                            Row(children: [searchField]),
                            const SizedBox(height: AppSizes.space12),
                            searchButton,
                          ],
                        );
                      }

                      return Row(
                        children: [
                          searchField,
                          const SizedBox(width: AppSizes.space12),
                          searchButton,
                        ],
                      );
                    },
                  ),

                  // Error
                  Obx(() {
                    final msg = ctrl.errorMessage.value;
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
                            Icon(
                              Icons.error_outline,
                              color: AppColors.error,
                              size: 18,
                            ),
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
                    final user = ctrl.foundUser.value;
                    if (user == null) return const SizedBox.shrink();
                    if (ctrl.requestSent.value) {
                      return _RequestSentCard(
                        name: user.displayName,
                        onReset: ctrl.reset,
                      );
                    }
                    return _FoundUserCard(
                      name: user.displayName,
                      avatarUrl: user.avatarUrl,
                      onSendRequest: ctrl.sendRequest,
                      isLoading: ctrl.isSearching.value,
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
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
            icon: Icons.person_add_alt_1,
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
            onPressed: onReset,
            isExpanded: true,
          ),
        ],
      ),
    );
  }
}
