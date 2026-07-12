import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/radar_repository.dart';
import '../datasources/radar_remote_datasource.dart';

class RadarRepositoryImpl implements RadarRepository {
  final RadarRemoteDataSource _remoteDataSource;
  final SupabaseClient _supabase;

  RadarRepositoryImpl(this._remoteDataSource, this._supabase);

  @override
  Future<List<UserEntity>> getNearbyUsers(double lat, double lng, double radiusKm) async {
    // 1. Consulta ultra-rápida no Redis para pegar IDs no raio dinâmico
    final ids = await _remoteDataSource.getNearbyUserIds(lat, lng, radiusKm);

    if (ids.isEmpty) {
      return [];
    }

    // 2. Busca e Filtra no PostgreSQL baseado no perfil selecionado anteriormente
    // Filtramos por: IDs próximos (do Redis) + Preferências de Gênero do usuário logado
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) return [];

    // Pegamos as preferências do usuário logado primeiro
    final myProfile = await _supabase
        .from('profiles')
        .select('search_preference')
        .eq('id', currentUser.id)
        .single();

    final searchPrefs = List<String>.from(myProfile['search_preference'] ?? []);

    // 3. Busca perfis que batem com a preferência
    final response = await _supabase
        .from('profiles')
        .select('*, icebreakers(*)')
        .filter('id', 'in', ids)
        .filter('gender', 'in', searchPrefs);

    // 4. Mapeamento para entidades de domínio
    return (response as List).map((profile) {
      return UserEntity(
        id: profile['id'],
        name: profile['display_name'],
        photoUrl: profile['photo_url'] ?? '',
        distanceInMeters: 0.0,
        bio: profile['bio'] ?? '',
        icebreakers: [],
      );
    }).toList();
  }

  @override
  Future<bool> sendInteraction(dynamic interaction) async {
    // Lógica para enviar o beijo/abraço/etc
    return true;
  }
}
