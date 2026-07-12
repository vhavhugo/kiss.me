import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/radar_repository.dart';
import '../providers/radar_provider.dart'; // Assumindo que o repository provider está aqui

class RadarSearchState {
  final List<UserEntity> users;
  final double currentRadiusKm;
  final bool isSearching;

  RadarSearchState({
    required this.users,
    required this.currentRadiusKm,
    required this.isSearching,
  });

  RadarSearchState copyWith({
    List<UserEntity>? users,
    double? currentRadiusKm,
    bool? isSearching,
  }) {
    return RadarSearchState(
      users: users ?? this.users,
      currentRadiusKm: currentRadiusKm ?? this.currentRadiusKm,
      isSearching: isSearching ?? this.isSearching,
    );
  }
}

class RadarSearchNotifier extends StateNotifier<RadarSearchState> {
  final RadarRepository _repository;
  Timer? _expansionTimer;

  RadarSearchNotifier(this._repository)
      : super(RadarSearchState(users: [], currentRadiusKm: 0.5, isSearching: false));

  void startSearch(double lat, double lng) async {
    _expansionTimer?.cancel();
    state = state.copyWith(isSearching: true, users: [], currentRadiusKm: 0.2); // Inicia com 200m
    _performSearch(lat, lng);
  }

  void stopSearch() {
    _expansionTimer?.cancel();
    state = state.copyWith(isSearching: false, users: [], currentRadiusKm: 0.0); // Zera o raio para efeito Offline
  }

  void _performSearch(double lat, double lng) async {
    // Se estiver Offline, para tudo
    if (!state.isSearching) return;

    // 1. Consulta ao backend
    final users = await _repository.getNearbyUsers(lat, lng, state.currentRadiusKm);

    if (users.isNotEmpty) {
      // ENCONTROU: Para a expansão e mostra os resultados
      state = state.copyWith(users: users, isSearching: false);
      _expansionTimer?.cancel();
    } else {
      // NÃO ENCONTROU: Aumenta o raio visualmente E continua a busca
      if (state.currentRadiusKm < 50.0) {
        _expansionTimer = Timer(const Duration(seconds: 2), () {
          final nextRadius = _getNextRadius(state.currentRadiusKm);
          state = state.copyWith(currentRadiusKm: nextRadius);
          _performSearch(lat, lng);
        });
      } else {
        state = state.copyWith(isSearching: false);
      }
    }
  }

  double _getNextRadius(double current) {
    // Incrementos garantidos para o usuário ver o KM subindo
    if (current < 1.0) return current + 0.1; // +100m (mais suave)
    if (current < 5.0) return current + 0.5; // +500m
    return current + 2.0; // +2km
  }

  @override
  void dispose() {
    _expansionTimer?.cancel();
    super.dispose();
  }
}

final radarSearchProvider = StateNotifierProvider<RadarSearchNotifier, RadarSearchState>((ref) {
  return RadarSearchNotifier(ref.read(radarRepositoryProvider));
});
