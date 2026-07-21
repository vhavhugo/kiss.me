import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/auth_user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _supabase;
  
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  AuthRepositoryImpl(this._supabase);

  @override
  Future<AuthUserEntity?> signInWithGoogle() async {
    try {
      // 1. Inicia o fluxo de autenticação do Google
      final googleAccount = await _googleSignIn.authenticate();

      // 2. Obtém o ID Token (Obrigatório para Supabase)
      final idToken = googleAccount.authentication.idToken;

      if (idToken == null) {
        throw Exception('Falha ao obter ID Token do Google.');
      }

      // 3. Obtém o Access Token (Opcional, mas recomendado)
      // Na v7.2.0, o accessToken foi movido para o authorizationClient
      final authz = await googleAccount.authorizationClient.authorizeScopes(['email']);
      final accessToken = authz.accessToken;

      // 4. Conecta com o Supabase
      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      final user = response.user;
      if (user == null) return null;

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
  Future<void> signInWithInstagram() async {
    try {
      await _supabase.auth.signInWithOAuth(
        const OAuthProvider('instagram'),
        redirectTo: 'https://tfjnbbybrdcmjxwlcuzw.supabase.co/auth/v1/callback',
      );
    } catch (e) {
      return;
    }
  }

  @override
  Future<void> signInWithTikTok() async {
    try {
      await _supabase.auth.signInWithOAuth(
        const OAuthProvider('tiktok'),
        redirectTo: 'https://tfjnbbybrdcmjxwlcuzw.supabase.co/auth/v1/callback',
      );
    } catch (e) {
      return;
    }
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
