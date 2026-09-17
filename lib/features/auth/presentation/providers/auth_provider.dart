import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/auth_user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../../radar/presentation/providers/radar_provider.dart';

enum AuthStatus { unauthenticated, authenticating, authenticated, onboarding }

class AuthState {
  final AuthStatus status;
  final AuthUserEntity? user;
  final bool isOnline;

  AuthState({
    required this.status,
    this.user,
    this.isOnline = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    AuthUserEntity? user,
    bool? isOnline,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.read(supabaseProvider));
});

class AuthNotifier extends Notifier<AuthState> {
  late final AuthRepository _repository;

  @override
  AuthState build() {
    _repository = ref.read(authRepositoryProvider);
    final currentUser = Supabase.instance.client.auth.currentUser;
    final subscription = _repository.authStateChanges.listen((user) {
      if (user == null) {
        state = AuthState(status: AuthStatus.unauthenticated);
      } else {
        state = AuthState(
          status: user.isFirstLogin ? AuthStatus.onboarding : AuthStatus.authenticated,
          user: user,
          isOnline: true,
        );
      }
    });
    ref.onDispose(subscription.cancel);

    if (currentUser == null) {
      return AuthState(status: AuthStatus.unauthenticated);
    }
    return AuthState(
      status: AuthStatus.authenticated,
      user: AuthUserEntity(
        id: currentUser.id,
        email: currentUser.email ?? '',
        isFirstLogin: false,
      ),
      isOnline: true,
    );
  }

  Future<void> loginWithGoogle() async {
    state = state.copyWith(status: AuthStatus.authenticating);
    try {
      final user = await _repository.signInWithGoogle();
      if (user != null) {
        state = state.copyWith(
          status: user.isFirstLogin ? AuthStatus.onboarding : AuthStatus.authenticated,
          user: user,
          isOnline: true,
        );
      } else {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
      rethrow;
    }
  }

  Future<void> loginWithTikTok() async {
    state = state.copyWith(status: AuthStatus.authenticating);
    try {
      await _repository.signInWithTikTok();
    } catch (e) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
      rethrow;
    }
  }

  void setOnboardingComplete() {
    state = state.copyWith(status: AuthStatus.authenticated);
  }

  void toggleOnlineStatus() {
    state = state.copyWith(isOnline: !state.isOnline);
  }

  void logout() {
    _repository.signOut();
    state = AuthState(status: AuthStatus.unauthenticated);
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
