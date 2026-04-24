import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart' as image_picker;

import 'package:done_drop/app/presentation/capture/moment_controller.dart';
import 'package:done_drop/app/routes/app_routes.dart';
import 'package:done_drop/core/services/analytics_service.dart';
import 'package:done_drop/core/services/capture_camera_service.dart';
import 'package:done_drop/core/services/capture_recovery_service.dart';
import 'package:done_drop/core/theme/theme.dart';
import 'package:done_drop/l10n/l10n.dart';

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen>
    with WidgetsBindingObserver {
  static const String _inlineCaptureRejectedReason = 'inline_capture_rejected';

  final _picker = image_picker.ImagePicker();
  final _momentController = Get.find<MomentController>();
  final _cameraService = Get.find<CaptureCameraService>();
  final _captureRecovery = Get.find<CaptureRecoveryService>();

  CameraController? _cameraController;
  CameraLensDirection _lensDirection = CameraLensDirection.back;
  bool _isInitializingCamera = true;
  bool _isCapturing = false;
  bool _isPickingGallery = false;
  String? _cameraError;
  bool _hasMultipleCameras = false;
  int _cameraGeneration = 0;

  bool get _isProofMoment => _momentController.isProofMoment;
  bool get _showGalleryAction => !_isProofMoment;
  bool get _isBusy =>
      _isInitializingCamera || _isCapturing || _isPickingGallery;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _momentController.startCaptureSession(
      Get.arguments as Map<String, dynamic>?,
    );
    _warmAndInitializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeCamera(updateState: false);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _cameraController;
    if (controller == null) return;

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _disposeCamera();
    } else if (state == AppLifecycleState.resumed && mounted) {
      _warmAndInitializeCamera();
    }
  }

  Future<void> _warmAndInitializeCamera() async {
    if (!mounted || _isCapturing || _isPickingGallery) return;
    final generation = ++_cameraGeneration;
    setState(() {
      _isInitializingCamera = true;
      _cameraError = null;
    });

    try {
      _hasMultipleCameras = await _cameraService.hasMultipleCameras();
      final nextController = await _cameraService.createController(
        lensDirection: _lensDirection,
      );
      if (!mounted || generation != _cameraGeneration) {
        await nextController.dispose();
        return;
      }

      final previous = _cameraController;
      setState(() {
        _cameraController = nextController;
        _isInitializingCamera = false;
      });
      await previous?.dispose();
    } catch (error) {
      if (!mounted || generation != _cameraGeneration) return;
      setState(() {
        _cameraController = null;
        _cameraError = error.toString();
        _isInitializingCamera = false;
      });
    }
  }

  Future<void> _disposeCamera({bool updateState = true}) async {
    _cameraGeneration++;
    final controller = _cameraController;
    _cameraController = null;
    if (updateState && mounted) {
      setState(() {
        _cameraController = null;
        _isInitializingCamera = false;
      });
    }
    await controller?.dispose();
  }

  Future<void> _captureInlinePhoto() async {
    final controller = _cameraController;
    if (_isBusy || controller == null || !controller.value.isInitialized) {
      return;
    }

    setState(() => _isCapturing = true);
    try {
      HapticFeedback.mediumImpact();
      await AnalyticsService.instance.photoCaptureStarted();
      final image = await controller.takePicture();
      if (!mounted) return;

      final validation = await _cameraService.validateCaptureFile(image.path);
      if (!mounted) return;

      if (!validation.isUsable) {
        debugPrint(
          '[CaptureScreen] Rejecting inline capture: '
          '${validation.reason} '
          '(avg=${validation.averageLuminance.toStringAsFixed(2)}, '
          'dark=${validation.darkPixelRatio.toStringAsFixed(3)}, '
          'std=${validation.luminanceStdDev.toStringAsFixed(2)})',
        );

        await _disposeCamera();
        if (!mounted) return;
        setState(() {
          _isCapturing = false;
          _cameraError = _inlineCaptureRejectedReason;
        });
        return;
      }

      await _openPreviewWithImage(
        image.path,
        source: 'camera',
        clearBusyState: () => setState(() => _isCapturing = false),
        disposeCurrentCameraBeforePreview: true,
        reinitializeInlineCameraAfterReturn: true,
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _isCapturing = false);
      Get.snackbar(
        context.l10n.captureUnavailableTitle,
        context.l10n.captureUnavailableMessage,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _pickFromGallery() async {
    if (_isBusy) return;
    setState(() => _isPickingGallery = true);

    try {
      await _captureRecovery.stageCaptureSession(
        activityId: _momentController.activityId,
        activityInstanceId: _momentController.activityInstanceId,
        completionLogId: _momentController.completionLogId,
      );
      final image = await _picker.pickImage(
        source: image_picker.ImageSource.gallery,
        imageQuality: 82,
        maxWidth: 1280,
        maxHeight: 1280,
      );

      if (!mounted) return;
      if (image == null) {
        await _captureRecovery.clearPendingCaptureSession();
        setState(() => _isPickingGallery = false);
        return;
      }

      await _openPreviewWithImage(
        image.path,
        source: 'gallery',
        clearBusyState: () => setState(() => _isPickingGallery = false),
        disposeCurrentCameraBeforePreview: false,
        reinitializeInlineCameraAfterReturn: false,
      );
    } catch (_) {
      if (!mounted) return;
      await _captureRecovery.clearPendingCaptureSession();
      setState(() => _isPickingGallery = false);
      Get.snackbar(
        currentL10n.captureUnavailableTitle,
        currentL10n.captureUnavailableMessage,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<bool> _openSystemCameraFallback({
    bool force = false,
    bool reinitializeInlineCameraAfterReturn = false,
  }) async {
    if (_isBusy && !force) return false;
    if (!_isCapturing && mounted) {
      setState(() => _isCapturing = true);
    }

    try {
      await _disposeCamera();
      if (!mounted) return false;
      await _captureRecovery.stageCaptureSession(
        activityId: _momentController.activityId,
        activityInstanceId: _momentController.activityInstanceId,
        completionLogId: _momentController.completionLogId,
      );

      final image = await _picker.pickImage(
        source: image_picker.ImageSource.camera,
        imageQuality: 82,
        maxWidth: 1280,
        maxHeight: 1280,
      );

      if (!mounted) return false;
      if (image == null) {
        await _captureRecovery.clearPendingCaptureSession();
        setState(() => _isCapturing = false);
        return false;
      }

      await _openPreviewWithImage(
        image.path,
        source: 'system_camera',
        clearBusyState: () => setState(() => _isCapturing = false),
        disposeCurrentCameraBeforePreview: false,
        reinitializeInlineCameraAfterReturn:
            reinitializeInlineCameraAfterReturn,
      );
      return true;
    } catch (_) {
      if (!mounted) return false;
      await _captureRecovery.clearPendingCaptureSession();
      setState(() => _isCapturing = false);
      Get.snackbar(
        currentL10n.captureUnavailableTitle,
        currentL10n.captureUnavailableMessage,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  Future<void> _openPreviewWithImage(
    String imagePath, {
    required String source,
    required VoidCallback clearBusyState,
    required bool disposeCurrentCameraBeforePreview,
    required bool reinitializeInlineCameraAfterReturn,
  }) async {
    await _captureRecovery.clearPendingCaptureSession();
    await AnalyticsService.instance.photoSelected(source);
    _momentController.attachImage(imagePath);

    if (disposeCurrentCameraBeforePreview) {
      await _disposeCamera();
      if (!mounted) return;
    }

    await Get.toNamed(AppRoutes.preview, arguments: {'imagePath': imagePath});
    if (!mounted) return;

    clearBusyState();
    if (reinitializeInlineCameraAfterReturn) {
      await _warmAndInitializeCamera();
    }
  }

  Future<void> _switchCamera() async {
    if (_isBusy || !_hasMultipleCameras) return;
    setState(() {
      _lensDirection = _lensDirection == CameraLensDirection.back
          ? CameraLensDirection.front
          : CameraLensDirection.back;
    });
    await _disposeCamera();
    await _warmAndInitializeCamera();
  }

  Future<bool> _handlePop() async {
    await _disposeCamera();
    _momentController.resetComposer();
    return true;
  }

  @override
  Widget build(BuildContext context) {
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
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(child: _buildCameraBody(context)),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _CaptureTopOverlay(
                  isProofMoment: _isProofMoment,
                  isBusy: _isBusy,
                  onClose: () async {
                    await _handlePop();
                    if (mounted) Get.back();
                  },
                  onSwitchCamera: _hasMultipleCameras ? _switchCamera : null,
                ),
              ),
              Positioned(
                left: AppSizes.space16,
                right: AppSizes.space16,
                bottom: AppSizes.space16,
                child: _CaptureBottomDock(
                  isProofMoment: _isProofMoment,
                  isBusy: _isBusy,
                  showGalleryAction: _showGalleryAction,
                  onGalleryTap: _pickFromGallery,
                  onCaptureTap: _captureInlinePhoto,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCameraBody(BuildContext context) {
    final l10n = context.l10n;
    final controller = _cameraController;

    if (_cameraError != null) {
      return _CameraFallbackState(
        title: l10n.captureUnavailableTitle,
        message: _cameraError == _inlineCaptureRejectedReason
            ? l10n.captureFallbackToSystemCameraMessage
            : l10n.captureUnavailableMessage,
        onOpenSystemCamera: _openSystemCameraFallback,
        onOpenGallery: _showGalleryAction ? _pickFromGallery : null,
      );
    }

    if (_isInitializingCamera ||
        controller == null ||
        !controller.value.isInitialized) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(height: AppSizes.space16),
            Text(
              l10n.captureOpeningProofCamera,
              style: AppTypography.bodyMedium(
                color: Colors.white.withValues(alpha: 0.82),
              ),
            ),
          ],
        ),
      );
    }

    return DecoratedBox(
      decoration: const BoxDecoration(color: Colors.black),
      child: Center(
        child: AspectRatio(
          aspectRatio: controller.value.aspectRatio,
          child: KeyedSubtree(
            key: ValueKey<Object>(controller),
            child: CameraPreview(controller),
          ),
        ),
      ),
    );
  }
}

class _CaptureTopOverlay extends StatelessWidget {
  const _CaptureTopOverlay({
    required this.isProofMoment,
    required this.isBusy,
    required this.onClose,
    this.onSwitchCamera,
  });

  final bool isProofMoment;
  final bool isBusy;
  final VoidCallback onClose;
  final VoidCallback? onSwitchCamera;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.space12,
        AppSizes.space8,
        AppSizes.space12,
        AppSizes.space12,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.52),
            Colors.black.withValues(alpha: 0.22),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _OverlayIconButton(icon: Icons.close_rounded, onTap: onClose),
          const SizedBox(width: AppSizes.space12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: AppSizes.space4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.space10,
                      vertical: AppSizes.space6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: AppSizes.borderRadiusFull,
                    ),
                    child: Text(
                      isProofMoment
                          ? context.l10n.captureHeroProofBadge
                          : context.l10n.captureHeroMomentBadge,
                      style: AppTypography.bodySmall(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: AppSizes.space10),
                  Text(
                    isProofMoment
                        ? context.l10n.captureHeroProofTitle
                        : context.l10n.captureHeroMomentTitle,
                    style: AppTypography.titleLarge(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          if (onSwitchCamera != null)
            _OverlayIconButton(
              icon: Icons.flip_camera_android_outlined,
              onTap: isBusy ? null : onSwitchCamera,
            ),
        ],
      ),
    );
  }
}

class _CaptureBottomDock extends StatelessWidget {
  const _CaptureBottomDock({
    required this.isProofMoment,
    required this.isBusy,
    required this.showGalleryAction,
    required this.onGalleryTap,
    required this.onCaptureTap,
  });

  final bool isProofMoment;
  final bool isBusy;
  final bool showGalleryAction;
  final VoidCallback onGalleryTap;
  final VoidCallback onCaptureTap;

  @override
  Widget build(BuildContext context) {
    final sideButton = SizedBox(
      width: 60,
      height: 60,
      child: showGalleryAction
          ? _OverlayCircleButton(
              icon: Icons.photo_library_outlined,
              onTap: isBusy ? null : onGalleryTap,
            )
          : const SizedBox.shrink(),
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.space16,
        AppSizes.space16,
        AppSizes.space16,
        AppSizes.space20,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.0),
            Colors.black.withValues(alpha: 0.28),
            Colors.black.withValues(alpha: 0.72),
          ],
        ),
        borderRadius: AppSizes.borderRadiusXl,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          sideButton,
          _CaptureShutterButton(isBusy: isBusy, onTap: onCaptureTap),
          SizedBox(
            width: 60,
            height: 60,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                isProofMoment
                    ? context.l10n.captureProofTitle
                    : context.l10n.captureMomentTitle,
                textAlign: TextAlign.right,
                style: AppTypography.bodySmall(
                  color: Colors.white.withValues(alpha: 0.84),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CaptureShutterButton extends StatelessWidget {
  const _CaptureShutterButton({required this.isBusy, required this.onTap});

  final bool isBusy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 92,
      height: 92,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(46),
          onTap: isBusy ? null : onTap,
          child: Ink(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.82),
                width: 4,
              ),
            ),
            child: Center(
              child: AnimatedContainer(
                duration: AppMotion.fast,
                width: isBusy ? 44 : 56,
                height: isBusy ? 44 : 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isBusy
                      ? Colors.white.withValues(alpha: 0.46)
                      : Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OverlayIconButton extends StatelessWidget {
  const _OverlayIconButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return _OverlayCircleButton(icon: icon, onTap: onTap);
  }
}

class _OverlayCircleButton extends StatelessWidget {
  const _OverlayCircleButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Ink(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.14),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Icon(icon, color: Colors.white),
        ),
      ),
    );
  }
}

class _CameraFallbackState extends StatelessWidget {
  const _CameraFallbackState({
    required this.title,
    required this.message,
    required this.onOpenSystemCamera,
    this.onOpenGallery,
  });

  final String title;
  final String message;
  final VoidCallback onOpenSystemCamera;
  final VoidCallback? onOpenGallery;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.space24),
        child: Container(
          padding: const EdgeInsets.all(AppSizes.space24),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: AppSizes.borderRadiusLg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.primaryFixed,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.camera_alt_outlined,
                  color: AppColors.primary,
                  size: 32,
                ),
              ),
              const SizedBox(height: AppSizes.space16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTypography.headlineSmall(color: AppColors.onSurface),
              ),
              const SizedBox(height: AppSizes.space8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSizes.space20),
              FilledButton.icon(
                onPressed: onOpenSystemCamera,
                icon: const Icon(Icons.photo_camera_outlined),
                label: Text(context.l10n.captureSourceCameraTitle),
              ),
              if (onOpenGallery != null) ...[
                const SizedBox(height: AppSizes.space12),
                OutlinedButton.icon(
                  onPressed: onOpenGallery,
                  icon: const Icon(Icons.photo_library_outlined),
                  label: Text(context.l10n.captureSourceGalleryTitle),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
