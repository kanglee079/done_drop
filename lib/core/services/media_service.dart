import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show compute;
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

  static const int _maxOriginalWidth =
      1080; // 1080p is plenty for mobile social
  static const int _maxOriginalHeight = 1080;
  static const int _thumbnailWidth = 400;
  static const int _originalQuality =
      80; // 80% is visually indistinguishable, much smaller files
  static const int _thumbQuality = 70;
  static const int _maxAvatarSizeBytes = 5 * 1024 * 1024; // 5MB
  static const int _maxMomentSizeBytes = 10 * 1024 * 1024; // 10MB

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

    final prepared = await _prepareMomentImages(localFilePath);

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

    final originalProgressSub = originalTask.snapshotEvents.listen((snapshot) {
      originalTransferred = snapshot.bytesTransferred;
      emitUploadProgress();
    });
    final thumbProgressSub = thumbTask.snapshotEvents.listen((snapshot) {
      thumbTransferred = snapshot.bytesTransferred;
      emitUploadProgress();
    });

    final results = await Future.wait([originalTask, thumbTask]);
    await originalProgressSub.cancel();
    await thumbProgressSub.cancel();

    final originalSnapshot = results[0];
    final thumbSnapshot = results[1];
    final originalDownloadUrl = await originalSnapshot.ref.getDownloadURL();
    final thumbDownloadUrl = await thumbSnapshot.ref.getDownloadURL();
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
  }

  Future<_PreparedMomentImages> _prepareMomentImages(
    String localFilePath,
  ) async {
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
