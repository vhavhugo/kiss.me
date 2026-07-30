enum AuthenticityLevel { unverified, partial, verified }

class ProfileAuthenticityEntity {
  final AuthenticityLevel level;
  final bool isAiGenerated; // Detecção de engano visual (Ivan, 2025)
  final String verificationMethod; // Ex: Selfie em tempo real
  final DateTime lastVerifiedAt;

  ProfileAuthenticityEntity({
    required this.level,
    required this.isAiGenerated,
    required this.verificationMethod,
    required this.lastVerifiedAt,
  });
}
