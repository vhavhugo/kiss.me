import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Precisão da localização enviada ao servidor (cloaking por grade).
enum LocationPrecision {
  exact('Exata', 'Melhor para achar quem está bem perto.', 0),
  block('Quarteirão (~500 m)', 'Equilíbrio entre privacidade e utilidade.', 500),
  neighborhood('Bairro (~2 km)', 'Esconde onde você está dentro do bairro.', 2000),
  city('Região (~5 km)', 'Máxima privacidade; resultados mais genéricos.', 5000);

  final String label;
  final String description;
  final double cellMeters;
  const LocationPrecision(this.label, this.description, this.cellMeters);
}

class PrivacySettings {
  final LocationPrecision precision;
  final bool approximateDistance;
  final bool readReceipts;

  const PrivacySettings({
    this.precision = LocationPrecision.block,
    this.approximateDistance = true,
    this.readReceipts = true,
  });

  PrivacySettings copyWith({
    LocationPrecision? precision,
    bool? approximateDistance,
    bool? readReceipts,
  }) =>
      PrivacySettings(
        precision: precision ?? this.precision,
        approximateDistance: approximateDistance ?? this.approximateDistance,
        readReceipts: readReceipts ?? this.readReceipts,
      );

  /// Move a posição para o centro de uma célula da grade. A posição enviada é
  /// sempre a mesma dentro da célula (sem ruído aleatório), o que impede
  /// calcular a posição real por várias consultas com ruído.
  ({double lat, double lng}) cloak(double lat, double lng) {
    final cell = precision.cellMeters;
    if (cell <= 0) return (lat: lat, lng: lng);
    final latStep = cell / 111320.0;
    final lngStep =
        cell / (111320.0 * math.max(0.01, math.cos(lat * math.pi / 180)));
    return (
      lat: ((lat / latStep).floor() + 0.5) * latStep,
      lng: ((lng / lngStep).floor() + 0.5) * lngStep,
    );
  }

  /// Texto de distância; em modo aproximado, usa faixas em vez de metros exatos.
  String distanceText(double meters) {
    if (!approximateDistance) {
      if (meters <= 0) return 'a poucos metros';
      if (meters < 1000) return '${meters.round()} m';
      return '${(meters / 1000).toStringAsFixed(1)} km';
    }
    if (meters < 500) return 'a menos de 500 m';
    if (meters < 1000) return 'a menos de 1 km';
    if (meters < 2000) return 'a cerca de 1–2 km';
    if (meters < 5000) return 'a cerca de 2–5 km';
    return 'a mais de 5 km';
  }
}

class PrivacySettingsNotifier extends Notifier<PrivacySettings> {
  static const _kPrecision = 'privacy_precision_v1';
  static const _kDistance = 'privacy_approx_distance_v1';
  static const _kReceipts = 'privacy_read_receipts_v1';

  @override
  PrivacySettings build() {
    _load();
    return const PrivacySettings();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    state = PrivacySettings(
      precision: LocationPrecision.values.firstWhere(
        (e) => e.name == p.getString(_kPrecision),
        orElse: () => LocationPrecision.block,
      ),
      approximateDistance: p.getBool(_kDistance) ?? true,
      readReceipts: p.getBool(_kReceipts) ?? true,
    );
  }

  Future<void> setPrecision(LocationPrecision v) async {
    state = state.copyWith(precision: v);
    (await SharedPreferences.getInstance()).setString(_kPrecision, v.name);
  }

  Future<void> setApproximateDistance(bool v) async {
    state = state.copyWith(approximateDistance: v);
    (await SharedPreferences.getInstance()).setBool(_kDistance, v);
  }

  Future<void> setReadReceipts(bool v) async {
    state = state.copyWith(readReceipts: v);
    (await SharedPreferences.getInstance()).setBool(_kReceipts, v);
  }
}

final privacySettingsProvider =
    NotifierProvider<PrivacySettingsNotifier, PrivacySettings>(
  PrivacySettingsNotifier.new,
);
