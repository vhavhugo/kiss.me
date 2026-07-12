import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/auth_user_entity.dart';

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

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState(status: AuthStatus.unauthenticated));

  Future<void> login(String provider) async {
    state = state.copyWith(status: AuthStatus.authenticating);
    
    // Simula um delay de rede realista
    await Future.delayed(const Duration(seconds: 2));

    // Mock do usuário autenticado
    final mockUser = AuthUserEntity(
      id: 'uuid-12345',
      email: 'usuario@$provider.com',
      isFirstLogin: true,
    );

    state = state.copyWith(
      status: AuthStatus.authenticated,
      user: mockUser,
      isOnline: true, // Aqui o usuário fica oficialmente "On-line"
    );
  }

  void setOnboardingComplete() {
    state = state.copyWith(status: AuthStatus.authenticated);
  }

  void logout() {
    state = AuthState(status: AuthStatus.unauthenticated);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
