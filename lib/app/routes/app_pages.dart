import 'package:get/get.dart';
import 'app_routes.dart';
import '../presentation/splash/splash_screen.dart';
import '../presentation/onboarding/onboarding_screen.dart';
import '../presentation/auth/sign_in_screen.dart';
import '../presentation/home/home_screen.dart';
import '../presentation/capture/capture_screen.dart';
import '../presentation/capture/preview_screen.dart';
import '../presentation/capture/success_screen.dart';
import '../presentation/feed/feed_screen.dart';
import '../presentation/feed/circle_detail_screen.dart';
import '../presentation/feed/create_circle_screen.dart';
import '../presentation/feed/invite_screen.dart';
import '../presentation/feed/join_circle_screen.dart';
import '../presentation/memory_wall/memory_wall_screen.dart';
import '../presentation/recap/recap_screen.dart';
import '../presentation/settings/settings_screen.dart';
import '../presentation/premium/premium_screen.dart';
import '../presentation/settings/profile_screen.dart';
import '../presentation/report/report_screen.dart';

/// DoneDrop GetX App Pages
/// Route definitions with GetX
class AppPages {
  AppPages._();

  static const initial = AppRoutes.splash;

  static final routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      transition: Transition.fade,
    ),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.signIn,
      page: () => const SignInScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.capture,
      page: () => const CaptureScreen(),
      transition: Transition.downToUp,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
      name: AppRoutes.preview,
      page: () => const PreviewScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.success,
      page: () => const SuccessScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.feed,
      page: () => const FeedScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.circleDetail,
      page: () => const CircleDetailScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.createCircle,
      page: () => const CreateCircleScreen(),
      transition: Transition.downToUp,
    ),
    GetPage(
      name: AppRoutes.invite,
      page: () => const InviteScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.joinCircle,
      page: () => const JoinCircleScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.memoryWall,
      page: () => const MemoryWallScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.recap,
      page: () => const RecapScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.premium,
      page: () => const PremiumScreen(),
      transition: Transition.downToUp,
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.report,
      page: () => const ReportScreen(),
      transition: Transition.rightToLeft,
    ),
  ];
}
