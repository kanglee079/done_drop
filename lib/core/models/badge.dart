/// Represents an Identity Badge a user has earned.
class IdentityBadge {
  const IdentityBadge({
    required this.id,
    required this.name,
    required this.description,
    required this.iconPath,
    required this.earnedAt,
  });

  final String id;
  final String name; // e.g., "Early Bird"
  final String description; // e.g., "Completed 10 morning habits in a row"
  final String iconPath; // path to local asset or remote URL
  final DateTime earnedAt;

  Map<String, dynamic> toFirestore() => {
        'id': id,
        'name': name,
        'description': description,
        'iconPath': iconPath,
        'earnedAt': earnedAt.toIso8601String(),
      };

  factory IdentityBadge.fromFirestore(Map<String, dynamic> map, String id) => IdentityBadge(
        id: id,
        name: map['name'] as String? ?? 'Badge',
        description: map['description'] as String? ?? '',
        iconPath: map['iconPath'] as String? ?? '',
        earnedAt: map['earnedAt'] != null
            ? DateTime.parse(map['earnedAt'] as String)
            : DateTime.now(),
      );
}
