import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:done_drop/core/constants/app_constants.dart';
import '../../../core/errors/failures.dart';
import '../../../core/errors/result.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/services/media_service.dart';
import 'user_profile_provider.dart';

class FirestoreUserProfileProvider implements UserProfileProvider {
  final FirebaseFirestore _fs = FirebaseFirestore.instance;
  static const _userCodeChars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  final Random _random = Random.secure();

  CollectionReference<Map<String, dynamic>> get _col =>
      _fs.collection(AppConstants.colUsers);
  CollectionReference<Map<String, dynamic>> get _directoryCol =>
      _fs.collection(AppConstants.colUserDirectory);
  CollectionReference<Map<String, dynamic>> get _codeLookupCol =>
      _fs.collection(AppConstants.colUserCodeLookup);
  CollectionReference<Map<String, dynamic>> get _usernameLookupCol =>
      _fs.collection(AppConstants.colUserUsernameLookup);
  CollectionReference<Map<String, dynamic>> get _emailLookupCol =>
      _fs.collection(AppConstants.colUserEmailLookup);

  @override
  Future<Result<UserProfile>> getUserProfile(String uid) async {
    try {
      final doc = await _col.doc(uid).get();
      if (!doc.exists || doc.data() == null) {
        return Result.failure(AppFailure.notFound('User profile not found'));
      }
      return Result.success(UserProfile.fromFirestore(doc.data()!));
    } catch (e) {
      return Result.failure(AppFailure.unexpected(e.toString()));
    }
  }

  @override
  Future<Result<UserProfile>> createUserProfile(UserProfile profile) async {
    try {
      final batch = _fs.batch();
      batch.set(_col.doc(profile.id), profile.toFirestore());
      _applyDiscoveryProfileWrites(batch, profile: profile);
      await batch.commit();
      return Result.success(profile);
    } catch (e) {
      return Result.failure(AppFailure.unexpected(e.toString()));
    }
  }

  @override
  Future<Result<void>> updateUserProfile(UserProfile profile) async {
    try {
      final previous = await _loadExistingProfile(profile.id);
      final batch = _fs.batch();
      batch.update(_col.doc(profile.id), profile.toFirestore());
      _applyDiscoveryProfileWrites(batch, profile: profile, previous: previous);
      await batch.commit();
      return Result.success(null);
    } catch (e) {
      return Result.failure(AppFailure.unexpected(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteUserProfile(String uid) async {
    try {
      final previous = await _loadExistingProfile(uid);
      final batch = _fs.batch();
      batch.delete(_col.doc(uid));
      batch.delete(_directoryCol.doc(uid));
      _deleteLookupDoc(batch, _codeLookupCol, previous?.userCode);
      _deleteLookupDoc(batch, _usernameLookupCol, previous?.username);
      await batch.commit();
      return Result.success(null);
    } catch (e) {
      return Result.failure(AppFailure.unexpected(e.toString()));
    }
  }

  @override
  Future<Result<String>> uploadAvatar(String uid, String filePath) async {
    try {
      // Upload to Firebase Storage via MediaService
      final media = await MediaService.instance.uploadAvatar(
        userId: uid,
        localFilePath: filePath,
      );

      // Update user profile with download URL
      await _col.doc(uid).update({'avatarUrl': media.downloadUrl});

      return Result.success(media.downloadUrl);
    } catch (e) {
      return Result.failure(AppFailure.unexpected(e.toString()));
    }
  }

  @override
  Future<Result<String>> generateUniqueUserCode() async {
    try {
      const maxAttempts = 24;
      final attemptedCodes = <String>{};

      for (var attempt = 0; attempt < maxAttempts; attempt++) {
        final code = List.generate(
          6,
          (_) => _userCodeChars[_random.nextInt(_userCodeChars.length)],
        ).join();
        if (!attemptedCodes.add(code)) continue;

        final existing = await _codeLookupCol.doc(code).get();
        if (!existing.exists) {
          return Result.success(code);
        }
      }

      return Result.failure(
        AppFailure.unexpected(
          'Unable to generate a unique user code right now.',
          'user_code_generation_failed',
        ),
      );
    } catch (e) {
      return Result.failure(AppFailure.unexpected(e.toString()));
    }
  }

  @override
  Future<Result<void>> syncDiscoveryProfile(
    UserProfile profile, {
    String? email,
  }) async {
    try {
      final previous = await _loadExistingProfile(profile.id);
      final batch = _fs.batch();
      _applyDiscoveryProfileWrites(
        batch,
        profile: profile,
        previous: previous,
        email: email,
      );
      await batch.commit();
      return Result.success(null);
    } catch (e) {
      return Result.failure(AppFailure.unexpected(e.toString()));
    }
  }

  @override
  Stream<UserProfile?> watchUserProfile(String uid) {
    return _col.doc(uid).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return UserProfile.fromFirestore(doc.data()!);
    });
  }

  Future<UserProfile?> _loadExistingProfile(String uid) async {
    final doc = await _col.doc(uid).get();
    if (!doc.exists || doc.data() == null) {
      return null;
    }
    return UserProfile.fromFirestore(doc.data()!);
  }

  void _applyDiscoveryProfileWrites(
    WriteBatch batch, {
    required UserProfile profile,
    UserProfile? previous,
    String? email,
  }) {
    batch.set(
      _directoryCol.doc(profile.id),
      profile.toPublicDirectoryFirestore(),
    );

    final previousCode = previous?.userCode?.trim().toUpperCase();
    final nextCode = profile.userCode?.trim().toUpperCase();
    if (previousCode != null &&
        previousCode.isNotEmpty &&
        previousCode != nextCode) {
      batch.delete(_codeLookupCol.doc(previousCode));
    }
    if (nextCode != null && nextCode.isNotEmpty) {
      batch.set(_codeLookupCol.doc(nextCode), {
        'userId': profile.id,
        'code': nextCode,
      });
    }

    final previousUsername = previous?.username?.trim().toLowerCase();
    final nextUsername = profile.username?.trim().toLowerCase();
    if (previousUsername != null &&
        previousUsername.isNotEmpty &&
        previousUsername != nextUsername) {
      batch.delete(_usernameLookupCol.doc(previousUsername));
    }
    if (nextUsername != null && nextUsername.isNotEmpty) {
      batch.set(_usernameLookupCol.doc(nextUsername), {
        'userId': profile.id,
        'username': nextUsername,
      });
    }

    final normalizedEmail = email?.trim().toLowerCase();
    if (normalizedEmail != null && normalizedEmail.isNotEmpty) {
      batch.set(_emailLookupCol.doc(normalizedEmail), {
        'userId': profile.id,
        'email': normalizedEmail,
      });
    }
  }

  void _deleteLookupDoc(
    WriteBatch batch,
    CollectionReference<Map<String, dynamic>> collection,
    String? docId,
  ) {
    final normalized = docId?.trim();
    if (normalized == null || normalized.isEmpty) {
      return;
    }
    batch.delete(collection.doc(normalized));
  }
}
