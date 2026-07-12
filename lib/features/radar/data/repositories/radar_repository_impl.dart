import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/radar_repository.dart';
import '../datasources/radar_remote_datasource.dart';

class RadarRepositoryImpl implements RadarRepository {
  final RadarRemoteDataSource _remoteDataSource;
  final SupabaseClient _supabase;

  RadarRepositoryImpl(this._remoteDataSource, this._supabase);

  @override
  Future<List<UserEntity>> getNearbyUsers(double lat, double lng) async {
    // 1. Consulta ultra-rápida no Redis para pegar IDs num raio de 10km
    final ids = await _remoteDataSource.getNearbyUserIds(lat, lng, 10.0);

    if (ids.isEmpty) {
      return [];
    }

    // 2. Busca os detalhes dos perfis no PostgreSQL apenas para os IDs encontrados no Redis
    final response = await _supabase
        .from('profiles')
        .select('*, icebreakers(*)')
        .filter('id', 'in', ids);

    // 3. Mapeamento para entidades de domínio
    return (response as List).map((profile) {
      return UserEntity(
        id: profile['id'],
        name: profile['display_name'],
        photoUrl: profile['photo_url'] ?? '',
        distanceInMeters: 0.0, // A distância exata pode ser calculada ou ignorada por privacidade
        bio: profile['bio'] ?? '',
        icebreakers: [], // Mapear questões se necessário
      );
    }).toList();
  }

  @override
  Future<bool> sendInteraction(dynamic interaction) async {
    // Lógica para enviar o beijo/abraço/etc
    return true;
  }
}
