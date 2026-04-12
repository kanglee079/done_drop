import 'package:get/get.dart';
import 'app_routes.dart';
import 'auth_guard.dart';
import '../presentation/splash/splash_screen.dart';
import '../presentation/onboarding/onboarding_screen.dart';
import '../presentation/auth/sign_in_screen.dart';
import '../presentation/auth/sign_up_screen.dart';
import '../presentation/auth/forgot_password_screen.dart';
import '../presentation/auth/forgot_password_binding.dart';
import '../presentation/home/home_screen.dart';
import '../presentation/capture/capture_screen.dart';
import '../presentation/capture/preview_screen.dart';
import '../presentation/capture/success_screen.dart';
import '../presentation/feed/feed_screen.dart';
import '../presentation/feed/feed_binding.dart';
// Circle screens deprecated in V1 — kept but not routed
// import '../presentation/feed/circle_detail_screen.dart';
// import '../presentation/feed/circle_detail_binding.dart';
// import '../presentation/feed/create_circle_screen.dart';
import '../presentation/feed/invite_screen.dart';
import '../presentation/feed/invite_binding.dart';
import '../presentation/feed/join_circle_screen.dart';
import '../presentation/memory_wall/memory_wall_screen.dart';
import '../presentation/memory_wall/memory_wall_binding.dart';
import '../presentation/recap/recap_screen.dart';
import '../presentation/recap/recap_binding.dart';
import '../presentation/settings/settings_screen.dart';
import '../presentation/settings/settings_binding.dart';
import '../presentation/settings/profile_screen.dart';
import '../presentation/settings/profile_binding.dart';
import '../presentation/settings/notification_settings_screen.dart';
import '../presentation/premium/premium_screen.dart';
import '../presentation/premium/premium_binding.dart';
import '../presentation/report/report_screen.dart';
import '../presentation/report/report_binding.dart';
import '../presentation/friends/friends_screen.dart';
import '../presentation/friends/friends_binding.dart';
import '../presentation/friends/add_friend_screen.dart';
import '../presentation/friends/add_friend_binding.dart';
import '../presentation/home/home_binding.dart';
import '../../features/auth/presentation/bindings/sign_in_binding.dart';
import '../../features/auth/presentation/bindings/sign_up_binding.dart';
import '../../features/auth/presentation/bindings/onboarding_binding.dart';

/// DoneDrop GetX App Pages
/// Route definitions with GetX
///
/// Route protection:
/// - Public (no guard): /splash, /onboarding, /sign-in, /sign-up, /forgot-password
/// - Protected (AuthGuard): all other routes
class AppPages {
  AppPages._();

  static const initial = AppRoutes.splash;

  static final routes = [
    // ── Public Routes ────────────────────────────────────────────────────────
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      transition: Transition.fade,
    ),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingScreen(),
      binding: OnboardingBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.signIn,
      page: () => const SignInScreen(),
      binding: SignInBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.signUp,
      page: () => const SignUpScreen(),
      binding: SignUpBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordScreen(),
      binding: ForgotPasswordBinding(),
      transition: Transition.rightToLeft,
    ),

    // ── Protected Routes (require AuthGuard) ─────────────────────────────────
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
      binding: HomeBinding(),
      middlewares: [AuthGuard()],
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.capture,
      page: () => const CaptureScreen(),
      middlewares: [AuthGuard()],
      transition: Transition.downToUp,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
      name: AppRoutes.preview,
      page: () => const PreviewScreen(),
      middlewares: [AuthGuard()],
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.success,
      page: () => const SuccessScreen(),
      middlewares: [AuthGuard()],
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.feed,
      page: () => const FeedScreen(),
      binding: FeedBinding(),
      middlewares: [AuthGuard()],
      transition: Transition.fadeIn,
    ),
    // ── Circle routes DEPRECATED in V1 ────────────────────────────────────
    // GetPage(
    //   name: AppRoutes.circleDetail,
    //   page: () => const CircleDetailScreen(),
    //   binding: CircleDetailBinding(),
    //   middlewares: [AuthGuard()],
    //   transition: Transition.rightToLeft,
    // ),
    // GetPage(
    //   name: AppRoutes.createCircle,
    //   page: () => const CreateCircleScreen(),
    //   middlewares: [AuthGuard()],
    //   transition: Transition.downToUp,
    // ),
    // ───────────────────────────────────────────────────────────────────────
    GetPage(
      name: AppRoutes.invite,
      page: () => const InviteScreen(),
      binding: InviteBinding(),
      middlewares: [AuthGuard()],
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.joinCircle,
      page: () => const JoinCircleScreen(),
      middlewares: [AuthGuard()],
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.memoryWall,
      page: () => const MemoryWallScreen(),
      binding: MemoryWallBinding(),
      middlewares: [AuthGuard()],
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.recap,
      page: () => const RecapScreen(),
      binding: RecapBinding(),
      middlewares: [AuthGuard()],
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsScreen(),
      binding: SettingsBinding(),
      middlewares: [AuthGuard()],
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.notificationSettings,
      page: () => const NotificationSettingsScreen(),
      middlewares: [AuthGuard()],
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.premium,
      page: () => const PremiumScreen(),
      binding: PremiumBinding(),
      middlewares: [AuthGuard()],
      transition: Transition.downToUp,
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileScreen(),
      binding: ProfileBinding(),
      middlewares: [AuthGuard()],
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.report,
      page: () => const ReportScreen(),
      binding: ReportBinding(),
      middlewares: [AuthGuard()],
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.friends,
      page: () => const FriendsScreen(),
      binding: FriendsBinding(),
      middlewares: [AuthGuard()],
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.addFriend,
      page: () => const AddFriendScreen(),
      binding: AddFriendBinding(),
      middlewares: [AuthGuard()],
      transition: Transition.rightToLeft,
    ),
  ];
}
