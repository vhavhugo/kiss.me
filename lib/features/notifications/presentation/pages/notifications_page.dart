import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../radar/domain/entities/interaction_entity.dart';
import '../../../radar/presentation/providers/interactions_provider.dart';

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
      Future.microtask(
          () => ref.read(interactionsProvider.notifier).load(user.id));
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

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(interactionsProvider);
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
          : ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final r = items[i];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _color(r.type).withAlpha(30),
                    child: r.type == ActionType.kiss
                        ? ClipOval(
                            child: Image.asset(
                                'assets/images/kiss_action_icon.png',
                                fit: BoxFit.cover),
                          )
                        : Text(r.type.emoji,
                            style: const TextStyle(fontSize: 22)),
                  ),
                  title: Text(r.incoming
                      ? '${r.toUserName} ${r.type.receivedMessage}'
                      : '${r.type.sentMessage} ${r.toUserName}'),
                  subtitle: Text(_time(r.createdAt)),
                  trailing: r.toUserPhotoUrl.isEmpty
                      ? null
                      : CircleAvatar(
                          backgroundImage: NetworkImage(r.toUserPhotoUrl),
                          backgroundColor: AppColors.offline,
                        ),
                );
              },
            ),
    );
  }
}
