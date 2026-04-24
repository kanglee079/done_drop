import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:done_drop/app/app.dart';
import 'package:done_drop/bootstrap/app_bootstrap.dart';
import 'package:done_drop/core/errors/result.dart';
import 'package:done_drop/core/models/user_profile.dart';
import 'package:done_drop/features/auth/data/firestore_user_profile_provider.dart';
import 'package:done_drop/features/auth/repositories/user_profile_repository.dart';

const String _qaEmail = String.fromEnvironment('QA_EMAIL');
const String _qaPassword = String.fromEnvironment('QA_PASSWORD');
const String _qaDisplayName = String.fromEnvironment('QA_DISPLAY_NAME');
const bool _qaCreateIfMissing = bool.fromEnvironment(
  'QA_CREATE_IF_MISSING',
  defaultValue: false,
);
const bool _qaSignOutFirst = bool.fromEnvironment(
  'QA_SIGN_OUT_FIRST',
  defaultValue: true,
);

bool _shouldCreateQaAccount(FirebaseAuthException error) {
  return switch (error.code) {
    'user-not-found' ||
    'invalid-credential' ||
    'invalid-login-credentials' => true,
    _ => false,
  };
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final status = ValueNotifier<String>('Initializing QA bootstrap...');

  try {
    final auth = FirebaseAuth.instance;
    if (_qaSignOutFirst) {
      await auth.signOut();
    }

    if (_qaEmail.isEmpty || _qaPassword.isEmpty) {
      throw StateError('QA_EMAIL or QA_PASSWORD is missing.');
    }

    status.value = 'Signing in $_qaEmail';
    late final UserCredential credential;
    try {
      credential = await auth.signInWithEmailAndPassword(
        email: _qaEmail,
        password: _qaPassword,
      );
    } on FirebaseAuthException catch (error) {
      if (!_qaCreateIfMissing || !_shouldCreateQaAccount(error)) {
        rethrow;
      }

      status.value = 'Creating QA account $_qaEmail';
      credential = await auth.createUserWithEmailAndPassword(
        email: _qaEmail,
        password: _qaPassword,
      );
    }

    final uid = credential.user?.uid;
    if (uid == null) {
      throw StateError('Signed in but no uid was returned.');
    }

    status.value = 'Bootstrapping profile for $uid';
    final repo = UserProfileRepository(FirestoreUserProfileProvider());
    final existing = await repo.getUserProfile(uid);
    final existingProfile = existing.dataOrNull;

    if (existingProfile != null) {
      final ensured = await repo.ensureUserCode(existingProfile);
      final profile = ensured.dataOrNull ?? existingProfile;
      await repo.syncDiscoveryProfile(profile, email: _qaEmail);
      status.value = 'Ready: ${profile.userCode ?? uid}';
    } else {
      final codeResult = await repo.generateUniqueUserCode();
      final userCode = codeResult.dataOrNull;
      if (userCode == null || userCode.isEmpty) {
        throw StateError('Could not generate userCode.');
      }

      final displayName = _qaDisplayName.isEmpty
          ? _qaEmail.split('@').first
          : _qaDisplayName;
      final profile = UserProfile(
        id: uid,
        displayName: displayName,
        username: null,
        userCode: userCode,
        avatarUrl: null,
        bio: null,
        createdAt: DateTime.now(),
        premiumStatus: false,
        blockedUserIds: const [],
        settings: const UserSettings(
          hasCompletedHabitSetup: false,
          preferredLocaleCode: 'en',
        ),
        widgetPreferences: const WidgetPreferences(),
      );

      final created = await repo.createUserProfile(profile);
      if (created.dataOrNull == null) {
        throw StateError('Could not create profile.');
      }
      status.value = 'Ready: $userCode';
    }

    status.value = 'Launching DoneDrop...';
    await bootstrapDoneDropApp(initializeFirebase: false);
    runApp(const DoneDropApp());
    return;
  } catch (error) {
    status.value = 'QA bootstrap failed: $error';
  }

  runApp(_QaBootstrapApp(status: status));
}

class _QaBootstrapApp extends StatelessWidget {
  const _QaBootstrapApp({required this.status});

  final ValueNotifier<String> status;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ValueListenableBuilder<String>(
              valueListenable: status,
              builder: (context, value, _) {
                return Text(
                  value,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
