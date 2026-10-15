import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/interaction_entity.dart';
import '../../domain/entities/user_entity.dart';
import 'radar_provider.dart';

/// Guarda as brincadeiras (beijo, abraço, aperto de mão, passeio) enviadas
/// pelo usuário, por conta, e alimenta a tela de Notificações.
class InteractionsNotifier extends Notifier<List<InteractionRecord>> {
  String? _ownerId;

  static String _key(String userId) => 'interactions_v1_$userId';

  @override
  List<InteractionRecord> build() => const [];

  Future<void> load(String userId) async {
    _ownerId = userId;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(userId));
    if (raw == null) {
      state = const [];
      return;
    }
    final list = (jsonDecode(raw) as List)
        .map((e) => InteractionRecord.fromJson(e as Map<String, dynamic>))
        .toList();
    state = list;
  }

  Future<void> send({
    required String fromUserId,
    required UserEntity target,
    required ActionType type,
  }) async {
    if (_ownerId != fromUserId) await load(fromUserId);

    final record = InteractionRecord(
      toUserId: target.id,
      toUserName: target.name,
      toUserPhotoUrl: target.photoUrl,
      type: type,
      createdAt: DateTime.now(),
    );
    state = [record, ...state];

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key(fromUserId),
      jsonEncode(state.map((r) => r.toJson()).toList()),
    );

    try {
      await ref.read(radarRepositoryProvider).sendInteraction(
            InteractionEntity(
              fromUserId: fromUserId,
              toUserId: target.id,
              type: type,
            ),
          );
    } catch (_) {
      // O registro local já foi salvo; falha de rede não perde a brincadeira.
    }
  }

  Future<void> clear() async {
    final id = _ownerId;
    state = const [];
    if (id == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key(id));
  }
}

final interactionsProvider =
    NotifierProvider<InteractionsNotifier, List<InteractionRecord>>(
  InteractionsNotifier.new,
);
