/// User profile model
class UserProfile {
  const UserProfile({
    required this.id,
    required this.displayName,
    this.username,
    this.userCode,
    this.avatarUrl,
    this.bio,
    required this.createdAt,
    this.premiumStatus = false,
    this.blockedUserIds = const [],
    this.settings = const UserSettings(),
    this.widgetPreferences = const WidgetPreferences(),
  });

  final String id;
  final String displayName;
  final String? username;
  /// Short unique code (6 chars) for easy friend adding via QR/ID.
  final String? userCode;
  final String? avatarUrl;
  final String? bio;
  final DateTime createdAt;
  final bool premiumStatus;
  final List<String> blockedUserIds;
  final UserSettings settings;
  final WidgetPreferences widgetPreferences;

  UserProfile copyWith({
    String? id,
    String? displayName,
    String? username,
    String? userCode,
    String? avatarUrl,
    String? bio,
    DateTime? createdAt,
    bool? premiumStatus,
    List<String>? blockedUserIds,
    UserSettings? settings,
    WidgetPreferences? widgetPreferences,
  }) => UserProfile(
    id: id ?? this.id,
    displayName: displayName ?? this.displayName,
    username: username ?? this.username,
    userCode: userCode ?? this.userCode,
    avatarUrl: avatarUrl ?? this.avatarUrl,
    bio: bio ?? this.bio,
    createdAt: createdAt ?? this.createdAt,
    premiumStatus: premiumStatus ?? this.premiumStatus,
    blockedUserIds: blockedUserIds ?? this.blockedUserIds,
    settings: settings ?? this.settings,
    widgetPreferences: widgetPreferences ?? this.widgetPreferences,
  );

  Map<String, dynamic> toFirestore() => {
    'id': id,
    'displayName': displayName,
    'username': username,
    'userCode': userCode,
    'avatarUrl': avatarUrl,
    'bio': bio,
    'createdAt': createdAt.toIso8601String(),
    'premiumStatus': premiumStatus,
    'blockedUserIds': blockedUserIds,
    'settings': settings.toFirestore(),
    'widgetPreferences': widgetPreferences.toFirestore(),
  };

  factory UserProfile.fromFirestore(Map<String, dynamic> map) => UserProfile(
    id: map['id'] as String,
    displayName: map['displayName'] as String,
    username: map['username'] as String?,
    userCode: map['userCode'] as String?,
    avatarUrl: map['avatarUrl'] as String?,
    bio: map['bio'] as String?,
    createdAt: DateTime.parse(map['createdAt'] as String),
    premiumStatus: map['premiumStatus'] as bool? ?? false,
    blockedUserIds:
        (map['blockedUserIds'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        [],
    settings: map['settings'] != null
        ? UserSettings.fromFirestore(map['settings'] as Map<String, dynamic>)
        : const UserSettings(),
    widgetPreferences: map['widgetPreferences'] != null
        ? WidgetPreferences.fromFirestore(
            map['widgetPreferences'] as Map<String, dynamic>,
          )
        : const WidgetPreferences(),
  );
}

class UserSettings {
  const UserSettings({
    this.reminderEnabled = true,
    this.recapDayOfWeek = 6,
    this.recapTimeOfDay = '09:00',
    this.defaultVisibility = 'personal_only',
    this.hasCompletedHabitSetup = true,
    this.preferredLocaleCode,
  });

  final bool reminderEnabled;
  final int recapDayOfWeek;
  final String recapTimeOfDay;
  final String defaultVisibility;
  final bool hasCompletedHabitSetup;
  final String? preferredLocaleCode;

  UserSettings copyWith({
    bool? reminderEnabled,
    int? recapDayOfWeek,
    String? recapTimeOfDay,
    String? defaultVisibility,
    bool? hasCompletedHabitSetup,
    String? preferredLocaleCode,
  }) => UserSettings(
    reminderEnabled: reminderEnabled ?? this.reminderEnabled,
    recapDayOfWeek: recapDayOfWeek ?? this.recapDayOfWeek,
    recapTimeOfDay: recapTimeOfDay ?? this.recapTimeOfDay,
    defaultVisibility: defaultVisibility ?? this.defaultVisibility,
    hasCompletedHabitSetup:
        hasCompletedHabitSetup ?? this.hasCompletedHabitSetup,
    preferredLocaleCode: preferredLocaleCode ?? this.preferredLocaleCode,
  );

  Map<String, dynamic> toFirestore() => {
    'reminderEnabled': reminderEnabled,
    'recapDayOfWeek': recapDayOfWeek,
    'recapTimeOfDay': recapTimeOfDay,
    'defaultVisibility': defaultVisibility,
    'hasCompletedHabitSetup': hasCompletedHabitSetup,
    'preferredLocaleCode': preferredLocaleCode,
  };

  factory UserSettings.fromFirestore(Map<String, dynamic> map) => UserSettings(
    reminderEnabled: map['reminderEnabled'] as bool? ?? true,
    recapDayOfWeek: map['recapDayOfWeek'] as int? ?? 6,
    recapTimeOfDay: map['recapTimeOfDay'] as String? ?? '09:00',
    defaultVisibility: map['defaultVisibility'] as String? ?? 'personal_only',
    hasCompletedHabitSetup: map['hasCompletedHabitSetup'] as bool? ?? true,
    preferredLocaleCode: map['preferredLocaleCode'] as String?,
  );
}

/// Widget preferences for iOS/Android home screen widgets.
class WidgetPreferences {
  const WidgetPreferences({this.showPersonal = true, this.style = 'default'});

  final bool showPersonal;
  final String style;

  Map<String, dynamic> toFirestore() => {
    'showPersonal': showPersonal,
    'style': style,
  };

  factory WidgetPreferences.fromFirestore(Map<String, dynamic> map) =>
      WidgetPreferences(
        showPersonal: map['showPersonal'] as bool? ?? true,
        style: map['style'] as String? ?? 'default',
      );
}
