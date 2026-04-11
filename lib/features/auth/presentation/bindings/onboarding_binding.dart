import 'package:get/get.dart';
import 'package:done_drop/features/auth/data/onboarding_service.dart';
import 'package:done_drop/features/auth/presentation/controllers/onboarding_controller.dart';

class OnboardingBinding extends Bindings {
  @override
  void dependencies() {
    // OnboardingService is already registered globally in main.dart
    Get.lazyPut<OnboardingController>(
      () => OnboardingController(Get.find<OnboardingService>()),
    );
  }
}
