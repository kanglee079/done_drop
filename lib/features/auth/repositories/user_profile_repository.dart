import '../data/user_profile_provider.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/errors/result.dart';

class UserProfileRepository {
  UserProfileRepository(this._provider);
  final UserProfileProvider _provider;

  Future<Result<UserProfile>> getUserProfile(String uid) =>
      _provider.getUserProfile(uid);

  Future<Result<UserProfile>> createUserProfile(UserProfile profile) =>
      _provider.createUserProfile(profile);

  Future<Result<void>> updateUserProfile(UserProfile profile) =>
      _provider.updateUserProfile(profile);

  Future<Result<void>> deleteUserProfile(String uid) =>
      _provider.deleteUserProfile(uid);

  Future<Result<String>> uploadAvatar(String uid, String filePath) =>
      _provider.uploadAvatar(uid, filePath);

  Stream<UserProfile?> watchUserProfile(String uid) =>
      _provider.watchUserProfile(uid);
}
