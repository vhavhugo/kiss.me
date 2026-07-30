class PrivacyShieldEntity {
  final bool isLocationFuzzed; // Anonimização de GPS (Lutz, 2017)
  final bool isBehavioralMinified; // Minimização de dados comportamentais (Menard, 2024)
  final bool isThirdPartyBlocked; // Bloqueio de compartilhamento com terceiros
  final String safetyStatus;

  PrivacyShieldEntity({
    required this.isLocationFuzzed,
    required this.isBehavioralMinified,
    required this.isThirdPartyBlocked,
    required this.safetyStatus,
  });
}
