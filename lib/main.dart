import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'app/app.dart';
import 'core/services/storage_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/analytics_service.dart';
import 'core/services/media_service.dart';
import 'core/services/local_database_service.dart';
import 'core/services/connectivity_service.dart';
import 'core/services/offline_queue_service.dart';
import 'core/services/local_cache_service.dart';
import 'core/services/account_deletion_service.dart';
import 'features/auth/data/onboarding_service.dart';
import 'features/auth/data/firebase_auth_provider.dart';
import 'features/auth/data/firestore_user_profile_provider.dart';
import 'features/auth/repositories/auth_repository.dart';
import 'features/auth/repositories/user_profile_repository.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';
import 'firebase/repositories/moment_repository.dart';
import 'firebase/repositories/friend_repository.dart';
import 'firebase/repositories/report_repository.dart';
import 'firebase/repositories/activity_repository.dart';
import 'core/services/streak_service.dart';
import 'core/services/block_service.dart';
import 'app/presentation/feed/reaction_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Set up Crashlytics — handles fatal Flutter errors
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  FlutterError.onError = (details) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(details);
  };

  // Initialize Analytics — all events fire from now on
  AnalyticsService.instance.init(FirebaseAnalytics.instance);

  // Initialize local services
  await StorageService.instance.init();
  await NotificationService.instance.init();
  await LocalDatabaseService.instance.init();
  await LocalCacheService.instance.init();

  // Register MediaService as a permanent GetX service
  Get.put<MediaService>(MediaService.instance, permanent: true);

  // Connectivity monitoring
  final connectivity = ConnectivityService();
  await connectivity.init();
  Get.put<ConnectivityService>(connectivity, permanent: true);

  // Offline queue service — queues operations when offline, syncs when online
  Get.put<OfflineQueueService>(OfflineQueueService(), permanent: true);
  Get.put<AccountDeletionService>(AccountDeletionService(), permanent: true);

  // Register global auth dependencies
  _registerAuthDependencies();

  runApp(const DoneDropApp());
}

void _registerAuthDependencies() {
  // OnboardingService - use the same SharedPreferences instance from StorageService
  final onboardingService = OnboardingService();
  onboardingService.configureWithPrefs(StorageService.instance.prefs);
  Get.put<OnboardingService>(onboardingService, permanent: true);

  // Firebase Auth Provider
  Get.put<FirebaseAuthProvider>(FirebaseAuthProvider(), permanent: true);

  // Firestore User Profile Provider
  Get.put<FirestoreUserProfileProvider>(
    FirestoreUserProfileProvider(),
    permanent: true,
  );

  // Auth Repository
  Get.put<AuthRepository>(
    AuthRepository(Get.find<FirebaseAuthProvider>()),
    permanent: true,
  );

  // User Profile Repository
  Get.put<UserProfileRepository>(
    UserProfileRepository(Get.find<FirestoreUserProfileProvider>()),
    permanent: true,
  );

  // Auth Controller
  Get.put<AuthController>(
    AuthController(Get.find<AuthRepository>(), Get.find<OnboardingService>()),
    permanent: true,
  );

  // Data Repositories (used across authenticated screens)
  Get.put<ActivityRepository>(
    ActivityRepository(FirebaseFirestore.instance),
    permanent: true,
  );
  Get.put<MomentRepository>(
    MomentRepository(FirebaseFirestore.instance),
    permanent: true,
  );
  Get.put<FriendRepository>(
    FriendRepository(FirebaseFirestore.instance),
    permanent: true,
  );
  Get.put<ReportRepository>(ReportRepository(), permanent: true);
  Get.put<BlockService>(BlockService(), permanent: true);
  Get.put<StreakService>(StreakService(), permanent: true);
  Get.put<ReactionController>(ReactionController(), permanent: true);
}
