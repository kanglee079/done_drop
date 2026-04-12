/// Moment model — a captured proof moment tied to a completed activity
class Moment {
  const Moment({
    required this.id,
    required this.ownerId,
    this.activityId,
    this.activityInstanceId,
    this.completionLogId, // links moment to its CompletionLog for audit trail
    required this.visibility,
    this.selectedFriendIds = const [],
    // Media stored in Firebase Storage; Firestore holds metadata
    required this.media,
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
  final String? activityId; // optional link to discipline activity
  final String? activityInstanceId; // optional link to activity instance
  final String? completionLogId; // links moment to its CompletionLog
  /// Visibility: personal_only | all_friends | selected_friends
  final String visibility;
  /// Used when visibility == selected_friends
  final List<String> selectedFriendIds;
  /// Media metadata stored in Firestore (Storage path, URLs, dimensions)
  final MomentMedia media;
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
    String? activityId,
    String? activityInstanceId,
    String? completionLogId,
    String? visibility,
    List<String>? selectedFriendIds,
    MomentMedia? media,
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
        activityId: activityId ?? this.activityId,
        activityInstanceId: activityInstanceId ?? this.activityInstanceId,
        completionLogId: completionLogId ?? this.completionLogId,
        visibility: visibility ?? this.visibility,
        selectedFriendIds: selectedFriendIds ?? this.selectedFriendIds,
        media: media ?? this.media,
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
        'activityId': activityId,
        'activityInstanceId': activityInstanceId,
        'completionLogId': completionLogId,
        'visibility': visibility,
        'selectedFriendIds': selectedFriendIds,
        'media': media.toFirestore(),
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
        activityId: map['activityId'] as String?,
        activityInstanceId: map['activityInstanceId'] as String?,
        completionLogId: map['completionLogId'] as String?,
        visibility: map['visibility'] as String,
        selectedFriendIds:
            (map['selectedFriendIds'] as List<dynamic>?)?.cast<String>() ?? [],
        media: MomentMedia.fromFirestore(map['media'] as Map<String, dynamic>),
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

/// Metadata for a single media file. Stored in Firestore; actual bytes in Firebase Storage.
class MediaMetadata {
  final String storagePath;
  final String downloadUrl;
  final String mimeType;
  final int width;
  final int height;
  final int bytesUploaded;
  final String ownerId;
  final String? momentId;

  const MediaMetadata({
    required this.storagePath,
    required this.downloadUrl,
    required this.mimeType,
    required this.width,
    required this.height,
    required this.bytesUploaded,
    required this.ownerId,
    this.momentId,
  });

  Map<String, dynamic> toFirestore() => {
        'storagePath': storagePath,
        'downloadUrl': downloadUrl,
        'mimeType': mimeType,
        'width': width,
        'height': height,
        'bytesUploaded': bytesUploaded,
        'ownerId': ownerId,
        if (momentId != null) 'momentId': momentId,
      };

  factory MediaMetadata.fromFirestore(Map<String, dynamic> map) => MediaMetadata(
        storagePath: map['storagePath'] as String? ?? '',
        downloadUrl: map['downloadUrl'] as String? ?? '',
        mimeType: map['mimeType'] as String? ?? 'image/jpeg',
        width: map['width'] as int? ?? 0,
        height: map['height'] as int? ?? 0,
        bytesUploaded: map['bytesUploaded'] as int? ?? 0,
        ownerId: map['ownerId'] as String? ?? '',
        momentId: map['momentId'] as String?,
      );
}

/// Media metadata for a moment (original + thumbnail). Stored in Firestore.
class MomentMedia {
  final MediaMetadata original;
  final MediaMetadata thumbnail;

  const MomentMedia({
    required this.original,
    required this.thumbnail,
  });

  Map<String, dynamic> toFirestore() => {
        'original': original.toFirestore(),
        'thumbnail': thumbnail.toFirestore(),
      };

  factory MomentMedia.fromFirestore(Map<String, dynamic> map) {
    final orig = map['original'] as Map<String, dynamic>?;
    final thumb = map['thumbnail'] as Map<String, dynamic>?;
    return MomentMedia(
      original: orig != null
          ? MediaMetadata.fromFirestore(orig)
          : MediaMetadata(
              storagePath: '',
              downloadUrl: '',
              mimeType: 'image/jpeg',
              width: 0,
              height: 0,
              bytesUploaded: 0,
              ownerId: '',
            ),
      thumbnail: thumb != null
          ? MediaMetadata.fromFirestore(thumb)
          : MediaMetadata(
              storagePath: '',
              downloadUrl: '',
              mimeType: 'image/jpeg',
              width: 0,
              height: 0,
              bytesUploaded: 0,
              ownerId: '',
            ),
    );
  }

  /// Creates an empty MomentMedia instance with no media.
  factory MomentMedia.empty() => MomentMedia(
        original: MediaMetadata(
          storagePath: '',
          downloadUrl: '',
          mimeType: 'image/jpeg',
          width: 0,
          height: 0,
          bytesUploaded: 0,
          ownerId: '',
        ),
        thumbnail: MediaMetadata(
          storagePath: '',
          downloadUrl: '',
          mimeType: 'image/jpeg',
          width: 0,
          height: 0,
          bytesUploaded: 0,
          ownerId: '',
        ),
      );
}

/// Alias for MomentMedia — used when both original and thumbnail metadata
/// are needed together (e.g., from MediaService.uploadMomentImages).
typedef MomentMediaMetadata = MomentMedia;

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
