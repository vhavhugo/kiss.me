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
  Future<List<String>> getNearbyUserIds(double lat, double lng, double radiusKm) async {
    try {
      final response = await _supabase.functions.invoke(
        'search-nearby',
        body: {'lat': lat, 'lng': lng, 'radius': radiusKm},
      );

      if (response.status == 200) {
        return List<String>.from(response.data['ids']);
      }
      return [];
    } catch (e) {
      debugPrint('Falha ao buscar pessoas próximas: $e');
      return [];
    }
  }
}
