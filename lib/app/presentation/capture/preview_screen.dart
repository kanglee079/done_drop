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
        const Text(
          'Share To',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Choose who can witness this moment.',
          style: TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant),
        ),
        const SizedBox(height: AppSizes.space16),

        Obx(() => _AudienceCard(
          icon: Icons.lock_outline,
          title: 'Just me',
          subtitle: 'Keep this moment completely private.',
          isSelected: ctrl.visibility.value == AppConstants.visibilityPersonalOnly,
          onTap: () => ctrl.setVisibility(AppConstants.visibilityPersonalOnly),
        )),
        const SizedBox(height: AppSizes.space12),

        Obx(() => _AudienceCard(
          icon: Icons.person_outline,
          title: 'My buddy',
          subtitle: 'Share only with your primary buddy.',
          isSelected: ctrl.visibility.value == AppConstants.visibilitySelectedFriends,
          onTap: () => ctrl.setVisibility(AppConstants.visibilitySelectedFriends),
        )),
        const SizedBox(height: AppSizes.space12),

        Obx(() => _AudienceCard(
          icon: Icons.groups_outlined,
          title: 'Close crew',
          subtitle: 'Notify all your close friends.',
          isSelected: ctrl.visibility.value == AppConstants.visibilityAllFriends,
          onTap: () => ctrl.setVisibility(AppConstants.visibilityAllFriends),
        )),
      ],
    );
  }
}

class _AudienceCard extends StatelessWidget {
  const _AudienceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppSizes.space16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.05) : AppColors.surfaceContainerLow,
          borderRadius: AppSizes.borderRadiusMd,
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surfaceContainerHigh,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 20,
                color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: AppSizes.space16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? AppColors.primary : AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
