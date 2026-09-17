import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/radar_repository.dart';
import '../providers/radar_provider.dart';

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

class RadarSearchNotifier extends Notifier<RadarSearchState> {
  late final RadarRepository _repository;
  Timer? _expansionTimer;

  @override
  RadarSearchState build() {
    _repository = ref.read(radarRepositoryProvider);
    // Não temos um super.dispose(), o Notifier limpa no ref.onDispose
    ref.onDispose(() {
      _expansionTimer?.cancel();
    });
    return RadarSearchState(users: [], currentRadiusKm: 0.5, isSearching: false);
  }

  void startSearch(String userId, double lat, double lng) async {
    _expansionTimer?.cancel();
    state = state.copyWith(isSearching: true, users: [], currentRadiusKm: 0.2); // Inicia com 200m
    await _repository.updateLocation(userId, lat, lng);
    _performSearch(userId, lat, lng);
  }

  void stopSearch() {
    _expansionTimer?.cancel();
    state = state.copyWith(isSearching: false, users: [], currentRadiusKm: 0.0);
  }

  void _performSearch(String userId, double lat, double lng) async {
    if (!state.isSearching) return;

    final users = await _repository.getNearbyUsers(
      userId,
      lat,
      lng,
      state.currentRadiusKm,
    );

    if (users.isNotEmpty) {
      state = state.copyWith(users: users, isSearching: false);
      _expansionTimer?.cancel();
    } else {
      if (state.currentRadiusKm < 50.0) {
        _expansionTimer = Timer(const Duration(seconds: 2), () {
          final nextRadius = _getNextRadius(state.currentRadiusKm);
          state = state.copyWith(currentRadiusKm: nextRadius);
          _performSearch(userId, lat, lng);
        });
      } else {
        state = state.copyWith(isSearching: false);
      }
    }
  }

  double _getNextRadius(double current) {
    if (current < 1.0) return current + 0.1;
    if (current < 5.0) return current + 0.5;
    return current + 2.0;
  }
}

final radarSearchProvider = NotifierProvider<RadarSearchNotifier, RadarSearchState>(RadarSearchNotifier.new);
