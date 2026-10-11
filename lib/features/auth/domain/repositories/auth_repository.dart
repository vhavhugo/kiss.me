import '../entities/auth_user_entity.dart';

abstract class AuthRepository {
  Future<AuthUserEntity?> signInWithGoogle();
  Future<AuthUserEntity?> signInWithTikTok();
  Future<AuthUserEntity?> signInWithInstagram();
  Future<void> signOut();
  Stream<AuthUserEntity?> get authStateChanges;
}
