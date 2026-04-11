import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:done_drop/core/theme/theme.dart';
import 'package:done_drop/app/core/widgets/widgets.dart';
import 'package:done_drop/firebase/repositories/friend_repository.dart';
import 'package:done_drop/features/auth/repositories/user_profile_repository.dart';
import 'package:done_drop/app/presentation/friends/add_friend_controller.dart';

class AddFriendScreen extends StatelessWidget {
  const AddFriendScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AddFriendController>(
      init: AddFriendController(
        Get.find<FriendRepository>(),
        Get.find<UserProfileRepository>(),
      ),
      builder: (ctrl) {
        return Scaffold(
          backgroundColor: AppColors.surface,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.primary),
              onPressed: () => Get.back(),
            ),
            title: const Text('Add Friend'),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.space24),
            child: Form(
              key: ctrl.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Find by Email',
                    style: TextStyle(
                      fontFamily: AppTypography.serifFamily,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppSizes.space8),
                  Text(
                    'Enter your friend\'s email address to send a friend request.',
                    style: TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(height: AppSizes.space32),

                  // Search field
                  Row(
                    children: [
                      Expanded(
                        child: Obx(() => DDTextField(
                          controller: ctrl.searchController,
                          label: 'Email',
                          hint: 'friend@example.com',
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.email_outlined,
                          validator: ctrl.validateEmail,
                          textInputAction: TextInputAction.search,
                          onFieldSubmitted: (_) => ctrl.searchByEmail(),
                          enabled: !ctrl.isSearching.value,
                        )),
                      ),
                      const SizedBox(width: AppSizes.space12),
                      Obx(() => DDPrimaryButton(
                        label: 'Search',
                        isLoading: ctrl.isSearching.value,
                        onPressed: ctrl.isSearching.value ? null : ctrl.searchByEmail,
                      )),
                    ],
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
                            Icon(Icons.error_outline, color: AppColors.error, size: 18),
                            const SizedBox(width: AppSizes.space8),
                            Expanded(child: Text(msg, style: TextStyle(color: AppColors.onErrorContainer, fontSize: 13))),
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
                      return _RequestSentCard(name: user.displayName, onReset: ctrl.reset);
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
            backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
            child: avatarUrl == null ? Icon(Icons.person, color: AppColors.primary, size: 32) : null,
          ),
          const SizedBox(height: AppSizes.space12),
          Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
          ),
          const SizedBox(height: 4),
          Text(
            'Send a friend request?',
            style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: AppSizes.space16),
          DDPrimaryButton(
            label: 'Send Friend Request',
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
            'Request Sent!',
            style: TextStyle(
              fontFamily: AppTypography.serifFamily,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Friend request sent to $name',
            style: TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: AppSizes.space16),
          DDSecondaryButton(
            label: 'Add Another Friend',
            onPressed: onReset,
            isExpanded: true,
          ),
        ],
      ),
    );
  }
}
