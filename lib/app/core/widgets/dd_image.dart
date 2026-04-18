import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:done_drop/core/services/media_service.dart';

/// Helper widget to display images from various sources:
/// - Data URLs (data:image/xxx;base64,xxx) → MemoryImage
/// - HTTP/HTTPS URLs → CachedNetworkImage
/// - Storage paths → loaded from MediaService (Firebase Storage)
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
  /// - Regular URL: https://example.com/image.jpg (Firebase Storage download URL)
  /// - Storage path: avatars/uid/avatar.jpg or moments/uid/mid/original.jpg
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
      setState(() => _isLoading = false);
      return;
    }

    final source = widget.source!;

    if (source.startsWith('data:')) {
      _loadFromDataUrl(source);
      return;
    }

    if (source.startsWith('http://') || source.startsWith('https://')) {
      setState(() {
        _isLoading = false;
        _imageBytes = null;
      });
      return;
    }

    await _loadFromStorage(source);
  }

  void _loadFromDataUrl(String dataUrl) {
    try {
      final bytes = Uri.parse(dataUrl).data?.contentAsBytes();
      if (mounted) {
        setState(() {
          _imageBytes = bytes != null ? Uint8List.fromList(bytes) : null;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadFromStorage(String storagePath) async {
    try {
      final bytes = await MediaService.instance.getBytes(storagePath);
      if (mounted) {
        setState(() {
          _imageBytes = bytes != null ? Uint8List.fromList(bytes) : null;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.source == null || widget.source!.isEmpty) {
      return _buildPlaceholder();
    }

    final source = widget.source!;

    if (source.startsWith('data:')) {
      if (_isLoading) return _buildPlaceholder();
      if (_imageBytes != null) return _buildImage(MemoryImage(_imageBytes!));
      return _buildError();
    }

    if (source.startsWith('http://') || source.startsWith('https://')) {
      return _buildNetworkImage(source);
    }

    if (_isLoading) return _buildPlaceholder();
    if (_imageBytes != null) return _buildImage(MemoryImage(_imageBytes!));
    return _buildError();
  }

  Widget _buildImage(ImageProvider image) {
    Widget child = Image(
      image: image,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      errorBuilder: (context, error, stackTrace) => _buildError(),
    );

    if (widget.borderRadius != null) {
      child = ClipRRect(borderRadius: widget.borderRadius!, child: child);
    }

    return child;
  }

  Widget _buildNetworkImage(String url) {
    Widget child = CachedNetworkImage(
      imageUrl: url,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      placeholder: (context, url) => widget.placeholder ?? _buildPlaceholder(),
      errorWidget: (context, url, error) => widget.errorWidget ?? _buildError(),
    );

    if (widget.borderRadius != null) {
      child = ClipRRect(borderRadius: widget.borderRadius!, child: child);
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
