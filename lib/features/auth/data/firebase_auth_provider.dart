import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/errors/result.dart';
import '../../../core/errors/failures.dart';
import 'auth_provider.dart';

/// IMPORTANT: Replace 'REPLACE_WITH_YOUR_GOOGLE_WEB_CLIENT_ID' with the actual Web Client ID from:
/// Firebase Console → Authentication → Sign-in method → Google → Web SDK configuration
///
/// To find it:
/// 1. Go to Firebase Console → Project Settings → Your apps → Web app
/// 2. Or: Firebase Console → Authentication → Sign-in method → Google → Web SDK configuration
/// 3. Copy the "Web client ID" (looks like: xxxxxxxx-xxxxxxxxxxxxxxxx.apps.googleusercontent.com)
class FirebaseAuthProvider implements AuthProvider {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _googleWebClientId =
      '796015993618-fq11oc3bbtk7kc22b96js07ie35qdps6.apps.googleusercontent.com';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: _googleWebClientId,
    scopes: ['email', 'profile'],
  );

  bool get _isGoogleSignInConfigured =>
      _googleWebClientId.isNotEmpty && _googleWebClientId != 'REPLACE_WITH_YOUR_GOOGLE_WEB_CLIENT_ID';

  @override
  Future<Result<UserCredential>> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return Result.success(credential);
    } on FirebaseAuthException catch (e) {
      return Result.failure(_mapAuthError(e.code));
    } catch (e) {
      return Result.failure(AppFailure.unexpected(e.toString()));
    }
  }

  @override
  Future<Result<UserCredential>> signUpWithEmail(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return Result.success(credential);
    } on FirebaseAuthException catch (e) {
      return Result.failure(_mapAuthError(e.code));
    } catch (e) {
      return Result.failure(AppFailure.unexpected(e.toString()));
    }
  }

  @override
  Future<Result<UserCredential>> signInWithGoogle() async {
    if (!_isGoogleSignInConfigured) {
      return Result.failure(
        AppFailure.unexpected(
          'Google Sign-In is not configured. '
          'Set _googleWebClientId in firebase_auth_provider.dart with your '
          'Web Client ID from Firebase Console → Authentication → '
          'Sign-in method → Google → Web SDK configuration.',
        ),
      );
    }
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return Result.failure(AppFailure.cancelled('Google sign-in was cancelled'));
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      return Result.success(userCredential);
    } on FirebaseAuthException catch (e) {
      return Result.failure(_mapAuthError(e.code));
    } catch (e) {
      return Result.failure(AppFailure.unexpected(e.toString()));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
      return Result.success(null);
    } catch (e) {
      return Result.failure(AppFailure.unexpected(e.toString()));
    }
  }

  @override
  Future<Result<void>> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return Result.success(null);
    } on FirebaseAuthException catch (e) {
      return Result.failure(_mapAuthError(e.code));
    } catch (e) {
      return Result.failure(AppFailure.unexpected(e.toString()));
    }
  }

  @override
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  @override
  User? get currentUser => _auth.currentUser;

  @override
  Future<Result<void>> deleteAccount() async {
    try {
      await _auth.currentUser?.delete();
      return Result.success(null);
    } on FirebaseAuthException catch (e) {
      return Result.failure(_mapAuthError(e.code));
    } catch (e) {
      return Result.failure(AppFailure.unexpected(e.toString()));
    }
  }

  AppFailure _mapAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return AppFailure.notFound('No account found with this email');
      case 'wrong-password':
        return AppFailure.unauthorized('Incorrect password');
      case 'email-already-in-use':
        return AppFailure.conflict('This email is already registered');
      case 'invalid-email':
        return AppFailure.invalidInput('Invalid email address');
      case 'weak-password':
        return AppFailure.invalidInput('Password is too weak (min 6 characters)');
      case 'user-disabled':
        return AppFailure.forbidden('This account has been disabled');
      case 'too-many-requests':
        return AppFailure.rateLimited('Too many attempts. Please try again later');
      case 'network-request-failed':
        return AppFailure.network('Network error. Check your connection');
      case 'invalid-credential':
        return AppFailure.unauthorized('Invalid credentials');
      default:
        return AppFailure.unexpected('Authentication error: $code');
    }
  }
}
