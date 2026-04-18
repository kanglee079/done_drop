import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:done_drop/app/routes/app_routes.dart';
import 'package:done_drop/core/theme/theme.dart';
import 'package:done_drop/l10n/l10n.dart';

class ScanCodeScreen extends StatefulWidget {
  const ScanCodeScreen({super.key});

  @override
  State<ScanCodeScreen> createState() => _ScanCodeScreenState();
}

class _ScanCodeScreenState extends State<ScanCodeScreen> {
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  bool _isProcessing = false;
  String? _lastScanned;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final raw = barcodes.first.rawValue ?? '';
    if (raw == _lastScanned) return;
    _lastScanned = raw;

    _isProcessing = true;

    // Parse QR data: donedrop://add?code=XXXXXX
    String? code;
    if (raw.startsWith('donedrop://add?code=')) {
      code = raw.substring('donedrop://add?code='.length);
    } else if (raw.length == 6) {
      // Plain 6-char code
      code = raw.toUpperCase();
    } else {
      code = raw.toUpperCase();
    }

    if (code.isEmpty) {
      Get.snackbar(
        context.l10n.invalidCodeError,
        '',
        snackPosition: SnackPosition.BOTTOM,
      );
      _isProcessing = false;
      return;
    }

    // Stop scanner
    await _scannerController.stop();

    // Navigate to add friend with code pre-filled
    Get.offNamed(
      AppRoutes.addFriend,
      arguments: {'prefillCode': code},
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          l10n.scanCodeTitle,
          style: AppTypography.titleMedium(color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: _scannerController,
              builder: (context, state, child) {
                return Icon(
                  state.torchState == TorchState.on
                      ? Icons.flash_on
                      : Icons.flash_off,
                  color: Colors.white,
                );
              },
            ),
            onPressed: () => _scannerController.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Scanner
          MobileScanner(
            controller: _scannerController,
            onDetect: _onDetect,
          ),

          // Overlay with cutout
          _ScannerOverlay(
            borderColor: AppColors.primary,
            overlayColor: Colors.black.withValues(alpha: 0.5),
          ),

          // Instructions
          Positioned(
            bottom: 120,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.space24,
                  vertical: AppSizes.space12,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: AppSizes.borderRadiusLg,
                ),
                child: Text(
                  l10n.scanCodeSubtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScannerOverlay extends StatelessWidget {
  const _ScannerOverlay({
    required this.borderColor,
    required this.overlayColor,
  });

  final Color borderColor;
  final Color overlayColor;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scanAreaSize = size.width * 0.7;

    return Stack(
      children: [
        // Top overlay
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: (size.height - scanAreaSize) / 2,
          child: Container(color: overlayColor),
        ),
        // Bottom overlay
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: (size.height - scanAreaSize) / 2,
          child: Container(color: overlayColor),
        ),
        // Left overlay
        Positioned(
          top: (size.height - scanAreaSize) / 2,
          left: 0,
          width: (size.width - scanAreaSize) / 2,
          height: scanAreaSize,
          child: Container(color: overlayColor),
        ),
        // Right overlay
        Positioned(
          top: (size.height - scanAreaSize) / 2,
          right: 0,
          width: (size.width - scanAreaSize) / 2,
          height: scanAreaSize,
          child: Container(color: overlayColor),
        ),

        // Corner brackets
        Center(
          child: SizedBox(
            width: scanAreaSize,
            height: scanAreaSize,
            child: Stack(
              children: [
                // Top-left corner
                Positioned(
                  top: 0,
                  left: 0,
                  child: _CornerBracket(
                    color: borderColor,
                    corner: _Corner.topLeft,
                  ),
                ),
                // Top-right corner
                Positioned(
                  top: 0,
                  right: 0,
                  child: _CornerBracket(
                    color: borderColor,
                    corner: _Corner.topRight,
                  ),
                ),
                // Bottom-left corner
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: _CornerBracket(
                    color: borderColor,
                    corner: _Corner.bottomLeft,
                  ),
                ),
                // Bottom-right corner
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: _CornerBracket(
                    color: borderColor,
                    corner: _Corner.bottomRight,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

enum _Corner { topLeft, topRight, bottomLeft, bottomRight }

class _CornerBracket extends StatelessWidget {
  const _CornerBracket({required this.color, required this.corner});

  final Color color;
  final _Corner corner;

  @override
  Widget build(BuildContext context) {
    const size = 32.0;
    const thickness = 4.0;

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CornerPainter(
          color: color,
          corner: corner,
          thickness: thickness,
        ),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  const _CornerPainter({
    required this.color,
    required this.corner,
    required this.thickness,
  });

  final Color color;
  final _Corner corner;
  final double thickness;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();

    switch (corner) {
      case _Corner.topLeft:
        path.moveTo(0, size.height);
        path.lineTo(0, 0);
        path.lineTo(size.width, 0);
        break;
      case _Corner.topRight:
        path.moveTo(0, 0);
        path.lineTo(size.width, 0);
        path.lineTo(size.width, size.height);
        break;
      case _Corner.bottomLeft:
        path.moveTo(0, 0);
        path.lineTo(0, size.height);
        path.lineTo(size.width, size.height);
        break;
      case _Corner.bottomRight:
        path.moveTo(0, size.height);
        path.lineTo(size.width, size.height);
        path.lineTo(size.width, 0);
        break;
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
