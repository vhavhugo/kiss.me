import 'package:flutter_riverpod/flutter_riverpod.dart';
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

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(AuthState(status: AuthStatus.unauthenticated));

  Future<void> loginWithGoogle() async {
    state = state.copyWith(status: AuthStatus.authenticating);
    try {
      final user = await _repository.signInWithGoogle();
      
      if (user != null) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
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

  // Fallback para login manual/mock
  Future<void> login(String provider) async {
    state = state.copyWith(status: AuthStatus.authenticating);
    await Future.delayed(const Duration(seconds: 2));
    final mockUser = AuthUserEntity(
      id: 'uuid-12345',
      email: 'usuario@$provider.com',
      isFirstLogin: true,
    );
    state = state.copyWith(
      status: AuthStatus.authenticated,
      user: mockUser,
      isOnline: true,
    );
  }

  void setOnboardingComplete() {
    state = state.copyWith(status: AuthStatus.authenticated);
  }

  void toggleOnlineStatus() {
    state = state.copyWith(isOnline: !state.isOnline);
  }

  void logout() {
    state = AuthState(status: AuthStatus.unauthenticated);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authRepositoryProvider));
});
