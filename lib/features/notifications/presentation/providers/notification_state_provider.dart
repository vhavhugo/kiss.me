import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Estado das notificações (lidas e removidas), salvo por conta.
/// Remover aqui não apaga nada dos Chats nem do histórico de brincadeiras.
class NotificationState {
  final Set<String> read;
  final Set<String> dismissed;
  const NotificationState({this.read = const {}, this.dismissed = const {}});
}

class NotificationStateNotifier extends Notifier<NotificationState> {
  String? _owner;

  @override
  NotificationState build() => const NotificationState();

  Future<void> load(String userId) async {
    _owner = userId;
    final prefs = await SharedPreferences.getInstance();
    state = NotificationState(
      read: (prefs.getStringList('notif_read_v1_$userId') ?? []).toSet(),
      dismissed:
          (prefs.getStringList('notif_dismissed_v1_$userId') ?? []).toSet(),
    );
  }

  Future<void> _persist() async {
    final id = _owner;
    if (id == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('notif_read_v1_$id', state.read.toList());
    await prefs.setStringList('notif_dismissed_v1_$id', state.dismissed.toList());
  }

  Future<void> markRead(String key) async {
    if (state.read.contains(key)) return;
    state = NotificationState(
        read: {...state.read, key}, dismissed: state.dismissed);
    await _persist();
  }

  Future<void> dismiss(String key) async {
    state = NotificationState(
        read: {...state.read, key}, dismissed: {...state.dismissed, key});
    await _persist();
  }
}

final notificationStateProvider =
    NotifierProvider<NotificationStateNotifier, NotificationState>(
  NotificationStateNotifier.new,
);
