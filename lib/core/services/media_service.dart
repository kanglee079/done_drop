import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show compute;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:done_drop/core/models/moment.dart'
    show MediaMetadata, MomentMediaMetadata;

// ── Isolate Processing ──────────────────────────────────────────────────────
// Must be top-level functions (not instance methods) for compute().

/// Data passed to the isolate for image processing.
class _ImageProcessRequest {
  final Uint8List sourceBytes;
  final int maxOriginalWidth;
  final int maxOriginalHeight;
  final int thumbnailWidth;
  final int originalQuality;
  final int thumbQuality;

  _ImageProcessRequest({
    required this.sourceBytes,
    required this.maxOriginalWidth,
    required this.maxOriginalHeight,
    required this.thumbnailWidth,
    required this.originalQuality,
    required this.thumbQuality,
  });
}

/// Result from the isolate image processing.
class _ImageProcessResult {
  final Uint8List originalBytes;
  final Uint8List thumbBytes;
  final int origWidth;
  final int origHeight;
  final int thumbWidth;
  final int thumbHeight;

  _ImageProcessResult({
    required this.originalBytes,
    required this.thumbBytes,
    required this.origWidth,
    required this.origHeight,
    required this.thumbWidth,
    required this.thumbHeight,
  });
}

enum MediaUploadStage { preparing, uploading, finalizing, complete }

class MomentUploadProgress {
  const MomentUploadProgress({
    required this.stage,
    required this.progress,
    this.bytesTransferred = 0,
    this.totalBytes = 0,
  });

  final MediaUploadStage stage;
  final double progress;
  final int bytesTransferred;
  final int totalBytes;
}

class _PreparedMomentImages {
  const _PreparedMomentImages({
    required this.originalBytes,
    required this.thumbBytes,
    required this.originalWidth,
    required this.originalHeight,
    required this.thumbnailWidth,
    required this.thumbnailHeight,
  });

  final Uint8List originalBytes;
  final Uint8List thumbBytes;
  final int originalWidth;
  final int originalHeight;
  final int thumbnailWidth;
  final int thumbnailHeight;
}

class _PreparedOriginalImage {
  const _PreparedOriginalImage({
    required this.originalBytes,
    required this.originalWidth,
    required this.originalHeight,
  });

  final Uint8List originalBytes;
  final int originalWidth;
  final int originalHeight;
}

class _OriginalImageProcessResult {
  const _OriginalImageProcessResult({
    required this.originalBytes,
    required this.origWidth,
    required this.origHeight,
  });

  final Uint8List originalBytes;
  final int origWidth;
  final int origHeight;
}

/// Top-level function that runs in a separate isolate.
/// Decodes once, resizes twice, encodes twice — all off the main thread.
_ImageProcessResult _processImageInIsolate(_ImageProcessRequest req) {
  final decoded = img.decodeImage(req.sourceBytes);
  if (decoded == null) {
    throw Exception('Failed to decode image');
  }

  // Resize original
  int ow = decoded.width, oh = decoded.height;
  if (ow > req.maxOriginalWidth || oh > req.maxOriginalHeight) {
    final r = (req.maxOriginalWidth / ow) < (req.maxOriginalHeight / oh)
        ? req.maxOriginalWidth / ow
        : req.maxOriginalHeight / oh;
    ow = (ow * r).round();
    oh = (oh * r).round();
  }
  final originalImage = img.copyResize(decoded, width: ow, height: oh);

  // Resize thumbnail
  final thumbMaxH = (req.thumbnailWidth * 1.5).round();
  int tw = decoded.width, th = decoded.height;
  if (tw > req.thumbnailWidth || th > thumbMaxH) {
    final r = (req.thumbnailWidth / tw) < (thumbMaxH / th)
        ? req.thumbnailWidth / tw
        : thumbMaxH / th;
    tw = (tw * r).round();
    th = (th * r).round();
  }
  final thumbImage = img.copyResize(decoded, width: tw, height: th);

  return _ImageProcessResult(
    originalBytes: Uint8List.fromList(
      img.encodeJpg(originalImage, quality: req.originalQuality),
    ),
    thumbBytes: Uint8List.fromList(
      img.encodeJpg(thumbImage, quality: req.thumbQuality),
    ),
    origWidth: originalImage.width,
    origHeight: originalImage.height,
    thumbWidth: thumbImage.width,
    thumbHeight: thumbImage.height,
  );
}

