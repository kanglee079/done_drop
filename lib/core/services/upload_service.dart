import 'image_service.dart';

export 'image_service.dart';

/// UploadService - DEPRECATED
/// Use ImageService instead for Firestore + local cache support.
/// This class is kept for backward compatibility.
@Deprecated('Use ImageService.instance instead')
class UploadService {
  UploadService._();
  static final UploadService instance = UploadService._();

  /// Upload a moment image.
  /// Returns the image ID.
  @Deprecated('Use ImageService.instance.uploadMomentImage instead')
  Future<String> uploadMomentImage({
    required String userId,
    required String momentId,
    required String localFilePath,
    String? contentType,
  }) async {
    return ImageService.instance.uploadMomentImage(
      userId: userId,
      momentId: momentId,
      localFilePath: localFilePath,
    );
  }

  /// Upload an avatar.
  /// Returns a data URL.
  @Deprecated('Use ImageService.instance.uploadAvatar instead')
  Future<String> uploadAvatar({
    required String userId,
    required String localFilePath,
  }) async {
    return ImageService.instance.uploadAvatar(
      userId: userId,
      localFilePath: localFilePath,
    );
  }

  /// Upload a circle cover.
  /// Returns the image ID.
  @Deprecated('Use ImageService.instance.uploadCircleCover instead')
  Future<String> uploadCircleCover({
    required String circleId,
    required String localFilePath,
    required String userId,
  }) async {
    return ImageService.instance.uploadCircleCover(
      circleId: circleId,
      localFilePath: localFilePath,
      userId: userId,
    );
  }
}
