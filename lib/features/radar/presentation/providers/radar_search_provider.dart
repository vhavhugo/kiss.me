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
    state = state.copyWith(isSearching: true, users: [], currentRadiusKm: 0.5);
    _performSearch(lat, lng);
  }

  void _performSearch(double lat, double lng) async {
    // 1. Atualiza apenas a flag de busca, mas mantém o raio visual aumentando
    final users = await _repository.getNearbyUsers(lat, lng, state.currentRadiusKm);

    if (users.isNotEmpty) {
      // Delay sutil para o usuário ver o número final antes das cartas aparecerem
      await Future.delayed(const Duration(milliseconds: 800));
      state = state.copyWith(users: users, isSearching: false);
      _expansionTimer?.cancel();
    } else {
      // Se não encontrou, aumenta o raio gradativamente
      if (state.currentRadiusKm < 20.0) { // Limite razoável de 20km
        _expansionTimer = Timer(const Duration(seconds: 2), () {
          double nextRadius = _getNextRadius(state.currentRadiusKm);
          state = state.copyWith(currentRadiusKm: nextRadius);
          _performSearch(lat, lng);
        });
      } else {
        state = state.copyWith(isSearching: false);
      }
    }
  }

  double _getNextRadius(double current) {
    // Incrementos mais fluidos e realistas
    if (current < 1.0) return current + 0.2; // +200m
    if (current < 5.0) return current + 0.5; // +500m
    return current + 1.0; // +1km
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
