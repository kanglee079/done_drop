import 'package:camera/camera.dart';

class CaptureCameraService {
  CaptureCameraService();

  List<CameraDescription>? _cachedCameras;
  Future<List<CameraDescription>>? _loadingFuture;

  Future<List<CameraDescription>> warmAvailableCameras() {
    if (_cachedCameras != null) {
      return Future<List<CameraDescription>>.value(_cachedCameras!);
    }
    return _loadingFuture ??= _loadAvailableCameras();
  }

  Future<List<CameraDescription>> _loadAvailableCameras() async {
    try {
      final cameras = await availableCameras();
      _cachedCameras = cameras;
      return cameras;
    } finally {
      _loadingFuture = null;
    }
  }

  Future<bool> hasMultipleCameras() async {
    final cameras = await warmAvailableCameras();
    return cameras.length > 1;
  }

  Future<CameraDescription> preferredCamera({
    CameraLensDirection preferredDirection = CameraLensDirection.back,
  }) async {
    final cameras = await warmAvailableCameras();
    if (cameras.isEmpty) {
      throw CameraException('no-camera', 'No camera available on this device.');
    }

    return cameras.firstWhere(
      (camera) => camera.lensDirection == preferredDirection,
      orElse: () => cameras.first,
    );
  }

  Future<CameraController> createController({
    CameraLensDirection lensDirection = CameraLensDirection.back,
    ResolutionPreset resolutionPreset = ResolutionPreset.medium,
  }) async {
    final camera = await preferredCamera(preferredDirection: lensDirection);
    final controller = CameraController(
      camera,
      resolutionPreset,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await controller.initialize();
    await controller.setFlashMode(FlashMode.off);
    return controller;
  }
}
