import 'package:get/get.dart';

import '../../../features/auth/presentation/controllers/auth_controller.dart';
import '../../../features/auth/repositories/user_profile_repository.dart';
import '../../../firebase/repositories/activity_repository.dart';
import 'initial_habit_setup_controller.dart';

class InitialHabitSetupBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InitialHabitSetupController>(
      () => InitialHabitSetupController(
        Get.find<AuthController>(),
        Get.find<ActivityRepository>(),
        Get.find<UserProfileRepository>(),
      ),
    );
  }
}
