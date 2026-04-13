import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:done_drop/core/theme/theme.dart';
import 'package:done_drop/core/constants/app_constants.dart';
import 'package:done_drop/core/errors/result.dart';
import 'package:done_drop/app/presentation/capture/moment_controller.dart';
import 'package:done_drop/app/presentation/home/home_controller.dart';
import 'package:done_drop/firebase/repositories/friend_repository.dart';
import 'package:done_drop/features/auth/repositories/user_profile_repository.dart';

/// DoneDrop Preview Screen — caption, audience selection, and post moment.
class PreviewScreen extends StatelessWidget {
  const PreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get or create MomentController; share it across preview flow
    final ctrl = Get.put(MomentController());

    // If imagePath was passed, set it on the controller
    final args = Get.arguments as Map<String, dynamic>?;
    final imagePath = args?['imagePath'] as String?;

    // Initialize proof moment context if coming from activity completion
    ctrl.initFromArgs(args);

    if (imagePath != null) {
      ctrl.setImagePath(imagePath);
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: SafeArea(
          child: Column(
            children: [
              // Top bar
              _PreviewTopBar(ctrl: ctrl),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.space24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image preview
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
                      const SizedBox(height: AppSizes.space24),

                      // Caption
                      _CaptionField(ctrl: ctrl),
                      const SizedBox(height: AppSizes.space24),

                      // Category
                      _CategorySelector(ctrl: ctrl),
                      const SizedBox(height: AppSizes.space24),

                      // Audience
                      _AudienceSection(ctrl: ctrl),
                      const SizedBox(height: AppSizes.space48),
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
  const _PreviewTopBar({required this.ctrl});
  final MomentController ctrl;

  @override
  Widget build(BuildContext context) {
    return Obx(() => Padding(
      padding: const EdgeInsets.all(AppSizes.space16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.primary),
            onPressed: ctrl.isPosting.value ? null : () => Get.back(),
          ),
          Expanded(
            child: Text(
              // "Proof Moment" when coming from activity completion
              ctrl.isProofMoment ? 'Proof Moment' : 'Post Moment',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTypography.serifFamily,
                fontSize: 18,
                fontStyle: FontStyle.italic,
                color: AppColors.primary,
              ),
            ),
          ),
          TextButton(
            onPressed: ctrl.isPosting.value ? null : ctrl.postMoment,
            child: ctrl.isPosting.value
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                  )
                : Text(
                    ctrl.isProofMoment ? 'Save' : 'Post',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ],
      ),
    ));
  }
}

class _CaptionField extends StatelessWidget {
  const _CaptionField({required this.ctrl});
  final MomentController ctrl;

  @override
  Widget build(BuildContext context) {
    final isProof = ctrl.isProofMoment;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Caption',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.outline,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: AppSizes.space8),
        TextField(
          controller: ctrl.captionController,
          maxLength: 300,
          maxLines: 3,
          style: TextStyle(
            fontFamily: AppTypography.serifFamily,
            fontSize: 20,
            fontStyle: FontStyle.italic,
            color: AppColors.onSurface,
          ),
          decoration: InputDecoration(
            // Proof moments don't require a caption; free captures can add one optionally
            hintText: isProof ? 'Add a caption for your proof (optional)...' : 'Add a short caption...',
            hintStyle: TextStyle(
              color: AppColors.outline.withValues(alpha: 0.4),
              fontStyle: FontStyle.italic,
            ),
            filled: true,
            fillColor: AppColors.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: AppSizes.borderRadiusMd,
              borderSide: BorderSide.none,
            ),
            counterText: '',
          ),
        ),
        Obx(() {
          final msg = ctrl.errorMessage.value;
          if (msg == null) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(top: AppSizes.space8),
            child: Text(msg, style: TextStyle(color: AppColors.error, fontSize: 12)),
          );
        }),
      ],
    );
  }
}

class _CategorySelector extends StatelessWidget {
  const _CategorySelector({required this.ctrl});
  final MomentController ctrl;

