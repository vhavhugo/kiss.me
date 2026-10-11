class AuthUserEntity {
  final String id;
  final String email;
  final bool isFirstLogin;

  const AuthUserEntity({
    required this.id,
    required this.email,
    required this.isFirstLogin,
  });
}
