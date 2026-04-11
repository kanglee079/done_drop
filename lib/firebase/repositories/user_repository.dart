import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_constants.dart';
import '../../core/models/models.dart';

/// DoneDrop Firestore Repository — User operations
class UserRepository {
  UserRepository(this._db);
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection(AppConstants.colUsers);

  Future<UserProfile?> getUser(String userId) async {
    final doc = await _col.doc(userId).get();
    if (!doc.exists) return null;
    return UserProfile.fromFirestore(doc.data()!);
  }

  Future<void> createUser(UserProfile user) async {
    await _col.doc(user.id).set(user.toFirestore());
  }

  Future<void> updateUser(UserProfile user) async {
    await _col.doc(user.id).update(user.toFirestore());
  }

  Future<void> updateSettings(String userId, UserSettings settings) async {
    await _col.doc(userId).update({'settings': settings.toFirestore()});
  }

  Stream<UserProfile?> watchUser(String userId) =>
      _col.doc(userId).snapshots().map((doc) {
        if (!doc.exists) return null;
        return UserProfile.fromFirestore(doc.data()!);
      });
}