_OriginalImageProcessResult _processOriginalImageInIsolate(
  _ImageProcessRequest req,
) {
  final decoded = img.decodeImage(req.sourceBytes);
  if (decoded == null) {
    throw Exception('Failed to decode image');
  }

  int ow = decoded.width, oh = decoded.height;
  if (ow > req.maxOriginalWidth || oh > req.maxOriginalHeight) {
    final r = (req.maxOriginalWidth / ow) < (req.maxOriginalHeight / oh)
        ? req.maxOriginalWidth / ow
        : req.maxOriginalHeight / oh;
    ow = (ow * r).round();
    oh = (oh * r).round();
  }

  final originalImage = img.copyResize(decoded, width: ow, height: oh);

  return _OriginalImageProcessResult(
    originalBytes: Uint8List.fromList(
      img.encodeJpg(originalImage, quality: req.originalQuality),
    ),
    origWidth: originalImage.width,
    origHeight: originalImage.height,
  );
}

/// Service for managing media uploads to Firebase Storage.
///
/// Storage path structure:
///   /avatars/{userId}/avatar.jpg
///   /moments/{userId}/{momentId}/original.jpg
///   /moments/{userId}/{momentId}/thumb.jpg
///
/// Firestore stores only metadata (path, download URLs, dimensions, mimeType).
/// Images are NEVER stored as base64 in Firestore.
class MediaService {
  MediaService._();
  static final MediaService instance = MediaService._();

  final _storage = FirebaseStorage.instance;
  final Map<String, Future<_PreparedMomentImages>> _preparedMomentImages = {};
  final Map<String, Future<_PreparedOriginalImage>> _preparedOriginalImages =
      {};

  static const int _maxOriginalWidth =
      960; // Optimized for fast mobile upload without visible loss
  static const int _maxOriginalHeight = 960;
  static const int _thumbnailWidth = 280;
  static const int _thumbnailHeight = 420;
  static const int _originalQuality =
      72; // Lower network cost while keeping proof readable
  static const int _thumbQuality = 56;
  static const int _maxAvatarSizeBytes = 5 * 1024 * 1024; // 5MB
  static const int _maxMomentSizeBytes = 10 * 1024 * 1024; // 10MB
  static const bool _useServerGeneratedThumbnails = bool.fromEnvironment(
    'DD_USE_SERVER_THUMBNAILS',
    defaultValue: false,
  );
  static const Duration _generatedThumbnailPollDelay = Duration(
    milliseconds: 800,
  );
  static const int _generatedThumbnailMaxAttempts = 6;

  bool get usesServerGeneratedThumbnails => _useServerGeneratedThumbnails;

  void warmMomentUpload(String localFilePath) {
    if (localFilePath.isEmpty) return;

    if (_useServerGeneratedThumbnails) {
      _preparedOriginalImages.putIfAbsent(
        localFilePath,
        () => _prepareOriginalMomentImage(localFilePath),
      );
      return;
    }

    _preparedMomentImages.putIfAbsent(
      localFilePath,
      () => _prepareMomentImages(localFilePath),
    );
  }

  void discardPreparedUpload(String localFilePath) {
    // Only clear the map that was actually populated by warmMomentUpload.
    // This prevents leaving orphaned entries when server thumbnails are enabled.
    if (_useServerGeneratedThumbnails) {
      _preparedOriginalImages.remove(localFilePath);
    } else {
      _preparedMomentImages.remove(localFilePath);
    }
  }

  // ── Local Cache ───────────────────────────────────────────────────────────

  Future<Directory> get _cacheDir async {
    final appDir = await getApplicationDocumentsDirectory();
    final cache = Directory('${appDir.path}/media_cache');
    if (!await cache.exists()) await cache.create(recursive: true);
    return cache;
  }

