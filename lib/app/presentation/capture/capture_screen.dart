import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart' as image_picker;
import 'package:done_drop/app/core/widgets/widgets.dart';
import 'package:done_drop/app/presentation/capture/moment_controller.dart';
import 'package:done_drop/app/routes/app_routes.dart';
import 'package:done_drop/core/services/analytics_service.dart';
import 'package:done_drop/core/theme/theme.dart';

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  final _picker = image_picker.ImagePicker();
  final _controller = Get.find<MomentController>();
  bool _isLoading = false;

  bool get _isProofMoment => _controller.isProofMoment;

  @override
  void initState() {
    super.initState();
    _controller.startCaptureSession(Get.arguments as Map<String, dynamic>?);

    if (_isProofMoment) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _pickFromCamera();
      });
    }
  }

  Future<void> _pickFromCamera() async {
    await _pickImage(image_picker.ImageSource.camera);
  }

  Future<void> _pickFromGallery() async {
    await _pickImage(image_picker.ImageSource.gallery);
  }

  Future<void> _pickImage(image_picker.ImageSource source) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    await AnalyticsService.instance.photoCaptureStarted();
    final image = await _picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1920,
    );

    if (!mounted) return;

    if (image == null) {
      setState(() => _isLoading = false);
      return;
    }

    await AnalyticsService.instance.photoSelected(
      source == image_picker.ImageSource.camera ? 'camera' : 'gallery',
    );
    _controller.attachImage(image.path);

    await Get.toNamed(AppRoutes.preview, arguments: {'imagePath': image.path});

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<bool> _handlePop() async {
    _controller.resetComposer();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final spec = DDResponsiveSpec.of(context);

    if (_isLoading && _isProofMoment) {
      return Scaffold(
        backgroundColor: AppColors.surface,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: AppSizes.space16),
              Text(
                'Opening your proof camera…',
                style: AppTypography.bodyMedium(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _handlePop();
        if (shouldPop && mounted) {
          Get.back();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          backgroundColor: AppColors.surface.withValues(alpha: 0.92),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: AppColors.primary),
            onPressed: () {
              _controller.resetComposer();
              Get.back();
            },
          ),
          title: Text(
            _isProofMoment ? 'Capture proof' : 'Capture moment',
            style: AppTypography.titleLarge(color: AppColors.onSurface),
          ),
        ),
        body: SafeArea(
          child: DDResponsiveScrollBody(
            maxWidth: 920,
            padding: spec.pagePadding(
              top: AppSizes.space8,
              bottom: AppSizes.space24,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final useTwoColumns = constraints.maxWidth >= 720;
                final cardWidth = useTwoColumns
                    ? ((constraints.maxWidth - AppSizes.space16) / 2)
                          .clamp(260.0, 420.0)
                          .toDouble()
                    : constraints.maxWidth;

                final optionCards = [
                  SizedBox(
                    width: cardWidth,
                    child: _CaptureOptionCard(
                      icon: Icons.camera_alt_outlined,
                      title: 'Camera',
                      description: 'Proof is freshest right now.',
                      onTap: _pickFromCamera,
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _CaptureOptionCard(
                      icon: Icons.photo_library_outlined,
                      title: 'Gallery',
                      description: 'Your recent wins are still waiting.',
                      onTap: _pickFromGallery,
                    ),
                  ),
                ];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSizes.space24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.primaryContainer,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: AppSizes.borderRadiusLg,
                        boxShadow: AppColors.cardShadow,
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
                              color: Colors.white.withValues(alpha: 0.14),
                              borderRadius: AppSizes.borderRadiusFull,
                            ),
                            child: Text(
                              _isProofMoment
                                  ? 'Complete + proof'
                                  : 'Save or share later',
                              style: AppTypography.labelMedium(
                                color: AppColors.onPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSizes.space20),
                          Text(
                            _isProofMoment
                                ? 'Capture the proof while the win is fresh.'
                                : 'Add a photo when the moment matters.',
                            style: AppTypography.headlineSmall(
                              color: AppColors.onPrimary,
                            ),
                          ),
                          const SizedBox(height: AppSizes.space8),
                          Text(
                            _isProofMoment
                                ? 'This keeps the habit completion linked to the exact instance you just finished.'
                                : 'You can keep it private, attach it to a habit later, or share it with your buddy circle.',
                            style: AppTypography.bodyMedium(
                              color: AppColors.onPrimary.withValues(
                                alpha: 0.84,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSizes.space24),
                    Text(
                      'Choose source',
                      style: AppTypography.labelMedium(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSizes.space12),
                    if (useTwoColumns)
                      Wrap(
                        spacing: AppSizes.space16,
                        runSpacing: AppSizes.space16,
                        children: optionCards,
                      )
                    else
                      Column(
                        children: [
                          optionCards[0],
                          const SizedBox(height: AppSizes.space16),
                          optionCards[1],
                        ],
                      ),
                    const SizedBox(height: AppSizes.space24),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          _controller.resetComposer();
                          Get.back();
                        },
                        child: Text(
                          'Cancel',
                          style: AppTypography.labelLarge(
                            color: AppColors.outline,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _CaptureOptionCard extends StatelessWidget {
  const _CaptureOptionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppSizes.borderRadiusLg,
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: AppSizes.borderRadiusLg,
            border: Border.all(color: AppColors.outlineVariant),
            boxShadow: AppColors.cardShadow,
          ),
          padding: const EdgeInsets.all(AppSizes.space24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primaryFixed,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: AppColors.primary, size: 26),
              ),
              const Spacer(),
              Text(
                title,
                style: AppTypography.titleMedium(color: AppColors.onSurface),
              ),
              const SizedBox(height: AppSizes.space8),
              Text(
                description,
                style: AppTypography.bodySmall(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
