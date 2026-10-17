import 'question_entity.dart';
import 'affinity_explanation_entity.dart';
import '../../../profile/domain/entities/profile_authenticity_entity.dart';

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
    this.acceptsSponsor = true,
  });
}
