import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

import 'package:done_drop/core/services/capture_camera_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late CaptureCameraService service;

  Future<String> writeJpg(img.Image image, String name) async {
    final file = File('${tempDir.path}/$name.jpg');
    await file.writeAsBytes(img.encodeJpg(image, quality: 90));
    return file.path;
  }

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp(
      'capture_camera_service_test',
    );
    service = CaptureCameraService();
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('rejects missing files', () async {
    final result = await service.validateCaptureFile(
      '${tempDir.path}/missing.jpg',
    );

    expect(result.isUsable, isFalse);
    expect(result.reason, 'missing_file');
  });

  test('rejects near-black captures', () async {
    final image = img.Image(width: 160, height: 200);
    img.fill(image, color: img.ColorRgb8(0, 0, 0));
    final path = await writeJpg(image, 'black');

    final result = await service.validateCaptureFile(path);

    expect(result.isUsable, isFalse);
    expect(
      result.reason,
      anyOf('near_black_capture', 'too_small', 'too_small_dimensions'),
    );
    if (result.reason == 'near_black_capture') {
      expect(result.darkPixelRatio, greaterThan(0.98));
    }
  });

  test('keeps real captures usable', () async {
    final image = img.Image(width: 160, height: 200);
    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        image.setPixelRgba(
          x,
          y,
          (60 + (x % 120)).clamp(0, 255),
          (40 + (y % 140)).clamp(0, 255),
          180,
          255,
        );
      }
    }
    final path = await writeJpg(image, 'real');

    final result = await service.validateCaptureFile(path);

    expect(result.isUsable, isTrue);
    expect(result.reason, 'ok');
    expect(result.averageLuminance, greaterThan(20));
  });
}