  Future<String> _localPath(String path) async {
    final dir = await _cacheDir;
    // Sanitize path for use as filename
    final safe = path.replaceAll('/', '_').replaceAll(':', '_');
    return '${dir.path}/$safe';
  }

  Future<void> _cacheLocally(String storagePath, Uint8List bytes) async {
    try {
      final localFile = File(await _localPath(storagePath));
      await localFile.writeAsBytes(bytes);
    } catch (_) {}
  }

  Future<Uint8List?> _getCachedBytes(String storagePath) async {
    try {
      final file = File(await _localPath(storagePath));
      if (await file.exists()) return await file.readAsBytes();
    } catch (_) {}
    return null;
  }

  // ── Image Processing ──────────────────────────────────────────────────────

  Future<Uint8List> _resizeAndCompress(
    String filePath, {
    required int maxWidth,
    required int maxHeight,
    required int quality,
  }) async {
    final file = File(filePath);
    Uint8List bytes = await file.readAsBytes();

    final image = img.decodeImage(bytes);
    if (image == null) return bytes;

    int targetWidth = image.width;
    int targetHeight = image.height;

    if (targetWidth > maxWidth || targetHeight > maxHeight) {
      final ratioW = maxWidth / targetWidth;
      final ratioH = maxHeight / targetHeight;
      final ratio = ratioW < ratioH ? ratioW : ratioH;
      targetWidth = (targetWidth * ratio).round();
      targetHeight = (targetHeight * ratio).round();
    }

    final resized = img.copyResize(
      image,
      width: targetWidth,
      height: targetHeight,
    );

    return Uint8List.fromList(img.encodeJpg(resized, quality: quality));
  }

  // ── Upload Helpers ────────────────────────────────────────────────────────

  Future<_MediaUploadResult> _uploadBytes(
    String path,
    Uint8List bytes, {
    required String mimeType,
  }) async {
    final ref = _storage.ref().child(path);

    final metadata = SettableMetadata(
      contentType: mimeType,
      cacheControl: 'private, max-age=31536000',
    );

    final task = ref.putData(bytes, metadata);
    final snapshot = await task;
    final downloadUrl = await snapshot.ref.getDownloadURL();

    return _MediaUploadResult(
      storagePath: path,
      downloadUrl: downloadUrl,
      bytesUploaded: bytes.length,
    );
  }

  // ── Avatar ───────────────────────────────────────────────────────────────

  /// Upload avatar image. Returns metadata for Firestore.
  Future<MediaMetadata> uploadAvatar({
    required String userId,
    required String localFilePath,
  }) async {
    final bytes = await _resizeAndCompress(
      localFilePath,
      maxWidth: 512,
      maxHeight: 512,
      quality: _originalQuality,
    );

    if (bytes.length > _maxAvatarSizeBytes) {
      throw MediaUploadException('Avatar exceeds maximum size of 5MB');
    }

    final path = 'avatars/$userId/avatar.jpg';
    final result = await _uploadBytes(path, bytes, mimeType: 'image/jpeg');

    await _cacheLocally(path, bytes);

    return MediaMetadata(
      storagePath: result.storagePath,
      downloadUrl: result.downloadUrl,
      mimeType: 'image/jpeg',
      width: 512,
      height: 512,
      bytesUploaded: result.bytesUploaded,
      ownerId: userId,
    );
  }

  /// Delete avatar from Storage.
  Future<void> deleteAvatar(String userId) async {
    try {
      await _storage.ref().child('avatars/$userId/avatar.jpg').delete();
    } catch (_) {}
  }

  // ── Moment Images ────────────────────────────────────────────────────────

