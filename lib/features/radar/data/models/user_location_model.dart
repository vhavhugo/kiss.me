class UserLocationModel {
  final String userId;
  final double latitude;
  final double longitude;

  UserLocationModel({
    required this.userId,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'lat': latitude,
        'lng': longitude,
      };
}
