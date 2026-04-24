import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../app/presentation/feed/reaction_controller.dart';
import '../core/services/account_deletion_service.dart';
import '../core/services/analytics_service.dart';
import '../core/services/billing_service.dart';
import '../core/services/block_service.dart';
import '../core/services/capture_camera_service.dart';
import '../core/services/capture_recovery_service.dart';
import '../core/services/connectivity_service.dart';
import '../core/services/local_cache_service.dart';
import '../core/services/local_database_service.dart';
import '../core/services/locale_controller.dart';
import '../core/services/media_service.dart';
import '../core/services/notification_service.dart';
import '../core/services/offline_queue_service.dart';
import '../core/services/storage_service.dart';
import '../core/services/streak_service.dart';
import '../features/auth/data/firebase_auth_provider.dart';
import '../features/auth/data/firestore_user_profile_provider.dart';
import '../features/auth/data/onboarding_service.dart';
import '../features/auth/presentation/controllers/auth_controller.dart';
import '../features/auth/repositories/auth_repository.dart';
import '../features/auth/repositories/user_profile_repository.dart';
import '../firebase/repositories/activity_repository.dart';
import '../firebase/repositories/chat_repository.dart';
import '../firebase/repositories/friend_repository.dart';
import '../firebase/repositories/moment_repository.dart';
import '../firebase/repositories/report_repository.dart';

const bool _enableAppCheck = bool.fromEnvironment(
  'DD_ENABLE_APP_CHECK',
  defaultValue: false,
);
const bool _enableDebugAppCheck = bool.fromEnvironment(
  'DD_ENABLE_DEBUG_APP_CHECK',
  defaultValue: false,
);

Future<void> bootstrapDoneDropApp({bool initializeFirebase = true}) async {
  if (initializeFirebase && Firebase.apps.isEmpty) {
    await Firebase.initializeApp();
  }

  if (!kIsWeb && (_enableAppCheck || (kDebugMode && _enableDebugAppCheck))) {
    await FirebaseAppCheck.instance.activate(
      androidProvider: kDebugMode
          ? AndroidProvider.debug
          : AndroidProvider.playIntegrity,
      appleProvider: kDebugMode
          ? AppleProvider.debug
          : AppleProvider.appAttestWithDeviceCheckFallback,
    );
    await FirebaseAppCheck.instance.setTokenAutoRefreshEnabled(true);
    if (!kDebugMode) {
      try {
        await FirebaseAppCheck.instance.getToken(true);
      } catch (error) {
        debugPrint('[AppCheck] Warmup skipped: $error');
      }
    }
  } else if (kDebugMode && !kIsWeb) {
    debugPrint(
      '[AppCheck] Debug App Check disabled. Set '
      '--dart-define=DD_ENABLE_DEBUG_APP_CHECK=true to opt in.',
    );
  }

  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  FlutterError.onError = (details) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(details);
  };

  AnalyticsService.instance.init(FirebaseAnalytics.instance);

  await Future.wait([
    StorageService.instance.init(),
    NotificationService.instance.init(),
  ]);
  final localeController = LocaleController();
  await localeController.init();
  await LocalDatabaseService.instance.init();
  await LocalCacheService.instance.init();

  Get.put<MediaService>(MediaService.instance, permanent: true);
  final captureCameraService = CaptureCameraService();
  Get.put<CaptureCameraService>(captureCameraService, permanent: true);
  Get.put<CaptureRecoveryService>(CaptureRecoveryService(), permanent: true);
  unawaited(captureCameraService.warmAvailableCameras());

  final connectivity = ConnectivityService();
  await connectivity.init();
  Get.put<ConnectivityService>(connectivity, permanent: true);

  Get.put<OfflineQueueService>(OfflineQueueService(), permanent: true);
  Get.put<AccountDeletionService>(AccountDeletionService(), permanent: true);
  Get.put<LocaleController>(localeController, permanent: true);

  _registerAuthDependencies();

  final billingService = BillingService();
  Get.put<BillingService>(billingService, permanent: true);
  unawaited(billingService.init());
}

void _registerAuthDependencies() {
  final onboardingService = OnboardingService();
  onboardingService.configureWithPrefs(StorageService.instance.prefs);
  Get.put<OnboardingService>(onboardingService, permanent: true);

  Get.put<FirebaseAuthProvider>(FirebaseAuthProvider(), permanent: true);
  Get.put<FirestoreUserProfileProvider>(
    FirestoreUserProfileProvider(),
    permanent: true,
  );

  Get.put<AuthRepository>(
    AuthRepository(Get.find<FirebaseAuthProvider>()),
    permanent: true,
  );

  Get.put<UserProfileRepository>(
    UserProfileRepository(Get.find<FirestoreUserProfileProvider>()),
    permanent: true,
  );

  Get.put<AuthController>(
    AuthController(
      Get.find<AuthRepository>(),
      Get.find<OnboardingService>(),
      Get.find<UserProfileRepository>(),
      Get.find<LocaleController>(),
    ),
    permanent: true,
  );

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
  Get.put<ChatRepository>(
    ChatRepository(FirebaseFirestore.instance),
    permanent: true,
  );
  Get.put<ReportRepository>(ReportRepository(), permanent: true);
  Get.put<BlockService>(BlockService(), permanent: true);
  Get.put<StreakService>(StreakService(), permanent: true);
  Get.put<ReactionController>(ReactionController(), permanent: true);
}
