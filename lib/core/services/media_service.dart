import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:done_drop/core/models/moment.dart' show MediaMetadata, MomentMediaMetadata;

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

  static const int _maxOriginalWidth = 1920;
  static const int _maxOriginalHeight = 1920;
  static const int _thumbnailWidth = 400;
  static const int _originalQuality = 85;
  static const int _thumbQuality = 75;
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
  /// Uploads two files:
  ///   /moments/{userId}/{momentId}/original.jpg
  ///   /moments/{userId}/{momentId}/thumb.jpg
  Future<MomentMediaMetadata> uploadMomentImages({
    required String userId,
    required String momentId,
    required String localFilePath,
  }) async {
    // Upload original (resized to max 1920px)
    final originalBytes = await _resizeAndCompress(
      localFilePath,
      maxWidth: _maxOriginalWidth,
      maxHeight: _maxOriginalHeight,
      quality: _originalQuality,
    );

    if (originalBytes.length > _maxMomentSizeBytes) {
      throw MediaUploadException('Moment image exceeds maximum size of 10MB');
    }

    final originalPath = 'moments/$userId/$momentId/original.jpg';
    final originalResult = await _uploadBytes(
      originalPath,
      originalBytes,
      mimeType: 'image/jpeg',
    );

    // Decode to get original dimensions
    final decoded = img.decodeImage(originalBytes);
    final origWidth = decoded?.width ?? _maxOriginalWidth;
    final origHeight = decoded?.height ?? _maxOriginalHeight;

    // Upload thumbnail (resized to 400px wide)
    final thumbBytes = await _resizeAndCompress(
      localFilePath,
      maxWidth: _thumbnailWidth,
      maxHeight: (_thumbnailWidth * 1.5).round(),
      quality: _thumbQuality,
    );

    final thumbPath = 'moments/$userId/$momentId/thumb.jpg';
    final thumbResult = await _uploadBytes(
      thumbPath,
      thumbBytes,
      mimeType: 'image/jpeg',
    );

    // Cache both locally
    await _cacheLocally(originalPath, originalBytes);
    await _cacheLocally(thumbPath, thumbBytes);

    return MomentMediaMetadata(
      original: MediaMetadata(
        storagePath: originalResult.storagePath,
        downloadUrl: originalResult.downloadUrl,
        mimeType: 'image/jpeg',
        width: origWidth,
        height: origHeight,
        bytesUploaded: originalResult.bytesUploaded,
        ownerId: userId,
        momentId: momentId,
      ),
      thumbnail: MediaMetadata(
        storagePath: thumbResult.storagePath,
        downloadUrl: thumbResult.downloadUrl,
        mimeType: 'image/jpeg',
        width: _thumbnailWidth,
        height: (_thumbnailWidth * 1.5).round(),
        bytesUploaded: thumbResult.bytesUploaded,
        ownerId: userId,
        momentId: momentId,
      ),
    );
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
