import '../../../core/errors/result.dart';
import '../../../core/models/user_profile.dart';

abstract class UserProfileProvider {
  Future<Result<UserProfile>> getUserProfile(String uid);
  Future<Result<UserProfile>> createUserProfile(UserProfile profile);
  Future<Result<void>> updateUserProfile(UserProfile profile);
  Future<Result<void>> deleteUserProfile(String uid);
  Future<Result<String>> uploadAvatar(String uid, String filePath);
  Stream<UserProfile?> watchUserProfile(String uid);
}
