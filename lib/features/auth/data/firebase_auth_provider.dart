import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/errors/result.dart';
import '../../../core/errors/failures.dart';
import '../../../l10n/l10n.dart';
import 'auth_provider.dart';

class FirebaseAuthProvider implements AuthProvider {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Synced to `android/app/google-services.json` generated `default_web_client_id`.
  static const String _googleServerClientId =
      '796015993618-vqotkva1s64768pguv41dj689eb432rv.apps.googleusercontent.com';

  /// Synced to the iOS OAuth client for bundle id `com.donedrop.app`.
  static const String _googleAppleClientId =
      '796015993618-fks8fhf53fjietrtom7hb74nl88rblhk.apps.googleusercontent.com';

  late final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: _googleClientId,
    serverClientId: _configuredGoogleServerClientId,
    scopes: const ['email', 'profile'],
  );

  String? get _googleClientId {
    if (kIsWeb) return null;

    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return _googleAppleClientId;
      default:
        return null;
    }
  }

  String? get _configuredGoogleServerClientId {
    if (kIsWeb) return null;

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return _googleServerClientId;
      default:
        return null;
    }
  }

  bool get _isGoogleSignInConfigured {
    if (kIsWeb) return true;

    final serverClientId = _configuredGoogleServerClientId;
    final clientId = _googleClientId;

    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return serverClientId != null &&
            serverClientId.isNotEmpty &&
            clientId != null &&
            clientId.isNotEmpty;
      case TargetPlatform.android:
        return serverClientId != null && serverClientId.isNotEmpty;
      default:
        return false;
    }
  }

  @override
  bool get shouldOfferGoogleSignIn {
    if (kIsWeb) return false;

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.macOS:
        return _isGoogleSignInConfigured;
      case TargetPlatform.iOS:
        return false;
      default:
        return false;
    }
  }

  @override
  String? get googleSignInAvailabilityNotice {
    if (kIsWeb) return null;

    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return currentL10n.googleSignInIosLimited;
      case TargetPlatform.android:
      case TargetPlatform.macOS:
        return _isGoogleSignInConfigured
            ? null
            : currentL10n.googleSignInConfigError;
      default:
        return null;
    }
  }

  @override
  Future<Result<UserCredential>> signInWithEmail(
    String email,
    String password,
  ) async {
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
  Future<Result<UserCredential>> signUpWithEmail(
    String email,
    String password,
  ) async {
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
          currentL10n.googleSignInConfigError,
          'google_sign_in_not_configured',
        ),
      );
    }
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return Result.failure(
          AppFailure.cancelled(
            currentL10n.googleSignInCancelled,
            'google_sign_in_cancelled',
          ),
        );
      }

      final googleAuth = await googleUser.authentication;
      if (googleAuth.idToken == null || googleAuth.idToken!.isEmpty) {
        return Result.failure(
          AppFailure.unexpected(
            currentL10n.googleSignInTokenMissing,
            'google_sign_in_missing_token',
          ),
        );
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      return Result.success(userCredential);
    } on PlatformException catch (e) {
      return Result.failure(_mapGooglePlatformError(e));
    } on FirebaseAuthException catch (e) {
      return Result.failure(_mapAuthError(e.code));
    } catch (e) {
      return Result.failure(
        AppFailure.unexpected(
          currentL10n.googleSignInFailed,
          'google_sign_in_unexpected',
        ),
      );
    }
  }

  @override
  Future<Result<void>> reauthenticateWithPassword({
    required String email,
    required String password,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      return Result.failure(AppFailure.unauthorized('No authenticated user.'));
    }

    try {
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);
      return Result.success(null);
    } on FirebaseAuthException catch (e) {
      return Result.failure(_mapAuthError(e.code));
    } catch (e) {
      return Result.failure(AppFailure.unexpected(e.toString()));
    }
  }

  @override
  Future<Result<void>> reauthenticateWithGoogle() async {
    final user = _auth.currentUser;
    if (user == null) {
      return Result.failure(AppFailure.unauthorized('No authenticated user.'));
    }

    if (!_isGoogleSignInConfigured) {
      return Result.failure(
        AppFailure.unexpected(
          currentL10n.googleSignInConfigError,
          'google_sign_in_not_configured',
        ),
      );
    }

    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return Result.failure(
          AppFailure.cancelled(
            currentL10n.googleSignInCancelled,
            'google_reauth_cancelled',
          ),
        );
      }

      final googleAuth = await googleUser.authentication;
      if (googleAuth.idToken == null || googleAuth.idToken!.isEmpty) {
        return Result.failure(
          AppFailure.unexpected(
            currentL10n.googleSignInTokenMissing,
            'google_reauth_missing_token',
          ),
        );
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await user.reauthenticateWithCredential(credential);
      return Result.success(null);
    } on PlatformException catch (e) {
      return Result.failure(_mapGooglePlatformError(e));
    } on FirebaseAuthException catch (e) {
      return Result.failure(_mapAuthError(e.code));
    } catch (e) {
      return Result.failure(
        AppFailure.unexpected(
          currentL10n.googleSignInFailed,
          'google_reauth_unexpected',
        ),
      );
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
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
        return AppFailure.notFound(
          currentL10n.authAccountNotFound,
          'auth_user_not_found',
        );
      case 'wrong-password':
        return AppFailure.unauthorized(
          currentL10n.authWrongPassword,
          'auth_wrong_password',
        );
      case 'email-already-in-use':
        return AppFailure.conflict(
          currentL10n.authEmailAlreadyInUse,
          'auth_email_already_in_use',
        );
      case 'invalid-email':
        return AppFailure.invalidInput(
          currentL10n.emailInvalid,
          'auth_invalid_email',
        );
      case 'weak-password':
        return AppFailure.invalidInput(
          currentL10n.passwordTooShort,
          'auth_weak_password',
        );
      case 'user-disabled':
        return AppFailure.forbidden(
          currentL10n.authAccountDisabled,
          'auth_user_disabled',
        );
      case 'too-many-requests':
        return AppFailure.rateLimited(
          currentL10n.authTooManyRequests,
          'auth_too_many_requests',
        );
      case 'network-request-failed':
        return AppFailure.network(
          currentL10n.authNetworkError,
          'auth_network_error',
        );
      case 'invalid-credential':
        return AppFailure.unauthorized(
          currentL10n.authInvalidCredentials,
          'auth_invalid_credential',
        );
      case 'account-exists-with-different-credential':
        return AppFailure.conflict(
          currentL10n.authDifferentSignInMethod,
          'auth_different_sign_in_method',
        );
      case 'operation-not-allowed':
        return AppFailure.forbidden(
          currentL10n.authProviderUnavailable,
          'auth_operation_not_allowed',
        );
      case 'requires-recent-login':
        return AppFailure.unauthorized(
          currentL10n.authRecentLoginRequired,
          'auth_requires_recent_login',
        );
      default:
        return AppFailure.unexpected(
          currentL10n.authGenericError,
          'auth_$code',
        );
    }
  }

  AppFailure _mapGooglePlatformError(PlatformException error) {
    switch (error.code) {
      case GoogleSignIn.kSignInCanceledError:
        return AppFailure.cancelled(
          currentL10n.googleSignInCancelled,
          'google_sign_in_cancelled',
        );
      case GoogleSignIn.kNetworkError:
        return AppFailure.network(
          currentL10n.googleSignInNetworkError,
          'google_sign_in_network_error',
        );
      case GoogleSignIn.kSignInFailedError:
        final diagnostic = [
          error.message ?? '',
          if (error.details != null) '${error.details}',
        ].join(' ').toUpperCase();

        if (diagnostic.contains('DEVELOPER_ERROR') ||
            diagnostic.contains(' 10:') ||
            diagnostic.contains('12500')) {
          return AppFailure.unexpected(
            currentL10n.googleSignInConfigError,
            'google_sign_in_config_error',
          );
        }

        return AppFailure.unexpected(
          currentL10n.googleSignInFailed,
          'google_sign_in_failed',
        );
      case GoogleSignIn.kSignInRequiredError:
        return AppFailure.unexpected(
          currentL10n.googleSignInFailed,
          'google_sign_in_required',
        );
      default:
        return AppFailure.unexpected(
          currentL10n.googleSignInFailed,
          'google_${error.code}',
        );
    }
  }
}