  /// Upload moment images (original + thumbnail). Returns metadata for Firestore.
  ///
  /// Performance optimizations:
  ///   1. Decode + resize + encode in a BACKGROUND ISOLATE (no UI jank)
  ///   2. Upload original + thumbnail in PARALLEL (Future.wait)
  ///   3. Cache both files in PARALLEL (non-blocking)
  Future<MomentMediaMetadata> uploadMomentImages({
    required String userId,
    required String momentId,
    required String localFilePath,
    void Function(MomentUploadProgress progress)? onProgress,
  }) async {
    onProgress?.call(
      const MomentUploadProgress(
        stage: MediaUploadStage.preparing,
        progress: 0,
      ),
    );

    if (_useServerGeneratedThumbnails) {
      return _uploadWithServerGeneratedThumbnail(
        userId: userId,
        momentId: momentId,
        localFilePath: localFilePath,
        onProgress: onProgress,
      );
    }

    final prepared = await _consumePreparedMomentImages(localFilePath);

    if (prepared.originalBytes.length > _maxMomentSizeBytes) {
      throw MediaUploadException('Moment image exceeds maximum size of 10MB');
    }

    final originalPath = 'moments/$userId/$momentId/original.jpg';
    final thumbPath = 'moments/$userId/$momentId/thumb.jpg';
    final originalRef = _storage.ref().child(originalPath);
    final thumbRef = _storage.ref().child(thumbPath);
    final metadata = SettableMetadata(
      contentType: 'image/jpeg',
      cacheControl: 'private, max-age=31536000',
    );

    final totalBytes =
        prepared.originalBytes.length + prepared.thumbBytes.length;
    var originalTransferred = 0;
    var thumbTransferred = 0;

    void emitUploadProgress() {
      final transferred = originalTransferred + thumbTransferred;
      final progress = totalBytes == 0 ? 0.0 : transferred / totalBytes;
      onProgress?.call(
        MomentUploadProgress(
          stage: MediaUploadStage.uploading,
          progress: progress.clamp(0, 1),
          bytesTransferred: transferred,
          totalBytes: totalBytes,
        ),
      );
    }

    emitUploadProgress();

    final originalTask = originalRef.putData(prepared.originalBytes, metadata);
    final thumbTask = thumbRef.putData(prepared.thumbBytes, metadata);

    originalTask.snapshotEvents.listen((snapshot) {
      originalTransferred = snapshot.bytesTransferred;
      emitUploadProgress();
    });
    thumbTask.snapshotEvents.listen((snapshot) {
      thumbTransferred = snapshot.bytesTransferred;
      emitUploadProgress();
    });

    final results = await Future.wait([originalTask, thumbTask]);

    final originalSnapshot = results[0];
    final thumbSnapshot = results[1];
    final downloadUrls = await Future.wait([
      originalSnapshot.ref.getDownloadURL(),
      thumbSnapshot.ref.getDownloadURL(),
    ]);
    final originalDownloadUrl = downloadUrls[0];
    final thumbDownloadUrl = downloadUrls[1];
    onProgress?.call(
      const MomentUploadProgress(
        stage: MediaUploadStage.finalizing,
        progress: 1,
      ),
    );

    unawaited(
      Future.wait([
        _cacheLocally(originalPath, prepared.originalBytes),
        _cacheLocally(thumbPath, prepared.thumbBytes),
      ]),
    );

    final media = MomentMediaMetadata(
      original: MediaMetadata(
        storagePath: originalPath,
        downloadUrl: originalDownloadUrl,
        mimeType: 'image/jpeg',
        width: prepared.originalWidth,
        height: prepared.originalHeight,
        bytesUploaded: prepared.originalBytes.length,
        ownerId: userId,
        momentId: momentId,
      ),
      thumbnail: MediaMetadata(
        storagePath: thumbPath,
        downloadUrl: thumbDownloadUrl,
        mimeType: 'image/jpeg',
        width: prepared.thumbnailWidth,
        height: prepared.thumbnailHeight,
        bytesUploaded: prepared.thumbBytes.length,
        ownerId: userId,
        momentId: momentId,
      ),
    );

    onProgress?.call(
      const MomentUploadProgress(stage: MediaUploadStage.complete, progress: 1),
    );
    return media;
  }

