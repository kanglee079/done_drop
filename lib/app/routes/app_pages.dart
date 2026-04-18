import 'package:get/get.dart';
import 'app_routes.dart';
import 'auth_guard.dart';
import '../presentation/splash/splash_screen.dart';
import '../presentation/onboarding/onboarding_screen.dart';
import '../presentation/auth/sign_in_screen.dart';
import '../presentation/auth/sign_up_screen.dart';
import '../presentation/auth/forgot_password_screen.dart';
import '../presentation/auth/forgot_password_binding.dart';
import '../presentation/setup/initial_habit_setup_binding.dart';
import '../presentation/home/home_screen.dart';
import '../presentation/capture/capture_binding.dart';
import '../presentation/capture/capture_screen.dart';
import '../presentation/capture/preview_screen.dart';
import '../presentation/capture/success_screen.dart';
import '../presentation/recap/recap_screen.dart';
import '../presentation/recap/recap_binding.dart';
import '../presentation/settings/profile_screen.dart';
import '../presentation/settings/profile_binding.dart';
import '../presentation/settings/notification_settings_screen.dart';
import '../presentation/notifications/notification_center_binding.dart';
import '../presentation/notifications/notification_center_screen.dart';
import '../presentation/premium/premium_screen.dart';
import '../presentation/premium/premium_binding.dart';
import '../presentation/legal/legal_document_screen.dart';
import '../presentation/report/report_screen.dart';
import '../presentation/report/report_binding.dart';
import '../presentation/friends/friends_screen.dart';
import '../presentation/friends/friends_binding.dart';
import '../presentation/friends/add_friend_screen.dart';
import '../presentation/friends/add_friend_binding.dart';
import '../presentation/chat/chat_binding.dart';
import '../presentation/chat/chat_screen.dart';
import '../presentation/buddy_wall/buddy_wall_binding.dart';
import '../presentation/buddy_wall/buddy_wall_screen.dart';
import '../presentation/qr/qr_binding.dart';
import '../presentation/qr/my_code_screen.dart';
import '../presentation/qr/scan_code_screen.dart';
import '../presentation/leaderboard/leaderboard_screen.dart';
import '../presentation/leaderboard/leaderboard_binding.dart';
import '../presentation/streak/streak_history_screen.dart';
import '../presentation/streak/streak_binding.dart';
import '../presentation/home/home_binding.dart';
import '../../features/auth/presentation/bindings/sign_in_binding.dart';
import '../../features/auth/presentation/bindings/sign_up_binding.dart';
import '../../features/auth/presentation/bindings/onboarding_binding.dart';
import '../presentation/setup/initial_habit_setup_screen.dart';

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
      name: AppRoutes.initialSetup,
      page: () => const InitialHabitSetupScreen(),
      binding: InitialHabitSetupBinding(),
      middlewares: [AuthGuard()],
      transition: Transition.rightToLeft,
    ),
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
      binding: CaptureBinding(),
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
    // NOTE: Feed, MemoryWall, and Settings are embedded as tabs in HomeScreen.
    // They do NOT need standalone routes.
    // If deep linking is added later, re-add them with proper bindings.
    GetPage(
      name: AppRoutes.recap,
      page: () => const RecapScreen(),
      binding: RecapBinding(),
      middlewares: [AuthGuard()],
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationCenterScreen(),
      binding: NotificationCenterBinding(),
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
      name: AppRoutes.privacyPolicy,
      page: () => const LegalDocumentScreen(
        documentType: LegalDocumentType.privacyPolicy,
      ),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.termsOfService,
      page: () => const LegalDocumentScreen(
        documentType: LegalDocumentType.termsOfService,
      ),
      transition: Transition.rightToLeft,
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
    GetPage(
      name: AppRoutes.chat,
      page: () => const ChatScreen(),
      binding: ChatBinding(),
      middlewares: [AuthGuard()],
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.buddyWall,
      page: () => const BuddyWallScreen(),
      binding: BuddyWallBinding(),
      middlewares: [AuthGuard()],
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.myCode,
      page: () => const MyCodeScreen(),
      binding: QrBinding(),
      middlewares: [AuthGuard()],
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.scanCode,
      page: () => const ScanCodeScreen(),
      binding: QrBinding(),
      middlewares: [AuthGuard()],
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.leaderboard,
      page: () => const LeaderboardScreen(),
      binding: LeaderboardBinding(),
      middlewares: [AuthGuard()],
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.streakHistory,
      page: () => const StreakHistoryScreen(),
      binding: StreakBinding(),
      middlewares: [AuthGuard()],
      transition: Transition.rightToLeft,
    ),
  ];
}
