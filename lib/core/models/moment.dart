/// Moment model — a captured photo moment
class Moment {
  const Moment({
    required this.id,
    required this.ownerId,
    this.taskTemplateId,
    this.circleId,
    required this.visibility,
    required this.imageUrl,
    this.thumbnailUrl,
    required this.caption,
    this.category,
    required this.completedAt,
    required this.createdAt,
    required this.updatedAt,
    this.reactionCounts = const {},
    this.isDeleted = false,
    this.moderationStatus = 'approved',
  });

  final String id;
  final String ownerId;
  final String? taskTemplateId;
  final String? circleId;
  final String visibility; // personal_only, circle
  final String imageUrl;
  final String? thumbnailUrl;
  final String caption;
  final String? category;
  final DateTime completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, int> reactionCounts;
  final bool isDeleted;
  final String moderationStatus; // approved, pending, rejected

  Moment copyWith({
    String? id,
    String? ownerId,
    String? taskTemplateId,
    String? circleId,
    String? visibility,
    String? imageUrl,
    String? thumbnailUrl,
    String? caption,
    String? category,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, int>? reactionCounts,
    bool? isDeleted,
    String? moderationStatus,
  }) =>
      Moment(
        id: id ?? this.id,
        ownerId: ownerId ?? this.ownerId,
        taskTemplateId: taskTemplateId ?? this.taskTemplateId,
        circleId: circleId ?? this.circleId,
        visibility: visibility ?? this.visibility,
        imageUrl: imageUrl ?? this.imageUrl,
        thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
        caption: caption ?? this.caption,
        category: category ?? this.category,
        completedAt: completedAt ?? this.completedAt,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        reactionCounts: reactionCounts ?? this.reactionCounts,
        isDeleted: isDeleted ?? this.isDeleted,
        moderationStatus: moderationStatus ?? this.moderationStatus,
      );

  Map<String, dynamic> toFirestore() => {
        'id': id,
        'ownerId': ownerId,
        'taskTemplateId': taskTemplateId,
        'circleId': circleId,
        'visibility': visibility,
        'imageUrl': imageUrl,
        'thumbnailUrl': thumbnailUrl,
        'caption': caption,
        'category': category,
        'completedAt': completedAt.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'reactionCounts': reactionCounts,
        'isDeleted': isDeleted,
        'moderationStatus': moderationStatus,
      };

  factory Moment.fromFirestore(Map<String, dynamic> map) => Moment(
        id: map['id'] as String,
        ownerId: map['ownerId'] as String,
        taskTemplateId: map['taskTemplateId'] as String?,
        circleId: map['circleId'] as String?,
        visibility: map['visibility'] as String,
        imageUrl: map['imageUrl'] as String,
        thumbnailUrl: map['thumbnailUrl'] as String?,
        caption: map['caption'] as String,
        category: map['category'] as String?,
        completedAt: DateTime.parse(map['completedAt'] as String),
        createdAt: DateTime.parse(map['createdAt'] as String),
        updatedAt: DateTime.parse(map['updatedAt'] as String),
        reactionCounts:
            (map['reactionCounts'] as Map<String, dynamic>?)?.map(
                  (k, v) => MapEntry(k, v as int),
                ) ??
                {},
        isDeleted: map['isDeleted'] as bool? ?? false,
        moderationStatus: map['moderationStatus'] as String? ?? 'approved',
      );
}

/// Reaction on a moment
class Reaction {
  const Reaction({
    required this.id,
    required this.momentId,
    required this.userId,
    required this.reactionType,
    required this.createdAt,
  });

  final String id;
  final String momentId;
  final String userId;
  final String reactionType; // love, celebrate, inspiring
  final DateTime createdAt;

  Map<String, dynamic> toFirestore() => {
        'id': id,
        'momentId': momentId,
        'userId': userId,
        'reactionType': reactionType,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Reaction.fromFirestore(Map<String, dynamic> map) => Reaction(
        id: map['id'] as String,
        momentId: map['momentId'] as String,
        userId: map['userId'] as String,
        reactionType: map['reactionType'] as String,
        createdAt: DateTime.parse(map['createdAt'] as String),
      );
}

/// Task template — recurring tasks user creates
class TaskTemplate {
  const TaskTemplate({
    required this.id,
    required this.ownerId,
    required this.title,
    this.category,
    this.iconKey,
    this.isArchived = false,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String ownerId;
  final String title;
  final String? category;
  final String? iconKey;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  TaskTemplate copyWith({
    String? id,
    String? ownerId,
    String? title,
    String? category,
    String? iconKey,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      TaskTemplate(
        id: id ?? this.id,
        ownerId: ownerId ?? this.ownerId,
        title: title ?? this.title,
        category: category ?? this.category,
        iconKey: iconKey ?? this.iconKey,
        isArchived: isArchived ?? this.isArchived,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  Map<String, dynamic> toFirestore() => {
        'id': id,
        'ownerId': ownerId,
        'title': title,
        'category': category,
        'iconKey': iconKey,
        'isArchived': isArchived,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory TaskTemplate.fromFirestore(Map<String, dynamic> map) => TaskTemplate(
        id: map['id'] as String,
        ownerId: map['ownerId'] as String,
        title: map['title'] as String,
        category: map['category'] as String?,
        iconKey: map['iconKey'] as String?,
        isArchived: map['isArchived'] as bool? ?? false,
        createdAt: DateTime.parse(map['createdAt'] as String),
        updatedAt: DateTime.parse(map['updatedAt'] as String),
      );
}
