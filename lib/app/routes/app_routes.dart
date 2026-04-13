/// DoneDrop Route Names
abstract class AppRoutes {
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const signIn = '/sign-in';
  static const signUp = '/sign-up';
  static const forgotPassword = '/forgot-password';
  static const home = '/home';
  static const capture = '/capture';
  static const preview = '/preview';
  static const success = '/success';
  static const feed = '/feed';
  // ── Circle routes DEPRECATED in V1 — removed ────────────────────────────
  // static const invite = '/invite';
  // static const joinCircle = '/join';
  static const memoryWall = '/wall';
  static const momentDetail = '/moment/:id';
  static const recap = '/recap';
  static const settings = '/settings';
  static const notificationSettings = '/settings/notifications';
  static const profile = '/profile';
  static const premium = '/premium';
  static const report = '/report/:targetType/:targetId';
  static const blocked = '/blocked';
  static const friends = '/friends';
  static const addFriend = '/friends/add';
  static const leaderboard = '/leaderboard';
  static const streakHistory = '/streak-history';
}
