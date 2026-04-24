import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/errors/result.dart';

abstract class AuthProvider {
  bool get shouldOfferGoogleSignIn;
  String? get googleSignInAvailabilityNotice;

  Future<Result<UserCredential>> signInWithEmail(String email, String password);
  Future<Result<UserCredential>> signUpWithEmail(String email, String password);
  Future<Result<UserCredential>> signInWithGoogle();
  Future<Result<void>> reauthenticateWithPassword({
    required String email,
    required String password,
  });
  Future<Result<void>> reauthenticateWithGoogle();
  Future<Result<void>> signOut();
  Future<Result<void>> sendPasswordReset(String email);
  Stream<User?> authStateChanges();
  User? get currentUser;
  Future<Result<void>> deleteAccount();
}
