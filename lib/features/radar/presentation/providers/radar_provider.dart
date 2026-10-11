import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/util/location_service.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/mock/mock_radar_repository.dart';
import '../../data/datasources/radar_remote_datasource.dart';
import '../../data/repositories/radar_repository_impl.dart';
import '../../domain/repositories/radar_repository.dart';

final supabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

final radarRemoteDataSourceProvider = Provider<RadarRemoteDataSource>((ref) {
  return RadarRemoteDataSource(ref.read(supabaseProvider));
});

final radarRepositoryProvider = Provider<RadarRepository>((ref) {
  final isMock = ref.watch(isMockModeProvider);
  if (isMock) {
    return MockRadarRepository();
  }
  return RadarRepositoryImpl(
    ref.read(radarRemoteDataSourceProvider),
    ref.read(supabaseProvider),
  );
});
