import 'question_entity.dart';

class UserEntity {
  final String id;
  final String name;
  final String photoUrl;
  final double distanceInMeters;
  final String bio;
  final List<QuestionEntity> icebreakers;

  UserEntity({
    required this.id,
    required this.name,
    required this.photoUrl,
    required this.distanceInMeters,
    required this.bio,
    required this.icebreakers,
  });
}
