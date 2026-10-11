import 'dart:async';
import '../../features/radar/domain/entities/user_entity.dart';
import '../../features/radar/domain/entities/question_entity.dart';
import '../../features/radar/domain/entities/affinity_explanation_entity.dart';
import '../../features/radar/domain/repositories/radar_repository.dart';
import '../../features/profile/domain/entities/profile_authenticity_entity.dart';

class MockRadarRepository implements RadarRepository {
  final List<UserEntity> _mockUsers = [
    UserEntity(
      id: 'mock-user-1',
      name: 'Camila, 24',
      photoUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=600&auto=format&fit=crop&q=80',
      distanceInMeters: 45.0,
      bio: 'Amante de cafés, arte e boas conversas. Sempre pronta para viajar!',
      icebreakers: [
        QuestionEntity(id: 'q1', text: 'Café ou vinho no primeiro encontro?'),
        QuestionEntity(id: 'q2', text: 'Qual sua playlist favorita?'),
      ],
      authenticity: ProfileAuthenticityEntity(
        level: AuthenticityLevel.verified,
        isAiGenerated: false,
        verificationMethod: 'Selfie em tempo real',
        lastVerifiedAt: DateTime.now(),
      ),
      affinity: AffinityExplanationEntity(
        score: 0.94,
        justification: 'Vocês têm 94% de afinidade em gostos musicais, passeios ao ar livre e gastronomia.',
        commonInterests: ['Música', 'Café', 'Fotografia'],
      ),
    ),
    UserEntity(
      id: 'mock-user-2',
      name: 'Lucas, 26',
      photoUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=600&auto=format&fit=crop&q=80',
      distanceInMeters: 120.0,
      bio: 'Gosto de esportes, trilhas e tecnologia. Vamos tomar um sorvete?',
      icebreakers: [
        QuestionEntity(id: 'q3', text: 'Praia ou serra no fim de semana?'),
      ],
      authenticity: ProfileAuthenticityEntity(
        level: AuthenticityLevel.verified,
        isAiGenerated: false,
        verificationMethod: 'Biometria Facial',
        lastVerifiedAt: DateTime.now(),
      ),
      affinity: AffinityExplanationEntity(
        score: 0.88,
        justification: 'Ambos adoram esportes e fins de semana ao ar livre.',
        commonInterests: ['Esportes', 'Trilhas', 'Filmes'],
      ),
    ),
    UserEntity(
      id: 'mock-user-3',
      name: 'Beatriz, 23',
      photoUrl: 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=600&auto=format&fit=crop&q=80',
      distanceInMeters: 280.0,
      bio: 'Estudante de design e cinéfila de plantão. Bora trocar recomendações!',
      icebreakers: [
        QuestionEntity(id: 'q4', text: 'Qual o melhor filme que você já viu?'),
      ],
      authenticity: ProfileAuthenticityEntity(
        level: AuthenticityLevel.verified,
        isAiGenerated: false,
        verificationMethod: 'Selfie em tempo real',
        lastVerifiedAt: DateTime.now(),
      ),
      affinity: AffinityExplanationEntity(
        score: 0.82,
        justification: 'Afinidade alta em interesses culturais e criativos.',
        commonInterests: ['Cinema', 'Design', 'Livros'],
      ),
    ),
  ];

  @override
  Future<void> updateLocation(String userId, double lat, double lng) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  @override
  Future<List<UserEntity>> getNearbyUsers(
    String userId,
    double lat,
    double lng,
    double radiusKm,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockUsers;
  }

  @override
  Future<bool> sendInteraction(dynamic interaction) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }
}
