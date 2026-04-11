import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

/// Service for managing images with both Firestore (remote) and local storage.
///
/// Flow:
/// - Upload: Compress → Save to Firestore (source of truth) + local cache
/// - Load: Check local first → Download from Firestore if not cached → Cache locally
class ImageService {
  ImageService._();
  static final ImageService instance = ImageService._();

  final _fs = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _imagesCol =>
      _fs.collection('images');

  /// Max size for Firestore storage (leave buffer for other fields)
  static const int _maxFirestoreSize = 800 * 1024; // 800KB

  /// Get local cache directory path
  Future<Directory> get _cacheDir async {
    final appDir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${appDir.path}/image_cache');
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    return cacheDir;
  }

  /// Get local file path for an image
  Future<String> _getLocalPath(String imageId) async {
    final dir = await _cacheDir;
    return '${dir.path}/$imageId.dat';
  }

  /// Upload image: compress → save to Firestore + local cache
  /// Returns the image ID
  Future<String> uploadImage({
    required String userId,
    required String localFilePath,
    String? momentId,
    String? circleId,
    String? type,
  }) async {
    // Read and compress image
    final bytes = await _compressImageForUpload(localFilePath);
    final base64 = base64Encode(bytes);
    final ext = localFilePath.split('.').last.toLowerCase();
    final mimeType = ext == 'jpg' ? 'image/jpeg' : 'image/$ext';

    // Save to Firestore
    final docRef = _imagesCol.doc();
    try {
      await docRef.set({
        'userId': userId,
        if (momentId != null) 'momentId': momentId,
        if (circleId != null) 'circleId': circleId,
        if (type != null) 'type': type,
        'data': base64,
        'mimeType': mimeType,
        'originalSize': bytes.length,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Failed to save to Firestore: $e');
    }

    // Cache locally with full quality
    await _cacheLocally(docRef.id, bytes, mimeType);

    return docRef.id;
  }

  /// Compress image to fit within Firestore size limit
  Future<Uint8List> _compressImageForUpload(String filePath) async {
    final file = File(filePath);
    Uint8List bytes = await file.readAsBytes();

    // If already small enough, return as-is
    if (bytes.length <= _maxFirestoreSize) {
      return bytes;
    }

    try {
      // Decode image
      final image = img.decodeImage(bytes);
      if (image == null) return bytes;

      // Resize if needed
      img.Image resized = image;
      int quality = 85;

      while (bytes.length > _maxFirestoreSize && quality > 20) {
        // Compress with current quality
        resized = img.copyResize(image, width: image.width);
        bytes = Uint8List.fromList(img.encodeJpg(resized, quality: quality));
        quality -= 15;
      }

      // If still too large, resize dimensions
      while (bytes.length > _maxFirestoreSize && resized.width > 400) {
        resized = img.copyResize(resized, width: (resized.width * 0.8).round());
        bytes = Uint8List.fromList(img.encodeJpg(resized, quality: 70));
      }

      return bytes;
    } catch (e) {
      print('Image compression failed: $e');
      return bytes;
    }
  }

  /// Upload avatar and return data URL
  Future<String> uploadAvatar({
    required String userId,
    required String localFilePath,
  }) async {
    final imageId = await uploadImage(
      userId: userId,
      localFilePath: localFilePath,
      type: 'avatar',
    );

    final dataUrl = await getImageDataUrl(imageId);
    return dataUrl ?? '';
  }

  /// Upload moment image
  Future<String> uploadMomentImage({
    required String userId,
    required String momentId,
    required String localFilePath,
  }) async {
    return uploadImage(
      userId: userId,
      momentId: momentId,
      localFilePath: localFilePath,
      type: 'moment',
    );
  }

  /// Upload circle cover
  Future<String> uploadCircleCover({
    required String circleId,
    required String localFilePath,
    required String userId,
  }) async {
    return uploadImage(
      userId: userId,
      circleId: circleId,
      localFilePath: localFilePath,
      type: 'circle_cover',
    );
  }

  /// Cache image data locally
  Future<void> _cacheLocally(String imageId, List<int> bytes, String mimeType) async {
    try {
      final localPath = await _getLocalPath(imageId);
      final file = File(localPath);
      final size = bytes.length;
      final data = '$mimeType|$size|${base64Encode(bytes)}';
      await file.writeAsString(data);
    } catch (e) {
      print('Failed to cache image locally: $e');
    }
  }

  /// Get image data URL - tries local first, then downloads from Firestore
  Future<String?> getImageDataUrl(String imageId) async {
    final localData = await _getLocalImage(imageId);
    if (localData != null) {
      return 'data:${localData['mimeType']};base64,${localData['data']}';
    }

    final firestoreData = await _downloadFromFirestore(imageId);
    if (firestoreData != null) {
      return 'data:${firestoreData['mimeType']};base64,${firestoreData['data']}';
    }

    return null;
  }

  /// Get image bytes - tries local first, then downloads from Firestore
  Future<List<int>?> getImageBytes(String imageId) async {
    final localData = await _getLocalImage(imageId);
    if (localData != null) {
      return base64Decode(localData['data'] as String);
    }

    final firestoreData = await _downloadFromFirestore(imageId);
    if (firestoreData != null) {
      return base64Decode(firestoreData['data'] as String);
    }

    return null;
  }

  /// Get image from local cache
  Future<Map<String, dynamic>?> _getLocalImage(String imageId) async {
    try {
      final localPath = await _getLocalPath(imageId);
      final file = File(localPath);
      if (await file.exists()) {
        final content = await file.readAsString();
        final parts = content.split('|');
        if (parts.length >= 3) {
          return {
            'mimeType': parts[0],
            'size': int.tryParse(parts[1]) ?? 0,
            'data': parts[2],
          };
        }
      }
    } catch (e) {
      print('Failed to read local image: $e');
    }
    return null;
  }

  /// Download image from Firestore and cache locally
  Future<Map<String, dynamic>?> _downloadFromFirestore(String imageId) async {
    try {
      final doc = await _imagesCol.doc(imageId).get();
      if (!doc.exists) return null;

      final data = doc.data()!;
      final base64 = data['data'] as String?;
      final mimeType = data['mimeType'] as String? ?? 'image/jpeg';

      if (base64 != null) {
        final bytes = base64Decode(base64);
        await _cacheLocally(imageId, bytes, mimeType);
        return {
          'mimeType': mimeType,
          'data': base64,
        };
      }
    } catch (e) {
      print('Failed to download image from Firestore: $e');
    }
    return null;
  }

  /// Preload image to local cache
  Future<void> preloadImage(String imageId) async {
    await getImageBytes(imageId);
  }

  /// Delete image from both Firestore and local cache
  Future<void> deleteImage(String imageId) async {
    try {
      await _imagesCol.doc(imageId).delete();
    } catch (e) {
      print('Failed to delete from Firestore: $e');
    }

    try {
      final localPath = await _getLocalPath(imageId);
      final file = File(localPath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Failed to delete local image: $e');
    }
  }

  /// Clear all local cache
  Future<void> clearCache() async {
    try {
      final dir = await _cacheDir;
      if (await dir.exists()) {
        await for (final entity in dir.list()) {
          if (entity is File) {
            await entity.delete();
          }
        }
      }
    } catch (e) {
      print('Failed to clear cache: $e');
    }
  }

  /// Get cache size in bytes
  Future<int> getCacheSize() async {
    try {
      final dir = await _cacheDir;
      int totalSize = 0;
      if (await dir.exists()) {
        await for (final entity in dir.list()) {
          if (entity is File) {
            totalSize += await entity.length();
          }
        }
      }
      return totalSize;
    } catch (e) {
      return 0;
    }
  }

  /// Check if image is cached locally
  Future<bool> isCached(String imageId) async {
    try {
      final localPath = await _getLocalPath(imageId);
      return await File(localPath).exists();
    } catch (e) {
      return false;
    }
  }
}
