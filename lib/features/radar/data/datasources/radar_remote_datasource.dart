import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_location_model.dart';

class RadarRemoteDataSource {
  final SupabaseClient _supabase;

  RadarRemoteDataSource(this._supabase);

  /// Envia a localização em tempo real para o Redis via Edge Function
  Future<void> updateRealtimeLocation(UserLocationModel location) async {
    try {
      await _supabase.functions.invoke(
        'update-location',
        body: location.toJson(),
      );
    } catch (e) {
      debugPrint('Falha ao atualizar localização: $e');
    }
  }

  /// Busca os IDs dos usuários mais próximos no Redis
  /// Retorna id -> distância em metros, já do mais próximo ao mais distante.
  Future<Map<String, double>> getNearbyUserDistances(
      double lat, double lng, double radiusKm) async {
    try {
      final response = await _supabase.functions.invoke(
        'search-nearby',
        body: {'lat': lat, 'lng': lng, 'radius': radiusKm},
      );

      if (response.status == 200) {
        final ids = List<String>.from(response.data['ids'] ?? const []);
        final dist = (response.data['distances'] as List? ?? const [])
            .map((d) => (d as num).toDouble())
            .toList();
        return {
          for (var i = 0; i < ids.length; i++)
            ids[i]: i < dist.length ? dist[i] : 0.0,
        };
      }
      return {};
    } catch (e) {
      debugPrint('Falha ao buscar pessoas próximas: $e');
      return {};
    }
  }
}
