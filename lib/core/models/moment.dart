import 'package:done_drop/core/models/feed_delivery.dart';

/// Moment model — a captured proof moment tied to a completed activity
enum MomentSyncStatus {
  synced,
  queued,
  processing,
  uploading,
  finalizing,
  failed,
}

class Moment {
  const Moment({
    required this.id,
    required this.ownerId,
    this.ownerDisplayName,
    this.ownerAvatarUrl,
    this.activityId,
    this.activityInstanceId,
    this.completionLogId, // links moment to its CompletionLog for audit trail
    this.activityTitle,
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
    this.localPreviewPath,
    this.uploadProgress = 1,
    this.syncStatus = MomentSyncStatus.synced,
  });

  final String id;
  final String ownerId;
  final String? ownerDisplayName;
  final String? ownerAvatarUrl;
  final String? activityId; // optional link to discipline activity
  final String? activityInstanceId; // optional link to activity instance
  final String? completionLogId; // links moment to its CompletionLog
  final String? activityTitle; // denormalized for feed/wall rendering
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
  final String? localPreviewPath; // local-only image path for optimistic UI
  final double uploadProgress; // local-only progress: 0..1
  final MomentSyncStatus syncStatus; // local-only sync state for UI

  bool get isPendingSync => syncStatus != MomentSyncStatus.synced;

  Moment copyWith({
    String? id,
    String? ownerId,
    String? ownerDisplayName,
    String? ownerAvatarUrl,
    String? activityId,
    String? activityInstanceId,
    String? completionLogId,
    String? activityTitle,
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
    String? localPreviewPath,
    double? uploadProgress,
    MomentSyncStatus? syncStatus,
  }) =>
      Moment(
        id: id ?? this.id,
        ownerId: ownerId ?? this.ownerId,
        ownerDisplayName: ownerDisplayName ?? this.ownerDisplayName,
        ownerAvatarUrl: ownerAvatarUrl ?? this.ownerAvatarUrl,
        activityId: activityId ?? this.activityId,
        activityInstanceId: activityInstanceId ?? this.activityInstanceId,
        completionLogId: completionLogId ?? this.completionLogId,
        activityTitle: activityTitle ?? this.activityTitle,
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
        localPreviewPath: localPreviewPath ?? this.localPreviewPath,
        uploadProgress: uploadProgress ?? this.uploadProgress,
        syncStatus: syncStatus ?? this.syncStatus,
      );

  Map<String, dynamic> toFirestore() => {
        'id': id,
        'ownerId': ownerId,
        'ownerDisplayName': ownerDisplayName,
        'ownerAvatarUrl': ownerAvatarUrl,
        'activityId': activityId,
        'activityInstanceId': activityInstanceId,
        'completionLogId': completionLogId,
        'activityTitle': activityTitle,
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
        id: (map['id'] as String?) ?? '',
        ownerId: (map['ownerId'] as String?) ?? '',
        ownerDisplayName: map['ownerDisplayName'] as String?,
        ownerAvatarUrl: map['ownerAvatarUrl'] as String?,
        activityId: map['activityId'] as String?,
        activityInstanceId: map['activityInstanceId'] as String?,
        completionLogId: map['completionLogId'] as String?,
        activityTitle: map['activityTitle'] as String?,
        visibility: (map['visibility'] as String?) ?? 'private',
        selectedFriendIds:
            (map['selectedFriendIds'] as List<dynamic>?)?.cast<String>() ?? [],
        media: map['media'] == null
            ? MomentMedia.empty()
            : MomentMedia.fromFirestore(map['media'] as Map<String, dynamic>),
        caption: (map['caption'] as String?) ?? '',
        category: map['category'] as String?,
        completedAt: _parseDateTime(map['completedAt']),
        createdAt: _parseDateTime(map['createdAt']),
        updatedAt: _parseDateTime(map['updatedAt']),
        reactionCounts:
            (map['reactionCounts'] as Map<String, dynamic>?)?.map(
                  (k, v) => MapEntry(k, v as int),
                ) ??
                {},
        isDeleted: map['isDeleted'] as bool? ?? false,
        moderationStatus: map['moderationStatus'] as String? ?? 'approved',
      );

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is String && value.isNotEmpty) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  factory Moment.fromFeedDelivery(FeedDelivery delivery) => Moment(
        id: delivery.momentId,
        ownerId: delivery.ownerId,
        ownerDisplayName: delivery.ownerDisplayName,
        ownerAvatarUrl: delivery.ownerAvatarUrl,
        activityTitle: delivery.activityTitle,
        visibility: delivery.visibility,
        media: MomentMedia(
          original: MediaMetadata(
            storagePath: '',
            downloadUrl: delivery.originalUrl,
            mimeType: 'image/jpeg',
            width: 0,
            height: 0,
            bytesUploaded: 0,
            ownerId: delivery.ownerId,
            momentId: delivery.momentId,
          ),
          thumbnail: MediaMetadata(
            storagePath: '',
            downloadUrl: delivery.previewUrl,
            mimeType: 'image/jpeg',
            width: 0,
            height: 0,
            bytesUploaded: 0,
            ownerId: delivery.ownerId,
            momentId: delivery.momentId,
          ),
        ),
        caption: delivery.caption,
        category: delivery.category,
        completedAt: delivery.completedAt,
        createdAt: delivery.createdAt,
        updatedAt: delivery.createdAt,
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

  MediaMetadata copyWith({
    String? storagePath,
    String? downloadUrl,
    String? mimeType,
    int? width,
    int? height,
    int? bytesUploaded,
    String? ownerId,
    String? momentId,
  }) => MediaMetadata(
        storagePath: storagePath ?? this.storagePath,
        downloadUrl: downloadUrl ?? this.downloadUrl,
        mimeType: mimeType ?? this.mimeType,
        width: width ?? this.width,
        height: height ?? this.height,
        bytesUploaded: bytesUploaded ?? this.bytesUploaded,
        ownerId: ownerId ?? this.ownerId,
        momentId: momentId ?? this.momentId,
      );

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

  String get bestOriginalUrl => original.downloadUrl.isNotEmpty
      ? original.downloadUrl
      : thumbnail.downloadUrl;

  String get bestThumbnailUrl => thumbnail.downloadUrl.isNotEmpty
      ? thumbnail.downloadUrl
      : original.downloadUrl;

  bool get isGeneratedThumbnailPending =>
      thumbnail.storagePath.isNotEmpty && thumbnail.downloadUrl.isEmpty;

  MomentMedia copyWith({
    MediaMetadata? original,
    MediaMetadata? thumbnail,
  }) => MomentMedia(
        original: original ?? this.original,
        thumbnail: thumbnail ?? this.thumbnail,
      );

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

class MomentReactionSummary {
  const MomentReactionSummary({
    this.counts = const {},
    this.currentUserReaction,
  });

  final Map<String, int> counts;
  final String? currentUserReaction;

  int countFor(String reactionType) => counts[reactionType] ?? 0;

  int get totalCount =>
      counts.values.fold<int>(0, (sum, value) => sum + value);

  bool isActive(String reactionType) => currentUserReaction == reactionType;
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
