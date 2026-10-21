import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../radar/domain/entities/interaction_entity.dart';
import '../../../radar/presentation/providers/interactions_provider.dart';
import '../../../chat/presentation/pages/conversation_page.dart';
import '../providers/notification_state_provider.dart';
import '../providers/notification_items_provider.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    if (user != null) {
      Future.microtask(() {
        ref.read(interactionsProvider.notifier).load(user.id);
        ref.read(notificationStateProvider.notifier).load(user.id);
      });
    }
  }

  Color _color(ActionType t) {
    switch (t) {
      case ActionType.kiss:
        return Colors.pink;
      case ActionType.hug:
        return Colors.blue;
      case ActionType.handshake:
        return Colors.orange;
      case ActionType.walk:
        return Colors.green;
    }
  }

  String _time(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 1) return 'agora';
    if (diff.inHours < 1) return 'há ${diff.inMinutes} min';
    if (diff.inDays < 1) return 'há ${diff.inHours} h';
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  void _open(NotificationItem item) {
    ref.read(notificationStateProvider.notifier).markRead(item.key);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ConversationPage(
          peerId: item.peerId,
          peerName: item.peerName,
          peerPhotoUrl: item.peerPhoto,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationStateProvider);
    final items = ref.watch(notificationItemsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Notificações')),
      body: items.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Nenhuma notificação ainda.\nEnvie um beijo, abraço, aperto de mão ou passeio no bosque!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54),
                ),
              ),
            )
          : ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, i) {
                final item = items[i];
                final unread = !state.read.contains(item.key);
                return Dismissible(
                  key: ValueKey(item.key),
                  background: _swipeBg(Alignment.centerLeft, AppColors.primary,
                      Icons.chat_bubble_outline, 'Abrir'),
                  secondaryBackground: _swipeBg(Alignment.centerRight,
                      Colors.red, Icons.delete_outline, 'Excluir'),
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.startToEnd) {
                      _open(item);
                      return false;
                    }
                    return true;
                  },
                  onDismissed: (_) {
                    ref.read(notificationStateProvider.notifier).dismiss(item.key);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Notificação removida.'),
                          duration: Duration(seconds: 2)),
                    );
                  },
                  child: _tile(item, unread),
                );
              },
            ),
    );
  }

  Widget _swipeBg(Alignment align, Color color, IconData icon, String label) {
    return Container(
      color: color,
      alignment: align,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _tile(NotificationItem item, bool unread) {
    final type = item.type;
    final accent = type == null ? AppColors.primary : _color(type);
    return Container(
      decoration: BoxDecoration(
        color: unread ? AppColors.primary.withAlpha(18) : AppColors.background,
        border: Border(
          left: BorderSide(
              color: unread ? AppColors.primary : Colors.transparent, width: 4),
          bottom: const BorderSide(color: Colors.black12, width: 0.5),
        ),
      ),
      child: ListTile(
        onTap: () => _open(item),
        leading: CircleAvatar(
          backgroundColor: accent.withAlpha(30),
          child: type == null
              ? const Icon(Icons.chat_bubble_rounded,
                  color: AppColors.primary, size: 22)
              : type == ActionType.kiss
                  ? ClipOval(
                      child: Image.asset('assets/images/kiss_action_icon.png',
                          fit: BoxFit.cover),
                    )
                  : Text(type.emoji, style: const TextStyle(fontSize: 22)),
        ),
        title: Text(
          item.title,
          style: TextStyle(
              fontWeight: unread ? FontWeight.w800 : FontWeight.w500),
        ),
        subtitle: Text(
          item.preview == null
              ? _time(item.at)
              : '${item.preview} · ${_time(item.at)}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (item.peerPhoto.isNotEmpty)
              CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage(item.peerPhoto),
                backgroundColor: AppColors.offline,
              ),
            if (unread) ...[
              const SizedBox(width: 8),
              const CircleAvatar(radius: 5, backgroundColor: AppColors.primary),
            ],
          ],
        ),
      ),
    );
  }
}
