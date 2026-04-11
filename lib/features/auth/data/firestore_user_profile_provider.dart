import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../core/errors/failures.dart';
import '../../../core/errors/result.dart';
import '../../../core/models/user_profile.dart';
import 'user_profile_provider.dart';

class FirestoreUserProfileProvider implements UserProfileProvider {
  final FirebaseFirestore _fs = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _fs.collection('users');

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
      await _col.doc(profile.id).set(profile.toFirestore());
      return Result.success(profile);
    } catch (e) {
      return Result.failure(AppFailure.unexpected(e.toString()));
    }
  }

  @override
  Future<Result<void>> updateUserProfile(UserProfile profile) async {
    try {
      await _col.doc(profile.id).update(profile.toFirestore());
      return Result.success(null);
    } catch (e) {
      return Result.failure(AppFailure.unexpected(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteUserProfile(String uid) async {
    try {
      await _col.doc(uid).delete();
      return Result.success(null);
    } catch (e) {
      return Result.failure(AppFailure.unexpected(e.toString()));
    }
  }

  @override
  Future<Result<String>> uploadAvatar(String uid, String filePath) async {
    try {
      final ref = _storage.ref().child('avatars').child('$uid.jpg');
      final file = File(filePath);
      await ref.putFile(file, SettableMetadata(contentType: 'image/jpeg'));
      final url = await ref.getDownloadURL();
      return Result.success(url);
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
}
