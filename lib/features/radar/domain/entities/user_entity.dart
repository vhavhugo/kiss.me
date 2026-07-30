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

  UserEntity({
    required this.id,
    required this.name,
    required this.photoUrl,
    required this.distanceInMeters,
    required this.bio,
    required this.icebreakers,
    required this.authenticity,
    this.affinity,
  });
}
