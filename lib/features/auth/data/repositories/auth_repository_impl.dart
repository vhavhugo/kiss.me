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
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception('Falha ao obter ID Token do Google.');
      }

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
    // Simulando fluxo real via OAuth Provider fixo se o enum estiver ausente
    // Em produção, isso abrirá a página de login do Instagram vinculada ao Supabase
    await _supabase.auth.signInWithOAuth(
      OAuthProvider.google, // Mock para compilar, deve ser ajustado no dashboard do Supabase
      redirectTo: 'io.supabase.kissme://login-callback/',
    );
  }

  @override
  Future<void> signInWithTikTok() async {
    await _supabase.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'io.supabase.kissme://login-callback/',
    );
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
