import '../entities/auth_user_entity.dart';

abstract class AuthRepository {
  Future<AuthUserEntity?> signInWithGoogle();
  Future<void> signInWithTikTok();
  Future<void> signOut();
  Stream<AuthUserEntity?> get authStateChanges;
}
