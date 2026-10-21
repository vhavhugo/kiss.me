import 'question_entity.dart';
import 'affinity_explanation_entity.dart';
import '../../../profile/domain/entities/profile_authenticity_entity.dart';

/// Atualização publicada pelo dono do sonho (prestação de contas).
class DreamUpdate {
  final String text;
  final DateTime date;
  const DreamUpdate(this.text, this.date);

  Map<String, dynamic> toJson() => {'text': text, 'date': date.toIso8601String()};

  static DreamUpdate? fromJson(dynamic j) {
    if (j is! Map) return null;
    final d = DateTime.tryParse(j['date'] as String? ?? '');
    final t = j['text'] as String? ?? '';
    return d == null || t.isEmpty ? null : DreamUpdate(t, d);
  }
}

class UserEntity {
  final String id;
  final String name;
  final String photoUrl;
  final double distanceInMeters;
  final String bio;
  final List<QuestionEntity> icebreakers;
  final AffinityExplanationEntity? affinity;
  final ProfileAuthenticityEntity authenticity; // Foco em segurança (Datey, 2024)
  final List<String> photos;
  final String? city;
  final String? profession;
  final String? education;
  final String? dream;
  final bool acceptsSponsor;
  final String? pixKey;

  /// true = doação pura; false = com contrapartida descrita em [sponsorReward].
  final bool pureDonation;
  final String? sponsorReward;

  /// Meta e valor arrecadado, ambos informados pelo próprio dono do sonho.
  final double? dreamGoal;
  final double dreamRaised;
  final List<DreamUpdate> dreamUpdates;

  /// Foto principal seguida das demais, sem repetição.
  List<String> get allPhotos => [
        if (photoUrl.isNotEmpty) photoUrl,
        ...photos.where((p) => p != photoUrl),
      ];

  UserEntity({
    required this.id,
    required this.name,
    required this.photoUrl,
    required this.distanceInMeters,
    required this.bio,
    required this.icebreakers,
    required this.authenticity,
    this.affinity,
    this.photos = const [],
    this.city,
    this.profession,
    this.education,
    this.dream,
    this.acceptsSponsor = false,
    this.pixKey,
    this.pureDonation = true,
    this.sponsorReward,
    this.dreamGoal,
    this.dreamRaised = 0,
    this.dreamUpdates = const [],
  });
}
