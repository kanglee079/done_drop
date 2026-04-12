/// Circle model — DEPRECATED in V1.
///
/// V1 uses the friend model (personal_only / all_friends / selected_friends)
/// instead of circles. This model is kept for existing data migration only.
///
/// To be fully removed after V1 public launch.
@Deprecated('Circle deprecated in V1 — use friend system')
class Circle {
  const Circle({
    required this.id,
    required this.name,
    required this.type,
    required this.ownerId,
    required this.memberIds,
    this.coverPhotoUrl,
    required this.createdAt,
    required this.updatedAt,
    this.archived = false,
  });

  final String id;
  final String name;
  final String type; // partner, close_friends, squad, private_custom
  final String ownerId;
  final List<String> memberIds;
  final String? coverPhotoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool archived;

  Circle copyWith({
    String? id,
    String? name,
    String? type,
    String? ownerId,
    List<String>? memberIds,
    String? coverPhotoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? archived,
  }) =>
      Circle(
        id: id ?? this.id,
        name: name ?? this.name,
        type: type ?? this.type,
        ownerId: ownerId ?? this.ownerId,
        memberIds: memberIds ?? this.memberIds,
        coverPhotoUrl: coverPhotoUrl ?? this.coverPhotoUrl,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        archived: archived ?? this.archived,
      );

  Map<String, dynamic> toFirestore() => {
        'id': id,
        'name': name,
        'type': type,
        'ownerId': ownerId,
        'memberIds': memberIds,
        'coverPhotoUrl': coverPhotoUrl,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'archived': archived,
      };

  factory Circle.fromFirestore(Map<String, dynamic> map) => Circle(
        id: map['id'] as String,
        name: map['name'] as String,
        type: map['type'] as String,
        ownerId: map['ownerId'] as String,
        memberIds: (map['memberIds'] as List<dynamic>)
            .map((e) => e as String)
            .toList(),
        coverPhotoUrl: map['coverPhotoUrl'] as String?,
        createdAt: DateTime.parse(map['createdAt'] as String),
        updatedAt: DateTime.parse(map['updatedAt'] as String),
        archived: map['archived'] as bool? ?? false,
      );
}

/// Circle membership record
class CircleMembership {
  const CircleMembership({
    required this.id,
    required this.circleId,
    required this.userId,
    required this.role,
    required this.joinedAt,
    this.status = 'active',
  });

  final String id;
  final String circleId;
  final String userId;
  final String role; // owner, member
  final DateTime joinedAt;
  final String status; // active, invited, removed

  Map<String, dynamic> toFirestore() => {
        'id': id,
        'circleId': circleId,
        'userId': userId,
        'role': role,
        'joinedAt': joinedAt.toIso8601String(),
        'status': status,
      };

  factory CircleMembership.fromFirestore(Map<String, dynamic> map) =>
      CircleMembership(
        id: map['id'] as String,
        circleId: map['circleId'] as String,
        userId: map['userId'] as String,
        role: map['role'] as String,
        joinedAt: DateTime.parse(map['joinedAt'] as String),
        status: map['status'] as String? ?? 'active',
      );
}

/// Invite model
class Invite {
  const Invite({
    required this.id,
    required this.circleId,
    required this.createdBy,
    required this.inviteCode,
    required this.expiresAt,
    this.createdAt,
    this.maxUses = 5,
    this.currentUses = 0,
    this.status = 'active',
  });

  final String id;
  final String circleId;
  final String createdBy;
  final String inviteCode;
  final DateTime expiresAt;
  final DateTime? createdAt;
  final int maxUses;
  final int currentUses;
  final String status; // active, expired, revoked

  bool get isValid =>
      status == 'active' &&
      expiresAt.isAfter(DateTime.now()) &&
      currentUses < maxUses;

  Map<String, dynamic> toFirestore() => {
        'id': id,
        'circleId': circleId,
        'createdBy': createdBy,
        'inviteCode': inviteCode,
        'expiresAt': expiresAt.toIso8601String(),
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
        'maxUses': maxUses,
        'currentUses': currentUses,
        'status': status,
      };

  factory Invite.fromFirestore(Map<String, dynamic> map) => Invite(
        id: map['id'] as String,
        circleId: map['circleId'] as String,
        createdBy: map['createdBy'] as String,
        inviteCode: map['inviteCode'] as String,
        expiresAt: DateTime.parse(map['expiresAt'] as String),
        createdAt: map['createdAt'] != null
            ? DateTime.parse(map['createdAt'] as String)
            : null,
        maxUses: map['maxUses'] as int? ?? 5,
        currentUses: map['currentUses'] as int? ?? 0,
        status: map['status'] as String? ?? 'active',
      );
}
