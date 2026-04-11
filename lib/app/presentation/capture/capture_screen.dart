import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart' as img_picker;
import '../../../core/theme/theme.dart';
import '../../../core/services/analytics_service.dart';
import '../../routes/app_routes.dart';

/// DoneDrop Capture Screen — Camera / gallery selection
class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  final _picker = img_picker.ImagePicker();

  Future<void> _pickFromCamera() async {
    await AnalyticsService.instance.photoCaptureStarted();
    final image = await _picker.pickImage(
      source: img_picker.ImageSource.camera,
      imageQuality: 85,
      maxWidth: 1920,
    );
    if (image != null) {
      await AnalyticsService.instance.photoSelected('camera');
      Get.toNamed(AppRoutes.preview, arguments: {'imagePath': image.path});
    }
  }

  Future<void> _pickFromGallery() async {
    await AnalyticsService.instance.photoCaptureStarted();
    final image = await _picker.pickImage(
      source: img_picker.ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1920,
    );
    if (image != null) {
      await AnalyticsService.instance.photoSelected('gallery');
      Get.toNamed(AppRoutes.preview, arguments: {'imagePath': image.path});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withValues(alpha: 0.85),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.primary),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Capture',
          style: TextStyle(
            fontFamily: AppTypography.serifFamily,
            fontSize: 20,
            fontStyle: FontStyle.italic,
            color: AppColors.primary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.space24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Capture a Moment',
                style: TextStyle(
                  fontFamily: AppTypography.serifFamily,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Complete it. Capture it. Share the moment.',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: _CaptureOption(
                      icon: Icons.camera_alt_outlined,
                      title: 'Camera',
                      desc: 'Take a photo now',
                      onTap: _pickFromCamera,
                    ),
                  ),
                  const SizedBox(width: AppSizes.space16),
                  Expanded(
                    child: _CaptureOption(
                      icon: Icons.photo_library_outlined,
                      title: 'Gallery',
                      desc: 'Choose from library',
                      onTap: _pickFromGallery,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Center(
                child: TextButton(
                  onPressed: () => Get.back(),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: AppColors.outline),
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

class _CaptureOption extends StatelessWidget {
  const _CaptureOption({
    required this.icon,
    required this.title,
    required this.desc,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String desc;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.space32),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: AppSizes.borderRadiusLg,
        ),
        child: Column(
          children: [
            Icon(icon, size: 48, color: AppColors.primary),
            const SizedBox(height: AppSizes.space16),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              desc,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
