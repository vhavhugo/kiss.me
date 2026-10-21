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
      photos: [
        'https://images.unsplash.com/photo-1488426862026-3ee34a7d66df?w=800&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?w=800&auto=format&fit=crop&q=80',
      ],
      city: 'São Paulo, SP',
      profession: 'Designer de produto',
      education: 'MBA',
      dream: 'Dar a volta ao mundo conhecendo cafés em cada país.',
      acceptsSponsor: true,
      pixKey: 'camila.demo@kissme.app',
      pureDonation: false,
      dreamGoal: 5000,
      dreamRaised: 3600,
      dreamUpdates: [
        DreamUpdate('Já conheci 4 países! Falta a parte da Ásia.',
            DateTime.now().subtract(const Duration(days: 3))),
        DreamUpdate('Passagem para Tóquio comprada, obrigada a quem ajudou!',
            DateTime.now().subtract(const Duration(days: 12))),
      ],
      sponsorReward: 'Um cartão-postal de cada país e um café na volta.',
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
      photos: [
        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=800&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=800&auto=format&fit=crop&q=80',
      ],
      city: 'São Paulo, SP',
      profession: 'Engenheiro de software',
      education: 'Mestrado',
      dream: 'Abrir uma startup que ajude pessoas a se conectarem de verdade.',
      acceptsSponsor: true,
      pixKey: '+5511999990000',
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
      photos: [
        'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=800&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=800&auto=format&fit=crop&q=80',
      ],
      city: 'Guarulhos, SP',
      profession: 'Estudante de design',
      education: 'Faculdade',
      dream: 'Dirigir um curta-metragem premiado.',
      acceptsSponsor: false,
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
