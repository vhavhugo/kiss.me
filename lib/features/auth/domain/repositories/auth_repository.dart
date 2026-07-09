import '../entities/auth_user_entity.dart';

abstract class AuthRepository {
  Future<AuthUserEntity?> signInWithGoogle();
  Future<AuthUserEntity?> signInWithInstagram();
  Future<AuthUserEntity?> signInWithTikTok();
  Future<void> signOut();
  Stream<AuthUserEntity?> get authStateChanges;
}
