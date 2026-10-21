import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../chat/domain/entities/chat_message.dart';
import '../../../chat/presentation/providers/chat_provider.dart';
import '../../../radar/domain/entities/interaction_entity.dart';
import '../../../radar/presentation/providers/interactions_provider.dart';
import '../../../safety/presentation/providers/safety_provider.dart';
import 'notification_state_provider.dart';

class NotificationItem {
  final String key;
  final String peerId;
  final String peerName;
  final String peerPhoto;
  final DateTime at;
  final String title;
  final ActionType? type;
  final String? preview;
  const NotificationItem({
    required this.key,
    required this.peerId,
    required this.peerName,
    required this.peerPhoto,
    required this.at,
    required this.title,
    this.type,
    this.preview,
  });
}

String _preview(ChatMessage m) => switch (m.type) {
      ChatMessageType.text => m.content,
      ChatMessageType.audio => '🎤 Áudio',
      ChatMessageType.video => '🎬 Vídeo',
      ChatMessageType.image => '📷 Foto',
    };

/// Notificações visíveis (brincadeiras + mensagens não lidas), mais novas primeiro.
final notificationItemsProvider = Provider<List<NotificationItem>>((ref) {
  final blocked = ref.watch(blockedUsersProvider);
  final me = ref.watch(authProvider).user?.id ?? 'anonymous';
  final state = ref.watch(notificationStateProvider);
  final records = ref
      .watch(interactionsProvider)
      .where((r) => !blocked.contains(r.toUserId))
      .toList();

  final all = <NotificationItem>[];
  final peers = <String, InteractionRecord>{};
  for (final r in records) {
    peers.putIfAbsent(r.toUserId, () => r);
    all.add(NotificationItem(
      key: 'i|${r.toUserId}|${r.type.name}|${r.createdAt.toIso8601String()}',
      peerId: r.toUserId,
      peerName: r.toUserName,
      peerPhoto: r.toUserPhotoUrl,
      at: r.createdAt,
      type: r.type,
      title: r.incoming
          ? '${r.toUserName} ${r.type.receivedMessage}'
          : '${r.type.sentMessage} ${r.toUserName}',
    ));
  }
  for (final peer in peers.values) {
    final msgs = ref
            .watch(chatMessagesProvider(conversationIdFor(me, peer.toUserId)))
            .asData
            ?.value ??
        const <ChatMessage>[];
    final unread = msgs
        .where((m) =>
            m.senderId != me &&
            m.readAt == null &&
            !m.isDeleted &&
            !m.hiddenBy.contains(me))
        .toList();
    if (unread.isEmpty) continue;
    final last = unread.last;
    all.add(NotificationItem(
      key: 'm|${peer.toUserId}|${last.id}',
      peerId: peer.toUserId,
      peerName: peer.toUserName,
      peerPhoto: peer.toUserPhotoUrl,
      at: last.createdAt,
      title: unread.length > 1
          ? '${peer.toUserName} enviou ${unread.length} mensagens'
          : '${peer.toUserName} enviou uma mensagem',
      preview: _preview(last),
    ));
  }
  return all.where((i) => !state.dismissed.contains(i.key)).toList()
    ..sort((a, b) => b.at.compareTo(a.at));
});

/// Quantidade de notificações ainda não lidas (mostrada no selo de Ajustes).
final unreadNotificationsCountProvider = Provider<int>((ref) {
  final read = ref.watch(notificationStateProvider).read;
  return ref
      .watch(notificationItemsProvider)
      .where((i) => !read.contains(i.key))
      .length;
});
