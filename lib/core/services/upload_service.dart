import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

/// Service for uploading images to Firebase Storage.
class UploadService {
  UploadService._();
  static final UploadService instance = UploadService._();

  final _storage = FirebaseStorage.instance;

  /// Upload a moment image to Firebase Storage.
  /// Returns the download URL on success.
  ///
  /// Path format: moments/{userId}/{momentId}/{fileName}
  Future<String> uploadMomentImage({
    required String userId,
    required String momentId,
    required String localFilePath,
    String? contentType,
  }) async {
    final ext = localFilePath.split('.').last.toLowerCase();
    final fileName = '${const Uuid().v4()}.$ext';
    final ref = _storage.ref().child('moments').child(userId).child(momentId).child(fileName);

    final metadata = SettableMetadata(
      contentType: contentType ?? 'image/${ext == 'jpg' ? 'jpeg' : ext}',
      cacheControl: 'private',
    );

    await ref.putFile(File(localFilePath), metadata);
    return ref.getDownloadURL();
  }

  /// Upload an avatar image.
  /// Returns the download URL on success.
  Future<String> uploadAvatar({
    required String userId,
    required String localFilePath,
  }) async {
    final ext = localFilePath.split('.').last.toLowerCase();
    final ref = _storage.ref().child('avatars').child('$userId.$ext');

    final metadata = SettableMetadata(
      contentType: 'image/${ext == 'jpg' ? 'jpeg' : ext}',
      cacheControl: 'private',
    );

    await ref.putFile(File(localFilePath), metadata);
    return ref.getDownloadURL();
  }

  /// Upload a circle cover photo.
  /// Returns the download URL on success.
  Future<String> uploadCircleCover({
    required String circleId,
    required String localFilePath,
  }) async {
    final ext = localFilePath.split('.').last.toLowerCase();
    final ref = _storage.ref().child('circles').child(circleId).child('cover.$ext');

    final metadata = SettableMetadata(
      contentType: 'image/${ext == 'jpg' ? 'jpeg' : ext}',
      cacheControl: 'private',
    );

    await ref.putFile(File(localFilePath), metadata);
    return ref.getDownloadURL();
  }
}
