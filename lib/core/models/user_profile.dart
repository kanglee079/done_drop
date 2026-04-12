/// User profile model
class UserProfile {
  const UserProfile({
    required this.id,
    required this.displayName,
    this.username,
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
    String? avatarUrl,
    String? bio,
    DateTime? createdAt,
    bool? premiumStatus,
    List<String>? blockedUserIds,
    UserSettings? settings,
    WidgetPreferences? widgetPreferences,
  }) =>
      UserProfile(
        id: id ?? this.id,
        displayName: displayName ?? this.displayName,
        username: username ?? this.username,
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
        avatarUrl: map['avatarUrl'] as String?,
        bio: map['bio'] as String?,
        createdAt: DateTime.parse(map['createdAt'] as String),
        premiumStatus: map['premiumStatus'] as bool? ?? false,
        blockedUserIds: (map['blockedUserIds'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        settings: map['settings'] != null
            ? UserSettings.fromFirestore(map['settings'] as Map<String, dynamic>)
            : const UserSettings(),
        widgetPreferences: map['widgetPreferences'] != null
            ? WidgetPreferences.fromFirestore(
                map['widgetPreferences'] as Map<String, dynamic>)
            : const WidgetPreferences(),
      );
}

class UserSettings {
  const UserSettings({
    this.reminderEnabled = true,
    // circleActivityEnabled deprecated in V1 — circles replaced by friends
    @Deprecated('Circle model deprecated in V1') this.circleActivityEnabled = false,
    this.recapDayOfWeek = 6,
    this.recapTimeOfDay = '09:00',
    this.defaultVisibility = 'personal_only',
  });

  final bool reminderEnabled;
  @Deprecated('Circle model deprecated in V1')
  final bool circleActivityEnabled;
  final int recapDayOfWeek;
  final String recapTimeOfDay;
  final String defaultVisibility;

  UserSettings copyWith({
    bool? reminderEnabled,
    @Deprecated('Circle model deprecated in V1') bool? circleActivityEnabled,
    int? recapDayOfWeek,
    String? recapTimeOfDay,
    String? defaultVisibility,
  }) =>
      UserSettings(
        reminderEnabled: reminderEnabled ?? this.reminderEnabled,
        circleActivityEnabled:
            circleActivityEnabled ?? this.circleActivityEnabled,
        recapDayOfWeek: recapDayOfWeek ?? this.recapDayOfWeek,
        recapTimeOfDay: recapTimeOfDay ?? this.recapTimeOfDay,
        defaultVisibility: defaultVisibility ?? this.defaultVisibility,
      );

  Map<String, dynamic> toFirestore() => {
        'reminderEnabled': reminderEnabled,
        // Keep for backward compat — circles deprecated in V1
        'circleActivityEnabled': circleActivityEnabled,
        'recapDayOfWeek': recapDayOfWeek,
        'recapTimeOfDay': recapTimeOfDay,
        'defaultVisibility': defaultVisibility,
      };

  factory UserSettings.fromFirestore(Map<String, dynamic> map) => UserSettings(
        reminderEnabled: map['reminderEnabled'] as bool? ?? true,
        circleActivityEnabled:
            map['circleActivityEnabled'] as bool? ?? false,
        recapDayOfWeek: map['recapDayOfWeek'] as int? ?? 6,
        recapTimeOfDay: map['recapTimeOfDay'] as String? ?? '09:00',
        defaultVisibility: map['defaultVisibility'] as String? ?? 'personal_only',
      );
}

/// Widget preferences for iOS/Android home screen widgets.
/// Home Widget feature is not in V1 scope — this model is deprecated.
@Deprecated('Home Widget not in V1 scope')
class WidgetPreferences {
  @Deprecated('Home Widget not in V1 scope')
  const WidgetPreferences({
    this.showPersonal = true,
    @Deprecated('Circle model deprecated in V1')
    this.showCircle = false,
    @Deprecated('Circle model deprecated in V1')
    this.circleId,
    this.style = 'default',
  });

  final bool showPersonal;
  @Deprecated('Circle model deprecated in V1')
  final bool showCircle;
  @Deprecated('Circle model deprecated in V1')
  final String? circleId;
  final String style;

  Map<String, dynamic> toFirestore() => {
        'showPersonal': showPersonal,
        // Keep for backward compat
        'showCircle': showCircle,
        'circleId': circleId,
        'style': style,
      };

  factory WidgetPreferences.fromFirestore(Map<String, dynamic> map) =>
      WidgetPreferences(
        showPersonal: map['showPersonal'] as bool? ?? true,
        showCircle: map['showCircle'] as bool? ?? false,
        circleId: map['circleId'] as String?,
        style: map['style'] as String? ?? 'default',
      );
}
