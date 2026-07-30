enum BadgeType { intentionality, consistency, charisma, explorer }

class ConquestBadgeEntity {
  final BadgeType type;
  final String label;
  final String iconPath;
  final int level; // Progressão de nível (Pettersen, 2023)
  final double progress; // 0.0 a 1.0

  ConquestBadgeEntity({
    required this.type,
    required this.label,
    required this.iconPath,
    required this.level,
    required this.progress,
  });
}
