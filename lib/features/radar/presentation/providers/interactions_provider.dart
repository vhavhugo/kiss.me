import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/interaction_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../../../core/config/app_config.dart';
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
    final stored = raw == null
        ? <InteractionRecord>[]
        : (jsonDecode(raw) as List)
              .map((e) => InteractionRecord.fromJson(e as Map<String, dynamic>))
              .toList();
    final all = [
      ...stored,
      if (ref.read(isMockModeProvider)) ..._demoIncoming(),
    ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    state = all;
  }

  Future<void> send({
    required String fromUserId,
    required UserEntity target,
    required ActionType type,
    String answer = '',
    InteractionSource source = InteractionSource.kissMe,
  }) async {
    if (_ownerId != fromUserId) await load(fromUserId);

    final record = InteractionRecord(
      toUserId: target.id,
      toUserName: target.name,
      toUserPhotoUrl: target.photoUrl,
      type: type,
      createdAt: DateTime.now(),
      answer: answer,
      source: source,
    );
    state = [record, ...state];

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key(fromUserId),
      jsonEncode(
        state.where((r) => !r.incoming).map((r) => r.toJson()).toList(),
      ),
    );

    try {
      await ref
          .read(radarRepositoryProvider)
          .sendInteraction(
            InteractionEntity(
              fromUserId: fromUserId,
              toUserId: target.id,
              type: type,
              answer: answer,
            ),
          );
    } catch (_) {
      // O registro local já foi salvo; falha de rede não perde a brincadeira.
    }
  }

  // Apenas no modo demonstração: simula pessoas que interagiram com você.
  List<InteractionRecord> _demoIncoming() {
    final now = DateTime.now();
    return [
      InteractionRecord(
        toUserId: 'mock-user-1',
        toUserName: 'Camila, 24',
        toUserPhotoUrl:
            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=600&auto=format&fit=crop&q=80',
        type: ActionType.hug,
        createdAt: now.subtract(const Duration(minutes: 40)),
        incoming: true,
      ),
      InteractionRecord(
        toUserId: 'mock-user-2',
        toUserName: 'Lucas, 26',
        toUserPhotoUrl:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=600&auto=format&fit=crop&q=80',
        type: ActionType.kiss,
        createdAt: now.subtract(const Duration(hours: 3)),
        incoming: true,
      ),
    ];
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
