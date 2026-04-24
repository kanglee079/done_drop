import 'dart:io';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

class CaptureValidationResult {
  const CaptureValidationResult({
    required this.isUsable,
    required this.reason,
    required this.averageLuminance,
    required this.darkPixelRatio,
    required this.luminanceStdDev,
  });

  final bool isUsable;
  final String reason;
  final double averageLuminance;
  final double darkPixelRatio;
  final double luminanceStdDev;
}

Map<String, Object> _validateCaptureFileSync(String path) {
  final file = File(path);
  if (!file.existsSync()) {
    return {
      'isUsable': false,
      'reason': 'missing_file',
      'averageLuminance': 0.0,
      'darkPixelRatio': 1.0,
      'luminanceStdDev': 0.0,
    };
  }

  final bytes = file.readAsBytesSync();
  if (bytes.length < 4096) {
    return {
      'isUsable': false,
      'reason': 'too_small',
      'averageLuminance': 0.0,
      'darkPixelRatio': 1.0,
      'luminanceStdDev': 0.0,
    };
  }

  final decoded = img.decodeImage(bytes);
  if (decoded == null) {
    return {
      'isUsable': false,
      'reason': 'decode_failed',
      'averageLuminance': 0.0,
      'darkPixelRatio': 1.0,
      'luminanceStdDev': 0.0,
    };
  }

  if (decoded.width < 64 || decoded.height < 64) {
    return {
      'isUsable': false,
      'reason': 'too_small_dimensions',
      'averageLuminance': 0.0,
      'darkPixelRatio': 1.0,
      'luminanceStdDev': 0.0,
    };
  }

  final stepX = math.max(1, decoded.width ~/ 24);
  final stepY = math.max(1, decoded.height ~/ 24);

  var sampled = 0;
  var darkPixels = 0;
  var sum = 0.0;
  var sumSquares = 0.0;

  for (var y = 0; y < decoded.height; y += stepY) {
    for (var x = 0; x < decoded.width; x += stepX) {
      final luminance = decoded.getPixel(x, y).luminance.toDouble();
      sampled++;
      sum += luminance;
      sumSquares += luminance * luminance;
      if (luminance <= 10) {
        darkPixels++;
      }
    }
  }

  if (sampled == 0) {
    return {
      'isUsable': false,
      'reason': 'no_samples',
      'averageLuminance': 0.0,
      'darkPixelRatio': 1.0,
      'luminanceStdDev': 0.0,
    };
  }

  final average = sum / sampled;
  final darkRatio = darkPixels / sampled;
  final variance = math.max(0.0, (sumSquares / sampled) - (average * average));
  final stdDev = math.sqrt(variance);
  final isNearBlack = average <= 8 && darkRatio >= 0.985 && stdDev <= 6;

  return {
    'isUsable': !isNearBlack,
    'reason': isNearBlack ? 'near_black_capture' : 'ok',
    'averageLuminance': average,
    'darkPixelRatio': darkRatio,
    'luminanceStdDev': stdDev,
  };
}

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
    ResolutionPreset resolutionPreset = ResolutionPreset.high,
  }) async {
    final camera = await preferredCamera(preferredDirection: lensDirection);
    final presets = <ResolutionPreset>{
      resolutionPreset,
      ResolutionPreset.high,
      ResolutionPreset.medium,
      ResolutionPreset.low,
    }.toList(growable: false);

    CameraException? lastError;
    for (final preset in presets) {
      final controller = CameraController(
        camera,
        preset,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      try {
        await controller.initialize();
        await controller.setFlashMode(FlashMode.off);
        return controller;
      } on CameraException catch (error) {
        lastError = error;
        await controller.dispose();
      } catch (error) {
        await controller.dispose();
        throw CameraException(
          'camera-init-failed',
          'Failed to initialize camera: $error',
        );
      }
    }

    throw lastError ??
        CameraException(
          'camera-init-failed',
          'Failed to initialize camera on this device.',
        );
  }

  Future<CaptureValidationResult> validateCaptureFile(String path) async {
    final raw = await compute(_validateCaptureFileSync, path);
    return CaptureValidationResult(
      isUsable: raw['isUsable'] as bool? ?? false,
      reason: raw['reason'] as String? ?? 'unknown',
      averageLuminance: raw['averageLuminance'] as double? ?? 0,
      darkPixelRatio: raw['darkPixelRatio'] as double? ?? 1,
      luminanceStdDev: raw['luminanceStdDev'] as double? ?? 0,
    );
  }
}
