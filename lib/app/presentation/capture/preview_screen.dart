import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:done_drop/core/theme/theme.dart';
import 'package:done_drop/app/presentation/capture/moment_controller.dart';
import 'package:done_drop/app/presentation/home/home_controller.dart';
import 'package:done_drop/firebase/repositories/circle_repository.dart';
import 'package:done_drop/firebase/repositories/moment_repository.dart';

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
    if (imagePath != null) {
      ctrl.setImagePath(imagePath);
    }

    return Scaffold(
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
              'Post Moment',
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
                : const Text(
                    'Post',
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
            hintText: 'Add a short caption...',
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

  static const categories = [
    'Daily Wins',
    'Travel',
    'Reflections',
    'Health & Fitness',
    'Creative',
    'Learning',
    'Relationships',
    'Nature',
    'Food',
    'Work',
    'Monthly Highlights',
  ];

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
          label: 'Personal Wall',
          isSelected: ctrl.visibility.value == 'personal_only',
          onTap: () => ctrl.setVisibility('personal_only'),
        )),
        const SizedBox(height: AppSizes.space12),

        // Circle chips — dynamic from HomeController circles
        _CircleChips(ctrl: ctrl),
      ],
    );
  }
}

class _CircleChips extends StatelessWidget {
  const _CircleChips({required this.ctrl});
  final MomentController ctrl;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      init: HomeController(Get.find<CircleRepository>(), Get.find<MomentRepository>()),
      builder: (homeCtrl) {
        if (homeCtrl.circles.isEmpty) {
          return const SizedBox.shrink();
        }
        return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: homeCtrl.circles.map((circle) {
            final isSelected = ctrl.visibility.value == 'circle'
                && ctrl.selectedCircleId.value == circle.id;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.space8),
              child: _AudienceChip(
                icon: Icons.group,
                label: circle.name,
                isSelected: isSelected,
                onTap: () {
                  ctrl.setCircle(circle.id);
                },
              ),
            );
          }).toList(),
        ));
      },
    );
  }
}

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
          borderRadius: AppSizes.borderRadiusFull,
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
