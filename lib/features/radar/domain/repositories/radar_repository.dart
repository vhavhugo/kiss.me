import '../entities/user_entity.dart';

abstract class RadarRepository {
  Future<List<UserEntity>> getNearbyUsers(double lat, double lng, double radiusKm);
  Future<bool> sendInteraction(dynamic interaction);
}
