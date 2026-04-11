import 'package:get/get.dart';
import 'package:done_drop/features/auth/data/firebase_auth_provider.dart';
import 'package:done_drop/features/auth/data/firestore_user_profile_provider.dart';
import 'package:done_drop/features/auth/data/onboarding_service.dart';
import 'package:done_drop/features/auth/repositories/auth_repository.dart';
import 'package:done_drop/features/auth/repositories/user_profile_repository.dart';
import 'package:done_drop/features/auth/presentation/controllers/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // Providers
    Get.lazyPut<FirebaseAuthProvider>(() => FirebaseAuthProvider(), fenix: true);
    Get.lazyPut<FirestoreUserProfileProvider>(
        () => FirestoreUserProfileProvider(), fenix: true);

    // Repositories
    Get.lazyPut<AuthRepository>(
      () => AuthRepository(Get.find<FirebaseAuthProvider>()),
      fenix: true,
    );
    Get.lazyPut<UserProfileRepository>(
      () => UserProfileRepository(Get.find<FirestoreUserProfileProvider>()),
      fenix: true,
    );

    // Onboarding Service (singleton)
    Get.put<OnboardingService>(OnboardingService(), permanent: true);

    // Auth Controller
    Get.put<AuthController>(
      AuthController(
        Get.find<AuthRepository>(),
        Get.find<OnboardingService>(),
      ),
      permanent: true,
    );
  }
}
