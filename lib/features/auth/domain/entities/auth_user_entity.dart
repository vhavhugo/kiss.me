class AuthUserEntity {
  final String id;
  final String email;
  final bool isFirstLogin;

  AuthUserEntity({
    required this.id,
    required this.email,
    required this.isFirstLogin,
  });
}
