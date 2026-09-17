import '../entities/user_entity.dart';

abstract class RadarRepository {
  Future<void> updateLocation(String userId, double lat, double lng);
  Future<List<UserEntity>> getNearbyUsers(
    String userId,
    double lat,
    double lng,
    double radiusKm,
  );
  Future<bool> sendInteraction(dynamic interaction);
}
