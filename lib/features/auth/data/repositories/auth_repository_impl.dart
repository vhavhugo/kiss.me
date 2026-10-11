import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/auth_user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _supabase;

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _googleSignInInitialized = false;

  static const _googleServerClientId =
      '854347645823-llu6b8alkp8j40m6itj81139e5q2hu1r.apps.googleusercontent.com';

  AuthRepositoryImpl(this._supabase);

  Future<void> _ensureGoogleSignInInitialized() async {
    if (_googleSignInInitialized) return;
    await _googleSignIn.initialize(serverClientId: _googleServerClientId);
    _googleSignInInitialized = true;
  }

  @override
  Future<AuthUserEntity?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        await _supabase.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: _authCallbackUrl,
        );
        return null;
      }

      // 1. Inicia o fluxo de autenticação do Google
      await _ensureGoogleSignInInitialized();
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
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<AuthUserEntity?> signInWithTikTok() async {
    await _supabase.auth.signInWithOAuth(
      const OAuthProvider('tiktok'),
      redirectTo: _authCallbackUrl,
    );
    return null;
  }

  @override
  Future<AuthUserEntity?> signInWithInstagram() async {
    await _supabase.auth.signInWithOAuth(
      const OAuthProvider('facebook'),
      redirectTo: _authCallbackUrl,
    );
    return null;
  }

  @override
  Future<void> signOut() async {
    await _supabase.auth.signOut();
    if (!kIsWeb && _googleSignInInitialized) await _googleSignIn.signOut();
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

  String get _authCallbackUrl => '${_supabase.rest.url}/auth/v1/callback';
}
