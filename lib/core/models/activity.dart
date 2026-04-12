/// Discipline activity — a repeatable habit/routine the user commits to.
class Activity {
  const Activity({
    required this.id,
    required this.ownerId,
    required this.title,
    this.description,
    this.category,
    this.iconKey,
    this.colorHex,
    this.recurrence = 'daily',
    this.reminderTime,
    this.isArchived = false,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastCompletedAt,
    DateTime? createdAt,
    required this.updatedAt,
  }) : _createdAt = createdAt;

  final DateTime? _createdAt;
  DateTime get createdAt => _createdAt ?? DateTime.now();

  final String id;
  final String ownerId;
  final String title;
  final String? description;
  final String? category;
  final String? iconKey;
  final String? colorHex;
  final String recurrence;
  final String? reminderTime;
  final bool isArchived;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastCompletedAt;
  final DateTime updatedAt;

  bool get hasReminder => reminderTime != null && reminderTime!.isNotEmpty;

  int? get reminderHour {
    if (reminderTime == null) return null;
    return int.tryParse(reminderTime!.split(':')[0]);
  }

  int? get reminderMinute {
    if (reminderTime == null) return null;
    return int.tryParse(reminderTime!.split(':')[1]);
  }

  Activity copyWith({
    String? id,
    String? ownerId,
    String? title,
    String? description,
    String? category,
    String? iconKey,
    String? colorHex,
    String? recurrence,
    String? reminderTime,
    bool? isArchived,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastCompletedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      Activity(
        id: id ?? this.id,
        ownerId: ownerId ?? this.ownerId,
        title: title ?? this.title,
        description: description ?? this.description,
        category: category ?? this.category,
        iconKey: iconKey ?? this.iconKey,
        colorHex: colorHex ?? this.colorHex,
        recurrence: recurrence ?? this.recurrence,
        reminderTime: reminderTime ?? this.reminderTime,
        isArchived: isArchived ?? this.isArchived,
        currentStreak: currentStreak ?? this.currentStreak,
        longestStreak: longestStreak ?? this.longestStreak,
        lastCompletedAt: lastCompletedAt ?? this.lastCompletedAt,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  Map<String, dynamic> toFirestore() => {
        'id': id,
        'ownerId': ownerId,
        'title': title,
        'description': description,
        'category': category,
        'iconKey': iconKey,
        'colorHex': colorHex,
        'recurrence': recurrence,
        'reminderTime': reminderTime,
        'isArchived': isArchived,
        'currentStreak': currentStreak,
        'longestStreak': longestStreak,
        'lastCompletedAt': lastCompletedAt?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Activity.fromFirestore(Map<String, dynamic> map) => Activity(
        id: map['id'] as String,
        ownerId: map['ownerId'] as String,
        title: map['title'] as String,
        description: map['description'] as String?,
        category: map['category'] as String?,
        iconKey: map['iconKey'] as String?,
        colorHex: map['colorHex'] as String?,
        recurrence: map['recurrence'] as String? ?? 'daily',
        reminderTime: map['reminderTime'] as String?,
        isArchived: map['isArchived'] as bool? ?? false,
        currentStreak: map['currentStreak'] as int? ?? 0,
        longestStreak: map['longestStreak'] as int? ?? 0,
        lastCompletedAt: map['lastCompletedAt'] != null
            ? DateTime.parse(map['lastCompletedAt'] as String)
            : null,
        createdAt: map['createdAt'] != null
            ? DateTime.parse(map['createdAt'] as String)
            : null,
        updatedAt: DateTime.parse(map['updatedAt'] as String),
      );
}
