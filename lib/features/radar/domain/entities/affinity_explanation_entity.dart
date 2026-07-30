class AffinityExplanationEntity {
  final double score; // 0.0 a 1.0
  final String justification; // Por que o algoritmo recomendou (XAI)
  final List<String> commonInterests;

  AffinityExplanationEntity({
    required this.score,
    required this.justification,
    required this.commonInterests,
  });
}