  Future<MomentMediaMetadata> _uploadWithServerGeneratedThumbnail({
    required String userId,
    required String momentId,
    required String localFilePath,
    void Function(MomentUploadProgress progress)? onProgress,
  }) async {
    final prepared = await _consumePreparedOriginalImage(localFilePath);

    if (prepared.originalBytes.length > _maxMomentSizeBytes) {
      throw MediaUploadException('Moment image exceeds maximum size of 10MB');
    }

    final originalPath = 'moments/$userId/$momentId/original.jpg';
    final thumbnailPath = _generatedThumbnailPath(originalPath);
    final originalRef = _storage.ref().child(originalPath);
    final metadata = SettableMetadata(
      contentType: 'image/jpeg',
      cacheControl: 'private, max-age=31536000',
    );

    final totalBytes = prepared.originalBytes.length;

    final originalTask = originalRef.putData(prepared.originalBytes, metadata);
    originalTask.snapshotEvents.listen((snapshot) {
      final transferred = snapshot.bytesTransferred;
      final progress = totalBytes == 0 ? 0.0 : transferred / totalBytes;
      onProgress?.call(
        MomentUploadProgress(
          stage: MediaUploadStage.uploading,
          progress: progress.clamp(0, 1),
          bytesTransferred: transferred,
          totalBytes: totalBytes,
        ),
      );
    });

    final originalSnapshot = await originalTask;
    final originalDownloadUrl = await originalSnapshot.ref.getDownloadURL();

    onProgress?.call(
      const MomentUploadProgress(
        stage: MediaUploadStage.finalizing,
        progress: 1,
      ),
    );

    unawaited(_cacheLocally(originalPath, prepared.originalBytes));

    final media = MomentMediaMetadata(
      original: MediaMetadata(
        storagePath: originalPath,
        downloadUrl: originalDownloadUrl,
        mimeType: 'image/jpeg',
        width: prepared.originalWidth,
        height: prepared.originalHeight,
        bytesUploaded: prepared.originalBytes.length,
        ownerId: userId,
        momentId: momentId,
      ),
      thumbnail: MediaMetadata(
        storagePath: thumbnailPath,
        downloadUrl: '',
        mimeType: 'image/jpeg',
        width: _thumbnailWidth,
        height: _thumbnailHeight,
        bytesUploaded: 0,
        ownerId: userId,
        momentId: momentId,
      ),
    );

    onProgress?.call(
      const MomentUploadProgress(stage: MediaUploadStage.complete, progress: 1),
    );
    return media;
  }

  /// Delete all images for a moment.
  Future<void> deleteMomentImages(String userId, String momentId) async {
    try {
      await _storage
          .ref()
          .child('moments/$userId/$momentId/original.jpg')
          .delete();
    } catch (_) {}
    try {
      await _storage
          .ref()
          .child('moments/$userId/$momentId/thumb.jpg')
          .delete();
    } catch (_) {}
    try {
      await _storage
          .ref()
          .child(
            _generatedThumbnailPath('moments/$userId/$momentId/original.jpg'),
          )
          .delete();
    } catch (_) {}
  }

