import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import '../data/auth_provider.dart';
import '../../../core/errors/result.dart';

class AuthRepository {
  AuthRepository(this._provider);
  final AuthProvider _provider;

  bool get shouldOfferGoogleSignIn => _provider.shouldOfferGoogleSignIn;

  String? get googleSignInAvailabilityNotice =>
      _provider.googleSignInAvailabilityNotice;

  Future<Result<UserCredential>> signInWithEmail(
    String email,
    String password,
  ) => _provider.signInWithEmail(email, password);

  Future<Result<UserCredential>> signUpWithEmail(
    String email,
    String password,
  ) => _provider.signUpWithEmail(email, password);

  Future<Result<UserCredential>> signInWithGoogle() =>
      _provider.signInWithGoogle();

  Future<Result<void>> reauthenticateWithPassword({
    required String email,
    required String password,
  }) => _provider.reauthenticateWithPassword(email: email, password: password);

  Future<Result<void>> reauthenticateWithGoogle() =>
      _provider.reauthenticateWithGoogle();

  Future<Result<void>> signOut() => _provider.signOut();

  Future<Result<void>> sendPasswordReset(String email) =>
      _provider.sendPasswordReset(email);

  Stream<User?> get authStateChanges => _provider.authStateChanges();

  User? get currentUser => _provider.currentUser;

  Future<Result<void>> deleteAccount() => _provider.deleteAccount();
}
