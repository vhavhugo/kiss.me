import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AgeStatus { loading, unknown, adult, blocked }

/// Portão de idade (18+). Guarda apenas o resultado (maior de idade ou
/// bloqueado), nunca a data de nascimento informada nesta etapa.
class AgeGateNotifier extends Notifier<AgeStatus> {
  static const minAge = 18;
  String? _userId;

  static String _key(String id) => 'age_gate_v1_$id';

  @override
  AgeStatus build() => AgeStatus.loading;

  Future<void> load(String userId) async {
    if (_userId == userId && state != AgeStatus.loading) return;
    _userId = userId;
    state = AgeStatus.loading;
    final prefs = await SharedPreferences.getInstance();
    // O bloqueio vale para o aparelho, para que não dê para tentar outra data.
    if (prefs.getBool('age_blocked_device_v1') ?? false) {
      state = AgeStatus.blocked;
      return;
    }
    state = switch (prefs.getString(_key(userId))) {
      'adult' => AgeStatus.adult,
      'blocked' => AgeStatus.blocked,
      _ => AgeStatus.unknown,
    };
  }

  static int ageOf(DateTime birth, [DateTime? now]) {
    final n = now ?? DateTime.now();
    var age = n.year - birth.year;
    if (n.month < birth.month || (n.month == birth.month && n.day < birth.day)) {
      age--;
    }
    return age;
  }

  /// Retorna true se a pessoa tem 18 anos ou mais.
  Future<bool> declare(String userId, DateTime birth) async {
    final adult = ageOf(birth) >= minAge;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key(userId), adult ? 'adult' : 'blocked');
    if (!adult) await prefs.setBool('age_blocked_device_v1', true);
    state = adult ? AgeStatus.adult : AgeStatus.blocked;
    return adult;
  }
}

final ageGateProvider =
    NotifierProvider<AgeGateNotifier, AgeStatus>(AgeGateNotifier.new);
