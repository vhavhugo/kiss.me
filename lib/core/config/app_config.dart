import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Define se o aplicativo deve rodar em modo Mock (Offline / Demonstração)
/// sem exigir conexão ou configuração ativa no Supabase.
/// Pode ser controlado via:
/// --dart-define=USE_MOCK=true (ou false)
const bool kDefaultUseMock = bool.fromEnvironment('USE_MOCK', defaultValue: true);

class MockModeNotifier extends Notifier<bool> {
  @override
  bool build() {
    return kDefaultUseMock;
  }

  void setMockMode(bool value) {
    state = value;
  }

  void toggle() {
    state = !state;
  }
}

final isMockModeProvider = NotifierProvider<MockModeNotifier, bool>(MockModeNotifier.new);
