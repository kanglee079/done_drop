import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/errors/result.dart';

abstract class AuthProvider {
  Future<Result<UserCredential>> signInWithEmail(String email, String password);
  Future<Result<UserCredential>> signUpWithEmail(String email, String password);
  Future<Result<UserCredential>> signInWithGoogle();
  Future<Result<void>> signOut();
  Future<Result<void>> sendPasswordReset(String email);
  Stream<User?> authStateChanges();
  User? get currentUser;
  Future<Result<void>> deleteAccount();
}
