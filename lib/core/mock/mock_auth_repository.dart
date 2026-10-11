import 'dart:async';
import '../../features/auth/domain/entities/auth_user_entity.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  final _controller = StreamController<AuthUserEntity?>.broadcast();
  AuthUserEntity? _currentUser;

  MockAuthRepository() {
    // Inicia deslogado para permitir autenticação via botões da tela de login
    _currentUser = null;
  }

  @override
  Stream<AuthUserEntity?> get authStateChanges => _controller.stream;

  @override
  Future<AuthUserEntity?> signInWithGoogle() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = const AuthUserEntity(
      id: 'mock-google-user',
      email: 'google.usuario@kissme.app',
      isFirstLogin: false,
    );
    _controller.add(_currentUser);
    return _currentUser;
  }

  @override
  Future<AuthUserEntity?> signInWithInstagram() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = const AuthUserEntity(
      id: 'mock-instagram-user',
      email: 'instagram.usuario@kissme.app',
      isFirstLogin: false,
    );
    _controller.add(_currentUser);
    return _currentUser;
  }

  @override
  Future<AuthUserEntity?> signInWithTikTok() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = const AuthUserEntity(
      id: 'mock-tiktok-user',
      email: 'tiktok.usuario@kissme.app',
      isFirstLogin: false,
    );
    _controller.add(_currentUser);
    return _currentUser;
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _currentUser = null;
    _controller.add(null);
  }
}