  // Use constants instead of hardcoded list
  List<String> get categories => AppConstants.momentCategories;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.outline,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: AppSizes.space8),
        Obx(() => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _CategoryChip(
                label: 'None',
                isSelected: ctrl.selectedCategory.value.isEmpty,
                onTap: () => ctrl.setCategory(null),
              ),
              ...categories.map((cat) => _CategoryChip(
                label: cat,
                isSelected: ctrl.selectedCategory.value == cat,
                onTap: () => ctrl.setCategory(cat),
              )),
            ],
          ),
        )),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label, required this.isSelected, required this.onTap});
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryFixed : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _AudienceSection extends StatelessWidget {
  const _AudienceSection({required this.ctrl});
  final MomentController ctrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Share To',
          style: TextStyle(
            fontFamily: AppTypography.serifFamily,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Choose who can witness this moment.',
          style: TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant),
        ),
        const SizedBox(height: AppSizes.space16),

        // Personal Wall chip
        Obx(() => _AudienceChip(
          icon: Icons.person,
          label: 'Personal Only',
          isSelected: ctrl.visibility.value == AppConstants.visibilityPersonalOnly,
          onTap: () => ctrl.setVisibility(AppConstants.visibilityPersonalOnly),
        )),
        const SizedBox(height: AppSizes.space12),

        // All Friends chip
        Obx(() => _AudienceChip(
          icon: Icons.people,
          label: 'All Friends',
          isSelected: ctrl.visibility.value == AppConstants.visibilityAllFriends,
          onTap: () => ctrl.setVisibility(AppConstants.visibilityAllFriends),
        )),
        const SizedBox(height: AppSizes.space12),

        // Selected Friends chip
        Obx(() => _AudienceChip(
          icon: Icons.group,
          label: 'Selected Friends',
          isSelected: ctrl.visibility.value == AppConstants.visibilitySelectedFriends,
          onTap: () => ctrl.setVisibility(AppConstants.visibilitySelectedFriends),
        )),

        // Friend selector when "Selected Friends" is chosen
        Obx(() {
          if (ctrl.visibility.value != AppConstants.visibilitySelectedFriends) {
            return const SizedBox.shrink();
          }
          return _FriendSelector(
            selectedFriendIds: ctrl.selectedFriendIds,
            onToggle: ctrl.toggleSelectedFriend,
          );
        }),
      ],
    );
  }
}

class _FriendSelector extends StatelessWidget {
  const _FriendSelector({
    required this.selectedFriendIds,
    required this.onToggle,
  });

  final RxList<String> selectedFriendIds;
  final void Function(String) onToggle;

  @override
  Widget build(BuildContext context) {
    final friendRepo = Get.find<FriendRepository>();
    final userProfileRepo = Get.find<UserProfileRepository>();

    return FutureBuilder(
      future: friendRepo.watchFriendships(
        Get.find<HomeController>().currentUserId ?? '',
      ).first,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.only(top: AppSizes.space12),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }

        final friendships = snapshot.data!;
        if (friendships.isEmpty) {
          return Padding(
            padding: const EdgeInsets.only(top: AppSizes.space12),
            child: Container(
              padding: const EdgeInsets.all(AppSizes.space16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: AppSizes.borderRadiusMd,
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.outline, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'No friends yet. Add friends first to share with them.',
                      style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return FutureBuilder(
          future: Future.wait(
            friendships.map((f) async {
              final uid = Get.find<HomeController>().currentUserId ?? '';
              final friendId = f.otherUserId(uid);
              final result = await userProfileRepo.getUserProfile(friendId);
              final profile = result.fold(
                onSuccess: (data) => data,
                onFailure: (_) => null,
              );
              return (friendId, profile);
            }).toList(),
          ),
          builder: (context, snap) {
            if (!snap.hasData) return const SizedBox.shrink();

            return Padding(
              padding: const EdgeInsets.only(top: AppSizes.space12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Friends',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.outline,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: AppSizes.space8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: snap.data!.map((item) {
                      final friendId = item.$1;
                      final profile = item.$2;
                      final name = profile?.displayName ?? 'Friend';
                      final avatarUrl = profile?.avatarUrl;
                      final isSelected = selectedFriendIds.contains(friendId);

                      return GestureDetector(
                        onTap: () => onToggle(friendId),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryContainer
                                : AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(20),
                            border: isSelected
                                ? Border.all(color: AppColors.primary, width: 1.5)
                                : null,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 10,
                                backgroundColor: AppColors.primaryFixed,
                                backgroundImage: avatarUrl != null
                                    ? NetworkImage(avatarUrl)
                                    : null,
                                child: avatarUrl == null
                                    ? Icon(Icons.person, size: 10, color: AppColors.primary)
                                    : null,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                name,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? AppColors.onPrimaryContainer
                                      : AppColors.onSurfaceVariant,
                                ),
                              ),
                              if (isSelected) ...[
                                const SizedBox(width: 4),
                                Icon(Icons.check, size: 14, color: AppColors.primary),
                              ],
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// Unused — kept for reference during Phase 3 (Circle V1.5)
// class _CircleChips extends StatelessWidget {
//   const _CircleChips({required this.ctrl});
//   final MomentController ctrl;
//   ...
// }

class _AudienceChip extends StatelessWidget {
  const _AudienceChip({
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.space16, vertical: AppSizes.space12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryContainer : AppColors.surfaceContainerLow,
          borderRadius: AppSizes.borderRadiusMd,
          border: isSelected ? Border.all(color: AppColors.primary, width: 1.5) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppColors.onPrimaryContainer : AppColors.onSurfaceVariant,
            ),
            const SizedBox(width: AppSizes.space8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.onPrimaryContainer : AppColors.onSurfaceVariant,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: AppSizes.space8),
              Icon(Icons.check_circle, size: 16, color: AppColors.onPrimaryContainer),
            ],
          ],
        ),
      ),
    );
  }
}
