import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:done_drop/app/presentation/capture/moment_controller.dart';
import 'package:done_drop/core/constants/app_constants.dart';
import 'package:done_drop/core/models/friendship.dart';
import 'package:done_drop/core/models/user_profile.dart';
import 'package:done_drop/core/theme/theme.dart';
import 'package:done_drop/features/auth/presentation/controllers/auth_controller.dart';
import 'package:done_drop/features/auth/repositories/user_profile_repository.dart';
import 'package:done_drop/firebase/repositories/friend_repository.dart';

class PreviewScreen extends StatefulWidget {
  const PreviewScreen({super.key});

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  late final MomentController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<MomentController>();
    _controller.hydratePreview(Get.arguments as Map<String, dynamic>?);
  }

  @override
  Widget build(BuildContext context) {
    final imagePath = _controller.imagePath;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: SafeArea(
          child: Column(
            children: [
              _PreviewTopBar(controller: _controller),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSizes.space24,
                    AppSizes.space8,
                    AppSizes.space24,
                    AppSizes.space32,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (imagePath != null)
                        ClipRRect(
                          borderRadius: AppSizes.borderRadiusLg,
                          child: AspectRatio(
                            aspectRatio: 4 / 5,
                            child: Image.file(
                              File(imagePath),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      const SizedBox(height: AppSizes.space20),
                      _ProofSummary(controller: _controller),
                      const SizedBox(height: AppSizes.space20),
                      _CaptionField(controller: _controller),
                      const SizedBox(height: AppSizes.space20),
                      _CategorySelector(controller: _controller),
                      const SizedBox(height: AppSizes.space20),
                      _AudienceSection(controller: _controller),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreviewTopBar extends StatelessWidget {
  const _PreviewTopBar({required this.controller});

  final MomentController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.space12,
          vertical: AppSizes.space8,
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: controller.isPosting.value ? null : Get.back,
              icon: const Icon(Icons.arrow_back, color: AppColors.primary),
            ),
            Expanded(
              child: Text(
                controller.isProofMoment ? 'Proof Preview' : 'Moment Preview',
                textAlign: TextAlign.center,
                style: AppTypography.titleLarge(color: AppColors.onSurface),
              ),
            ),
            TextButton(
              onPressed: controller.isPosting.value
                  ? null
                  : controller.postMoment,
              child: controller.isPosting.value
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    )
                  : Text(
                      controller.isProofMoment ? 'Save' : 'Post',
                      style: AppTypography.labelLarge(color: AppColors.primary),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProofSummary extends StatelessWidget {
  const _ProofSummary({required this.controller});

  final MomentController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.space20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppSizes.borderRadiusLg,
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.space12,
              vertical: AppSizes.space8,
            ),
            decoration: BoxDecoration(
              color: controller.isProofMoment
                  ? AppColors.primaryFixed
                  : AppColors.tertiaryFixed,
              borderRadius: AppSizes.borderRadiusFull,
            ),
            child: Text(
              controller.isProofMoment ? 'Habit proof' : 'Private moment',
              style: AppTypography.labelMedium(
                color: controller.isProofMoment
                    ? AppColors.primary
                    : AppColors.tertiary,
              ),
            ),
          ),
          const SizedBox(height: AppSizes.space16),
          Text(
            controller.isProofMoment
                ? 'This post stays linked to the habit you just completed.'
                : 'You can save this privately or share it with a small buddy circle.',
            style: AppTypography.titleMedium(color: AppColors.onSurface),
          ),
          const SizedBox(height: AppSizes.space8),
          Text(
            controller.isProofMoment
                ? 'Posting here will only handle the proof image, audience, and linking. Completion is already locked in.'
                : 'Keep the loop simple: save only, add proof, or share privately.',
            style: AppTypography.bodySmall(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _CaptionField extends StatelessWidget {
  const _CaptionField({required this.controller});

  final MomentController controller;

  @override
  Widget build(BuildContext context) {
    final hintText = controller.isProofMoment
        ? 'What did you finish?'
        : 'Why does this moment matter?';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Caption',
          style: AppTypography.labelMedium(color: AppColors.onSurfaceVariant),
        ),
        const SizedBox(height: AppSizes.space8),
        TextField(
          controller: controller.captionController,
          maxLength: AppConstants.maxCaptionLength,
          maxLines: 4,
          style: AppTypography.bodyLarge(color: AppColors.onSurface),
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: AppColors.surfaceContainerLowest,
            border: OutlineInputBorder(
              borderRadius: AppSizes.borderRadiusMd,
              borderSide: BorderSide.none,
            ),
            counterText: '',
          ),
        ),
        Obx(() {
          final message = controller.errorMessage.value;
          if (message == null) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(top: AppSizes.space8),
            child: Text(
              message,
              style: AppTypography.bodySmall(color: AppColors.error),
            ),
          );
        }),
      ],
    );
  }
}

class _CategorySelector extends StatelessWidget {
  const _CategorySelector({required this.controller});

  final MomentController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: AppTypography.labelMedium(color: AppColors.onSurfaceVariant),
        ),
        const SizedBox(height: AppSizes.space8),
        Obx(
          () => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _CategoryChip(
                  label: 'None',
                  isSelected: controller.selectedCategory.value.isEmpty,
                  onTap: () => controller.setCategory(null),
                ),
                ...AppConstants.momentCategories.map(
                  (category) => _CategoryChip(
                    label: category,
                    isSelected: controller.selectedCategory.value == category,
                    onTap: () => controller.setCategory(category),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSizes.space8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppSizes.borderRadiusFull,
          onTap: onTap,
          child: Ink(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.space12,
              vertical: AppSizes.space10,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primaryFixed
                  : AppColors.surfaceContainerLow,
              borderRadius: AppSizes.borderRadiusFull,
            ),
            child: Text(
              label,
              style: AppTypography.labelMedium(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AudienceSection extends StatelessWidget {
  const _AudienceSection({required this.controller});

  final MomentController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Who sees this',
          style: AppTypography.titleMedium(color: AppColors.onSurface),
        ),
        const SizedBox(height: AppSizes.space8),
        Obx(
          () => Wrap(
            spacing: AppSizes.space8,
            runSpacing: AppSizes.space8,
            children: [
              _AudiencePill(
                icon: Icons.lock_outline,
                label: 'Only me',
                isSelected:
                    controller.visibility.value == AppConstants.visibilityPersonalOnly,
                onTap: () => controller.setVisibility(
                  AppConstants.visibilityPersonalOnly,
                ),
              ),
              _AudiencePill(
                icon: Icons.person_outline,
                label: 'Share privately',
                isSelected:
                    controller.visibility.value == AppConstants.visibilitySelectedFriends,
                onTap: () => controller.setVisibility(
                  AppConstants.visibilitySelectedFriends,
                ),
              ),
              _AudiencePill(
                icon: Icons.groups_outlined,
                label: 'Close crew',
                isSelected:
                    controller.visibility.value == AppConstants.visibilityAllFriends,
                onTap: () =>
                    controller.setVisibility(AppConstants.visibilityAllFriends),
              ),
            ],
          ),
        ),
        if (controller.visibility.value ==
            AppConstants.visibilitySelectedFriends) ...[
          const SizedBox(height: AppSizes.space16),
          _SelectedFriendPicker(controller: controller),
        ],
      ],
    );
  }
}

class _AudiencePill extends StatelessWidget {
  const _AudiencePill({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppSizes.borderRadiusFull,
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.space16,
            vertical: AppSizes.space10,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryFixed
                : AppColors.surfaceContainerLow,
            borderRadius: AppSizes.borderRadiusFull,
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.outlineVariant,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
              ),
              const SizedBox(width: AppSizes.space6),
              Text(
                label,
                style: AppTypography.labelMedium(
                  color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectedFriendPicker extends StatelessWidget {
  const _SelectedFriendPicker({required this.controller});

  final MomentController controller;

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final friendRepository = Get.find<FriendRepository>();
    final userProfileRepository = Get.find<UserProfileRepository>();
    final currentUserId = authController.firebaseUser?.uid;

    if (currentUserId == null) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<List<Friendship>>(
      stream: friendRepository.watchFriendships(currentUserId),
      builder: (context, snapshot) {
        final friendships = snapshot.data ?? const <Friendship>[];
        if (friendships.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSizes.space16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: AppSizes.borderRadiusMd,
            ),
            child: Text(
              'Add a buddy first to share proof privately.',
              style: AppTypography.bodySmall(color: AppColors.onSurfaceVariant),
            ),
          );
        }

        final friendIds = friendships
            .map((friendship) => friendship.otherUserId(currentUserId))
            .toList(growable: false);

        return FutureBuilder<Map<String, UserProfile>>(
          future: userProfileRepository.getUserProfiles(friendIds),
          builder: (context, profileSnapshot) {
            final profiles =
                profileSnapshot.data ?? const <String, UserProfile>{};

            return Obx(
              () => Wrap(
                spacing: AppSizes.space8,
                runSpacing: AppSizes.space8,
                children: friendIds
                    .map((friendId) {
                      final profile = profiles[friendId];
                      final displayName =
                          profile?.displayName ?? profile?.username ?? 'Buddy';
                      final isSelected = controller.selectedFriendIds.contains(
                        friendId,
                      );

                      return FilterChip(
                        selected: isSelected,
                        label: Text(displayName),
                        avatar: CircleAvatar(
                          backgroundColor: AppColors.primaryFixed,
                          backgroundImage: profile?.avatarUrl != null
                              ? NetworkImage(profile!.avatarUrl!)
                              : null,
                          child: profile?.avatarUrl == null
                              ? Text(
                                  displayName.characters.first.toUpperCase(),
                                  style: AppTypography.labelMedium(
                                    color: AppColors.primary,
                                  ),
                                )
                              : null,
                        ),
                        selectedColor: AppColors.primaryFixed,
                        onSelected: (_) =>
                            controller.toggleSelectedFriend(friendId),
                      );
                    })
                    .toList(growable: false),
              ),
            );
          },
        );
      },
    );
  }
}
