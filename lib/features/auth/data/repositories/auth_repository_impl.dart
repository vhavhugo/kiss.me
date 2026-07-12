import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/auth_user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _supabase;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  AuthRepositoryImpl(this._supabase);

  @override
  Future<AuthUserEntity?> signInWithGoogle() async {
    try {
      // 1. Inicia o fluxo de login do Google no dispositivo
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // Usuário cancelou

      // 2. Obtém os tokens de autenticação do Google
      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception('Falha ao obter ID Token do Google.');
      }

      // 3. Autentica no Supabase usando o ID Token do Google
      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      final user = response.user;
      if (user == null) return null;

      // 4. Retorna a nossa entidade de domínio
      return AuthUserEntity(
        id: user.id,
        email: user.email ?? '',
        isFirstLogin: true,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<AuthUserEntity?> signInWithInstagram() async {
    return null;
  }

  @override
  Future<AuthUserEntity?> signInWithTikTok() async {
    return null;
  }

  @override
  Future<void> signOut() async {
    await Future.wait([
      _supabase.auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  @override
  Stream<AuthUserEntity?> get authStateChanges =>
      _supabase.auth.onAuthStateChange.map((authState) {
        final user = authState.session?.user;
        if (user == null) return null;
        return AuthUserEntity(
          id: user.id,
          email: user.email ?? '',
          isFirstLogin: false,
        );
      });
}
