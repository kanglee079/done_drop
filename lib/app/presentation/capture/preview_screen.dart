import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/theme.dart';
import '../../routes/app_routes.dart';
class PreviewScreen extends StatefulWidget {
  const PreviewScreen({super.key});

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  final _captionController = TextEditingController();
  String _visibility = 'personal_only';
  String? _selectedCircle;
  bool _isPosting = false;

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _postMoment() async {
    setState(() => _isPosting = true);
    // Upload logic will be implemented in Phase 3
    await Future.delayed(const Duration(seconds: 1));
    Get.offNamed(AppRoutes.success);
  }

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>?;
    final imagePath = args?['imagePath'] as String?;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.all(AppSizes.space16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.primary),
                    onPressed: () => Get.back(),
                  ),
                  const Expanded(
                    child: Text(
                      'Post Moment',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Newsreader',
                        fontSize: 18,
                        fontStyle: FontStyle.italic,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _isPosting ? null : _postMoment,
                    child: _isPosting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
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
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.space24,
                ),
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
                    Text(
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
                      controller: _captionController,
                      maxLength: 300,
                      maxLines: 3,
                      style: TextStyle(
                        fontFamily: 'Newsreader',
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
                    const SizedBox(height: AppSizes.space32),
                    // Audience
                    Text(
                      'Share To',
                      style: TextStyle(
                        fontFamily: 'Newsreader',
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Choose who can witness this moment.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSizes.space16),
                    Wrap(
                      spacing: AppSizes.space12,
                      runSpacing: AppSizes.space12,
                      children: [
                        _AudienceChip(
                          icon: Icons.person,
                          label: 'Personal Wall',
                          isSelected: _visibility == 'personal_only',
                          onTap: () =>
                              setState(() => _visibility = 'personal_only'),
                        ),
                        _AudienceChip(
                          icon: Icons.group,
                          label: 'The Sunday Collective',
                          isSelected:
                              _visibility == 'circle' && _selectedCircle != null,
                          onTap: () => setState(() {
                            _visibility = 'circle';
                            _selectedCircle = 'demo-circle';
                          }),
                        ),
                      ],
                    ),
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
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.space16,
          vertical: AppSizes.space12,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryContainer
              : AppColors.surfaceContainerLow,
          borderRadius: AppSizes.borderRadiusFull,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? AppColors.onPrimaryContainer
                  : AppColors.onSurfaceVariant,
            ),
            const SizedBox(width: AppSizes.space8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? AppColors.onPrimaryContainer
                    : AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
