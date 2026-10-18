import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Indica se este aparelho concluiu a verificação de selfie com vivacidade.
class VerificationNotifier extends Notifier<bool> {
  static const _key = 'liveness_verified_v1';

  @override
  bool build() {
    SharedPreferences.getInstance().then((p) {
      if (p.getString(_key) != null) state = true;
    });
    return false;
  }

  Future<void> markVerified() async {
    state = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, DateTime.now().toIso8601String());
  }
}

final verificationProvider =
    NotifierProvider<VerificationNotifier, bool>(VerificationNotifier.new);
