/// DoneDrop App Constants
class AppConstants {
  AppConstants._();

  // ── App Info ─────────────────────────────────────────────────────────────
  static const String appName = 'DoneDrop';
  static const String tagline = 'Complete it. Capture it. Share the proof.';
  static const String appVersion = '1.0.0';
  static const String appDescription =
      'DoneDrop is a personal discipline app. Create habits and routines, '
      'get reminded to do them, complete and capture proof moments, '
      'then share privately with friends who hold you accountable.';

  // ── Storage Keys ─────────────────────────────────────────────────────────
  static const String keyOnboardingComplete = 'onboarding_complete';
  static const String keyUserId = 'user_id';
  static const String keyUserProfile = 'user_profile';
  static const String keySelectedTheme = 'selected_theme';
  static const String keyPremiumStatus = 'premium_status';
  static const String keyRecapNotificationTime = 'recap_notification_time';
  static const String keyReminderNotification = 'reminder_notification_enabled';

  // ── Legacy Circle Collections (V1.5 — kept for data migration compatibility) ──
  // V1 uses friendships/friend_requests. Circles are deprecated.
  @Deprecated('Circles deprecated in V1 — use friend system')
  static const String colCircles = 'circles';
  @Deprecated('Circles deprecated in V1 — use friend system')
  static const String colCircleMemberships = 'circle_memberships';
  @Deprecated('Circles deprecated in V1 — use invite codes for friend system')
  static const String colInvites = 'invites';

  // ── Firebase Collections ─────────────────────────────────────────────────
  static const String colUsers = 'users';
  static const String colUserDirectory = 'user_directory';
  static const String colUserCodeLookup = 'user_code_lookup';
  static const String colUserUsernameLookup = 'user_username_lookup';
  static const String colUserEmailLookup = 'user_email_lookup';
  static const String colMoments = 'moments';
  static const String colReactions = 'reactions';
  // task_templates: legacy V1.0 artifacts — replaced by activities
  @Deprecated('TaskTemplate deprecated — use Activity instead')
  static const String colTaskTemplates = 'task_templates';
  static const String colActivities = 'activities';
  static const String colActivityInstances = 'activity_instances';
  static const String colCompletionLogs = 'completion_logs';
  static const String colFriendships = 'friendships';
  static const String colFeedDeliveries = 'feed_deliveries';
  static const String colWeeklyRecaps = 'weekly_recaps';
  static const String colReports = 'reports';
  static const String colFriendRequests = 'friend_requests';

  // ── Moment Visibility ─────────────────────────────────────────────────────
  static const String visibilityPersonalOnly = 'personal_only';
  static const String visibilityAllFriends = 'all_friends';
  static const String visibilitySelectedFriends = 'selected_friends';

  // ── Activity Recurrence ───────────────────────────────────────────────────
  static const String recurrenceNone = 'none';
  static const String recurrenceDaily = 'daily';
  static const String recurrenceWeekly = 'weekly';
  static const String recurrenceMonthly = 'monthly';

  // ── Activity Instance Status ──────────────────────────────────────────────
  static const String instanceStatusPending = 'pending';
  static const String instanceStatusCompleted = 'completed';
  static const String instanceStatusMissed = 'missed';

  // ── Friend Request Status ──────────────────────────────────────────────
  static const String friendStatusPending = 'pending';
  static const String friendStatusAccepted = 'accepted';
  static const String friendStatusDeclined = 'declined';
  static const String friendStatusCancelled = 'cancelled';

  // ── Limits ──────────────────────────────────────────────────────────────
  static const int maxCaptionLength = 300;
  static const int maxFriendsFree = 5;
  static const int maxInviteCodeAgeHours = 24;
  static const int feedPageSize = 20;
  static const int wallPageSize = 30;

  // ── Reaction Types ──────────────────────────────────────────────────────
  static const List<String> reactionTypes = [
    'love',
    'celebrate',
    'inspiring',
  ];

  // ── Legacy Circle Types (V1.5 — deprecated in V1) ────────────────────────
  // V1 uses friend model (personal_only/all_friends/selected_friends) instead.
  @Deprecated('Circles deprecated in V1')
  static const String circleTypePartner = 'partner';
  @Deprecated('Circles deprecated in V1')
  static const String circleTypeCloseFriends = 'close_friends';
  @Deprecated('Circles deprecated in V1')
  static const String circleTypeSquad = 'squad';
  @Deprecated('Circles deprecated in V1')
  static const String circleTypePrivate = 'private_custom';

  // ── Onboarding Use Cases (V1 relocked — discipline-first) ──────────────────
  // Only two use cases: personal discipline, or personal + accountability partners.
  static const List<Map<String, dynamic>> onboardingUseCases = [
    {
      'key': 'personal',
      'label': 'Personal',
      'description': 'Track habits privately. Just you.',
      'icon': 'person',
    },
    {
      'key': 'with_friends',
      'label': 'With Friends',
      'description': 'Private accountability with close friends.',
      'icon': 'friends',
    },
  ];

  // ── Moment Categories (V1 relocked — discipline-first) ───────────────────
  // Removed: Reflections (diary mindset), Monthly Highlights (vague).
  static const List<String> momentCategories = [
    'Morning Routine',
    'Exercise',
    'Learning',
    'Creative',
    'Health',
    'Social',
    'Hobby',
    'Work',
    'Travel',
    'Other',
  ];

  // ── Animation Durations ─────────────────────────────────────────────────
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animMedium = Duration(milliseconds: 350);
  static const Duration animSlow = Duration(milliseconds: 600);
  static const Duration animHero = Duration(milliseconds: 400);
}
