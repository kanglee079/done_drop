import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:done_drop/core/services/image_service.dart';

/// Helper widget to display images from various sources:
/// - Data URLs (data:image/xxx;base64,xxx) → MemoryImage
/// - Regular URLs → CachedNetworkImage
/// - Image IDs (from Firestore) → Load from ImageService
class DDImage extends StatefulWidget {
  const DDImage({
    super.key,
    required this.source,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
  });

  /// Source can be:
  /// - Data URL: data:image/jpeg;base64,xxxxx
  /// - Regular URL: https://example.com/image.jpg
  /// - Image ID: moment_1234567890 (will be loaded from ImageService)
  final String? source;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;

  @override
  State<DDImage> createState() => _DDImageState();
}

class _DDImageState extends State<DDImage> {
  Uint8List? _imageBytes;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(DDImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.source != widget.source) {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    if (widget.source == null || widget.source!.isEmpty) {
      setState(() {
        _isLoading = false;
        _error = 'No source';
      });
      return;
    }

    final source = widget.source!;

    // Data URL - decode directly
    if (source.startsWith('data:')) {
      _loadFromDataUrl(source);
      return;
    }

    // Regular URL - use CachedNetworkImage
    if (source.startsWith('http://') || source.startsWith('https://')) {
      setState(() {
        _isLoading = false;
        _imageBytes = null; // Signal to use CachedNetworkImage
      });
      return;
    }

    // Image ID - load from ImageService
    await _loadFromImageService(source);
  }

  void _loadFromDataUrl(String dataUrl) {
    try {
      final parts = dataUrl.split(',');
      if (parts.length == 2) {
        final bytes = Uri.parse(dataUrl).data?.contentAsBytes();
        if (bytes != null) {
          setState(() {
            _imageBytes = Uint8List.fromList(bytes);
            _isLoading = false;
          });
        } else {
          setState(() {
            _error = 'Invalid data';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadFromImageService(String imageId) async {
    try {
      final bytes = await ImageService.instance.getImageBytes(imageId);
      if (mounted) {
        setState(() {
          _imageBytes = bytes != null ? Uint8List.fromList(bytes) : null;
          _isLoading = false;
          if (bytes == null) {
            _error = 'Image not found';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.source == null || widget.source!.isEmpty) {
      return _buildPlaceholder();
    }

    final source = widget.source!;

    // Data URL - use MemoryImage
    if (source.startsWith('data:')) {
      if (_isLoading) return _buildPlaceholder();
      if (_imageBytes != null) {
        return _buildImage(MemoryImage(_imageBytes!));
      }
      return _buildError();
    }

    // Regular URL - use CachedNetworkImage
    if (source.startsWith('http://') || source.startsWith('https://')) {
      return _buildNetworkImage(source);
    }

    // Image ID - use our loaded bytes or placeholder
    if (_isLoading) return _buildPlaceholder();
    if (_imageBytes != null) {
      return _buildImage(MemoryImage(_imageBytes!));
    }
    return _buildError();
  }

  Widget _buildImage(ImageProvider image) {
    Widget child = Image(
      image: image,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      errorBuilder: (_, __, ___) => _buildError(),
    );

    if (widget.borderRadius != null) {
      child = ClipRRect(
        borderRadius: widget.borderRadius!,
        child: child,
      );
    }

    return child;
  }

  Widget _buildNetworkImage(String url) {
    Widget child = CachedNetworkImage(
      imageUrl: url,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      placeholder: (_, __) => widget.placeholder ?? _buildPlaceholder(),
      errorWidget: (_, __, ___) => widget.errorWidget ?? _buildError(),
    );

    if (widget.borderRadius != null) {
      child = ClipRRect(
        borderRadius: widget.borderRadius!,
        child: child,
      );
    }

    return child;
  }

  Widget _buildPlaceholder() {
    return widget.placeholder ??
        Container(
          width: widget.width,
          height: widget.height,
          color: Colors.grey[200],
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
  }

  Widget _buildError() {
    return widget.errorWidget ??
        Container(
          width: widget.width,
          height: widget.height,
          color: Colors.grey[200],
          child: const Icon(Icons.image_not_supported, color: Colors.grey),
        );
  }
}