  Future<MediaMetadata?> waitForGeneratedThumbnail({
    required MediaMetadata original,
    int maxAttempts = _generatedThumbnailMaxAttempts,
    Duration pollDelay = _generatedThumbnailPollDelay,
  }) async {
    if (!_useServerGeneratedThumbnails) {
      return null;
    }

    final thumbnailPath = _generatedThumbnailPath(original.storagePath);
    final ref = _storage.ref().child(thumbnailPath);

    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        final downloadUrl = await ref.getDownloadURL();
        return MediaMetadata(
          storagePath: thumbnailPath,
          downloadUrl: downloadUrl,
          mimeType: 'image/jpeg',
          width: _thumbnailWidth,
          height: _thumbnailHeight,
          bytesUploaded: 0,
          ownerId: original.ownerId,
          momentId: original.momentId,
        );
      } catch (_) {
        if (attempt == maxAttempts - 1) return null;
        await Future<void>.delayed(pollDelay);
      }
    }

    return null;
  }

  Future<_PreparedMomentImages> _prepareMomentImages(
    String localFilePath,
  ) async {
    final nativePrepared = await _prepareMomentImagesWithNativeCompression(
      localFilePath,
    );
    if (nativePrepared != null) {
      return nativePrepared;
    }

    final sourceBytes = await File(localFilePath).readAsBytes();
    final processed = await compute(
      _processImageInIsolate,
      _ImageProcessRequest(
        sourceBytes: sourceBytes,
        maxOriginalWidth: _maxOriginalWidth,
        maxOriginalHeight: _maxOriginalHeight,
        thumbnailWidth: _thumbnailWidth,
        originalQuality: _originalQuality,
        thumbQuality: _thumbQuality,
      ),
    );

    return _PreparedMomentImages(
      originalBytes: processed.originalBytes,
      thumbBytes: processed.thumbBytes,
      originalWidth: processed.origWidth,
      originalHeight: processed.origHeight,
      thumbnailWidth: processed.thumbWidth,
      thumbnailHeight: processed.thumbHeight,
    );
  }

  Future<_PreparedOriginalImage> _prepareOriginalMomentImage(
    String localFilePath,
  ) async {
    final nativePrepared = await _prepareOriginalMomentImageWithNativeCompression(
      localFilePath,
    );
    if (nativePrepared != null) {
      return nativePrepared;
    }

    final sourceBytes = await File(localFilePath).readAsBytes();
    final processed = await compute(
      _processOriginalImageInIsolate,
      _ImageProcessRequest(
        sourceBytes: sourceBytes,
        maxOriginalWidth: _maxOriginalWidth,
        maxOriginalHeight: _maxOriginalHeight,
        thumbnailWidth: _thumbnailWidth,
        originalQuality: _originalQuality,
        thumbQuality: _thumbQuality,
      ),
    );

    return _PreparedOriginalImage(
      originalBytes: processed.originalBytes,
      originalWidth: processed.origWidth,
      originalHeight: processed.origHeight,
    );
  }

  Future<_PreparedMomentImages?> _prepareMomentImagesWithNativeCompression(
    String localFilePath,
  ) async {
    if (!(Platform.isAndroid || Platform.isIOS || Platform.isMacOS)) {
      return null;
    }

    Future<Uint8List?> compress({
      required int minWidth,
      required int minHeight,
      required int quality,
      required int inSampleSize,
    }) async {
      final bytes = await FlutterImageCompress.compressWithFile(
        localFilePath,
        minWidth: minWidth,
        minHeight: minHeight,
        quality: quality,
        inSampleSize: inSampleSize,
        format: CompressFormat.jpeg,
        autoCorrectionAngle: true,
        keepExif: false,
      );
      if (bytes == null || bytes.isEmpty) return null;
      return Uint8List.fromList(bytes);
    }

    try {
      final results = await Future.wait([
        compress(
          minWidth: _maxOriginalWidth,
          minHeight: _maxOriginalHeight,
          quality: _originalQuality,
          inSampleSize: 1,
        ),
        compress(
          minWidth: _thumbnailWidth,
          minHeight: _thumbnailHeight,
          quality: _thumbQuality,
          inSampleSize: 2,
        ),
      ]);

      final originalBytes = results[0];
      final thumbBytes = results[1];
      if (originalBytes == null || thumbBytes == null) {
        return null;
      }

      final originalImage = img.decodeImage(originalBytes);
      final thumbImage = img.decodeImage(thumbBytes);
      if (originalImage == null || thumbImage == null) {
        return null;
      }

      return _PreparedMomentImages(
        originalBytes: originalBytes,
        thumbBytes: thumbBytes,
        originalWidth: originalImage.width,
        originalHeight: originalImage.height,
        thumbnailWidth: thumbImage.width,
        thumbnailHeight: thumbImage.height,
      );
    } on UnsupportedError {
      return null;
    }
  }

  Future<_PreparedOriginalImage?> _prepareOriginalMomentImageWithNativeCompression(
    String localFilePath,
  ) async {
    if (!(Platform.isAndroid || Platform.isIOS || Platform.isMacOS)) {
      return null;
    }

    try {
      final bytes = await FlutterImageCompress.compressWithFile(
        localFilePath,
        minWidth: _maxOriginalWidth,
        minHeight: _maxOriginalHeight,
        quality: _originalQuality,
        inSampleSize: 1,
        format: CompressFormat.jpeg,
        autoCorrectionAngle: true,
        keepExif: false,
      );
      if (bytes == null || bytes.isEmpty) {
        return null;
      }

      final originalBytes = Uint8List.fromList(bytes);
      final originalImage = img.decodeImage(originalBytes);
      if (originalImage == null) {
        return null;
      }

      return _PreparedOriginalImage(
        originalBytes: originalBytes,
        originalWidth: originalImage.width,
        originalHeight: originalImage.height,
      );
    } on UnsupportedError {
      return null;
    }
  }

  String _generatedThumbnailPath(String originalPath) {
    final extensionIndex = originalPath.lastIndexOf('.');
    if (extensionIndex == -1) {
      return '${originalPath}_${_thumbnailWidth}x$_thumbnailHeight';
    }
    final base = originalPath.substring(0, extensionIndex);
    final extension = originalPath.substring(extensionIndex);
    return '${base}_${_thumbnailWidth}x$_thumbnailHeight$extension';
  }

  Future<_PreparedMomentImages> _consumePreparedMomentImages(
    String localFilePath,
  ) async {
    final future = _preparedMomentImages.remove(localFilePath);
    return future ?? _prepareMomentImages(localFilePath);
  }

  Future<_PreparedOriginalImage> _consumePreparedOriginalImage(
    String localFilePath,
  ) async {
    final future = _preparedOriginalImages.remove(localFilePath);
    return future ?? _prepareOriginalMomentImage(localFilePath);
  }

  // ── Cache Management ─────────────────────────────────────────────────────

  /// Check if a storage path is cached locally.
  Future<bool> isCached(String storagePath) async {
    return File(await _localPath(storagePath)).exists();
  }

  /// Preload a storage path into local cache.
  Future<void> preload(String storagePath) async {
    final cached = await _getCachedBytes(storagePath);
    if (cached != null) return;

    try {
      final ref = _storage.ref().child(storagePath);
      final bytes = await ref.getData();
      if (bytes != null) await _cacheLocally(storagePath, bytes);
    } catch (_) {}
  }

  /// Get cached bytes for a storage path. Falls back to network if not cached.
  Future<Uint8List?> getBytes(String storagePath) async {
    final cached = await _getCachedBytes(storagePath);
    if (cached != null) return cached;

    try {
      final ref = _storage.ref().child(storagePath);
      final bytes = await ref.getData();
      if (bytes != null) await _cacheLocally(storagePath, bytes);
      return bytes;
    } catch (_) {}
    return null;
  }

  /// Clear all local media cache.
  Future<void> clearCache() async {
    try {
      final dir = await _cacheDir;
      if (await dir.exists()) {
        await for (final entity in dir.list()) {
          if (entity is File) await entity.delete();
        }
      }
    } catch (_) {}
  }

  /// Get total cache size in bytes.
  Future<int> getCacheSize() async {
    try {
      final dir = await _cacheDir;
      int total = 0;
      if (await dir.exists()) {
        await for (final entity in dir.list()) {
          if (entity is File) total += await entity.length();
        }
      }
      return total;
    } catch (_) {
      return 0;
    }
  }
}

// ── Result Types ────────────────────────────────────────────────────────────

class _MediaUploadResult {
  final String storagePath;
  final String downloadUrl;
  final int bytesUploaded;

  _MediaUploadResult({
    required this.storagePath,
    required this.downloadUrl,
    required this.bytesUploaded,
  });
}

/// Exception thrown when media upload fails.
class MediaUploadException implements Exception {
  final String message;
  MediaUploadException(this.message);

  @override
  String toString() => 'MediaUploadException: $message';
}
