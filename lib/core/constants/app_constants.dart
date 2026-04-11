/// DoneDrop App Constants
class AppConstants {
  AppConstants._();

  // ── App Info ─────────────────────────────────────────────────────────────
  static const String appName = 'DoneDrop';
  static const String tagline = 'Complete it. Capture it. Share the moment.';
  static const String appVersion = '1.0.0';

  // ── Storage Keys ─────────────────────────────────────────────────────────
  static const String keyOnboardingComplete = 'onboarding_complete';
  static const String keyUserId = 'user_id';
  static const String keyUserProfile = 'user_profile';
  static const String keySelectedTheme = 'selected_theme';
  static const String keyPremiumStatus = 'premium_status';
  static const String keyRecapNotificationTime = 'recap_notification_time';
  static const String keyReminderNotification = 'reminder_notification_enabled';
  static const String keyCircleNotification = 'circle_notification_enabled';

  // ── Firebase Collections ─────────────────────────────────────────────────
  static const String colUsers = 'users';
  static const String colCircles = 'circles';
  static const String colCircleMemberships = 'circle_memberships';
  static const String colInvites = 'invites';
  static const String colMoments = 'moments';
  static const String colReactions = 'reactions';
  static const String colTaskTemplates = 'task_templates';
  static const String colWeeklyRecaps = 'weekly_recaps';
  static const String colReports = 'reports';
  static const String colFriendRequests = 'friend_requests';

  // ── Friend Request Status ──────────────────────────────────────────────
  static const String friendStatusPending = 'pending';
  static const String friendStatusAccepted = 'accepted';
  static const String friendStatusDeclined = 'declined';
  static const String friendStatusCancelled = 'cancelled';

  // ── Limits ──────────────────────────────────────────────────────────────
  static const int maxCaptionLength = 300;
  static const int maxMomentsFree = 100;
  static const int maxCirclesFree = 2;
  static const int maxCircleMembers = 20;
  static const int maxInviteCodeAgeHours = 24;
  static const int maxImageWidth = 1920;
  static const int maxImageHeight = 1920;
  static const int imageQuality = 85;

  // ── Reaction Types ──────────────────────────────────────────────────────
  static const List<String> reactionTypes = [
    'love',
    'celebrate',
    'inspiring',
  ];

  // ── Circle Types ────────────────────────────────────────────────────────
  static const String circleTypePartner = 'partner';
  static const String circleTypeCloseFriends = 'close_friends';
  static const String circleTypeSquad = 'squad';
  static const String circleTypePrivate = 'private_custom';

  // ── Onboarding Use Cases ────────────────────────────────────────────────
  static const List<Map<String, dynamic>> onboardingUseCases = [
    {
      'key': 'personal',
      'label': 'Personal',
      'description': 'A private journal for you.',
      'icon': 'person',
    },
    {
      'key': 'couple',
      'label': 'Couple',
      'description': 'Shared moments for two.',
      'icon': 'favorite',
    },
    {
      'key': 'friends',
      'label': 'Friends',
      'description': 'Close circles only.',
      'icon': 'groups',
    },
    {
      'key': 'squad',
      'label': 'Squad',
      'description': 'For your accountability circle.',
      'icon': 'celebration',
    },
  ];

  // ── Categories ───────────────────────────────────────────────────────────
  static const List<String> momentCategories = [
    'Daily Wins',
    'Travel',
    'Reflections',
    'Health & Fitness',
    'Creative',
    'Learning',
    'Relationships',
    'Nature',
    'Food',
    'Work',
    'Monthly Highlights',
  ];

  // ── Animation Durations ─────────────────────────────────────────────────
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animMedium = Duration(milliseconds: 350);
  static const Duration animSlow = Duration(milliseconds: 600);
  static const Duration animHero = Duration(milliseconds: 400);
}
