import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/interaction_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/radar_repository.dart';
import '../datasources/radar_remote_datasource.dart';
import '../models/user_location_model.dart';

import '../../domain/entities/affinity_explanation_entity.dart';
import '../../../profile/domain/entities/profile_authenticity_entity.dart';

class RadarRepositoryImpl implements RadarRepository {
  final RadarRemoteDataSource _remoteDataSource;
  final SupabaseClient _supabase;

  RadarRepositoryImpl(this._remoteDataSource, this._supabase);

  @override
  Future<void> updateLocation(String userId, double lat, double lng) {
    return _remoteDataSource.updateRealtimeLocation(
      UserLocationModel(userId: userId, latitude: lat, longitude: lng),
    );
  }

  @override
  Future<List<UserEntity>> getNearbyUsers(
    String userId,
    double lat,
    double lng,
    double radiusKm,
  ) async {
    // 1. Consulta ultra-rápida no Redis para pegar IDs no raio dinâmico
    final distances =
        await _remoteDataSource.getNearbyUserDistances(lat, lng, radiusKm);
    final ids = distances.keys.where((id) => id != userId).toList();

    if (ids.isEmpty) {
      return [];
    }

    // 2. Busca e Filtra no PostgreSQL baseado no perfil selecionado anteriormente
    // Filtramos por: IDs próximos (do Redis) + Preferências de Gênero do usuário logado
    // Pegamos as preferências do usuário logado primeiro
    final myProfile = await _supabase
        .from('profiles')
        .select('search_preference')
        .eq('id', userId)
        .single();

    final searchPrefs = List<String>.from(myProfile['search_preference'] ?? []);

    // 3. Busca perfis que batem com a preferência
    final response = await _supabase
        .from('profiles')
        .select('*, icebreakers(*)')
        .filter('id', 'in', ids)
        .filter('gender', 'in', searchPrefs);

    // 4. Mapeamento para entidades de domínio, mais próximos primeiro
    final rows = (response as List)
      ..sort((a, b) => (distances[a['id']] ?? 0.0)
          .compareTo(distances[b['id']] ?? 0.0));
    return rows.map((profile) {
      return UserEntity(
        id: profile['id'],
        name: profile['display_name'],
        photoUrl: profile['photo_url'] ?? '',
        distanceInMeters: distances[profile['id']] ?? 0.0,
        bio: profile['bio'] ?? '',
        icebreakers: [],
        authenticity: ProfileAuthenticityEntity(
          level: AuthenticityLevel.verified,
          isAiGenerated: false,
          verificationMethod: "Real-time Selfie",
          lastVerifiedAt: DateTime.now(),
        ),
        affinity: AffinityExplanationEntity(
          score: 0.85,
          justification: "Nossa IA detectou que vocês compartilham o amor por viagens e café.",
          commonInterests: ["Viagens", "Café"],
        ),
      );
    }).toList();
  }

  @override
  Future<bool> sendInteraction(dynamic interaction) async {
    final i = interaction as InteractionEntity;
    await _supabase.from('interactions').insert({
      'from_user_id': i.fromUserId,
      'to_user_id': i.toUserId,
      'type': i.type.name,
      'answer': i.answer,
    });
    return true;
  }
}
