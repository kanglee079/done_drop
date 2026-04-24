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

  Future<Result<String>> generateUniqueUserCode() =>
      _provider.generateUniqueUserCode();

  Future<Result<void>> syncDiscoveryProfile(
    UserProfile profile, {
    String? email,
  }) => _provider.syncDiscoveryProfile(profile, email: email);

  Future<Result<UserProfile>> ensureUserCode(UserProfile profile) async {
    final currentCode = profile.userCode?.trim() ?? '';
    if (currentCode.isNotEmpty) {
      return Result.success(profile);
    }

    final codeResult = await generateUniqueUserCode();
    return await codeResult.fold(
      onSuccess: (code) async {
        final updated = profile.copyWith(userCode: code);
        final updateResult = await updateUserProfile(updated);
        return updateResult.fold(
          onSuccess: (_) => Result.success(updated),
          onFailure: (failure) => Result.failure(failure),
        );
      },
      onFailure: (failure) async => Result.failure(failure),
    );
  }

  Stream<UserProfile?> watchUserProfile(String uid) =>
      _provider.watchUserProfile(uid);

  /// Batch fetch multiple user profiles.
  /// Returns a map of uid → UserProfile (only successful fetches).
  /// Uses Future.wait for parallel requests — reduces N round-trips to 1.
  Future<Map<String, UserProfile>> getUserProfiles(List<String> uids) async {
    if (uids.isEmpty) return {};

    final uniqueIds = uids.toSet().toList();
    final futures = uniqueIds.map((id) => getUserProfile(id));
    final results = await Future.wait(futures);

    final Map<String, UserProfile> profiles = {};
    for (var i = 0; i < uniqueIds.length; i++) {
      final result = results[i];
      result.fold(
        onSuccess: (profile) => profiles[uniqueIds[i]] = profile,
        onFailure: (_) {},
      );
    }
    return profiles;
  }
}
