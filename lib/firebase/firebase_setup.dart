import 'package:firebase_core/firebase_core.dart';

/// DoneDrop Firebase Configuration
/// Initialize all Firebase services here
class FirebaseSetup {
  FirebaseSetup._();

  static Future<void> initialize({
    required String appId,
    required String apiKey,
    required String projectId,
    required String authDomain,
    required String storageBucket,
    required String messagingSenderId,
    required String measurementId,
  }) async {
    final options = FirebaseOptions(
      appId: appId,
      apiKey: apiKey,
      projectId: projectId,
      authDomain: authDomain,
      storageBucket: storageBucket.contains('://')
          ? storageBucket.substring(storageBucket.indexOf('://') + 3)
          : storageBucket,
      messagingSenderId: messagingSenderId,
      measurementId: measurementId,
    );

    await Firebase.initializeApp(
      options: options,
      name: 'DoneDrop',
    );
  }

  static Future<void> initializeWithOptions(FirebaseOptions options) async {
    await Firebase.initializeApp(
      options: options,
      name: 'DoneDrop',
    );
  }
}
