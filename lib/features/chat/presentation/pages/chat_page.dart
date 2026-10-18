import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../safety/presentation/providers/safety_provider.dart';
import '../../../radar/domain/entities/interaction_entity.dart';
import '../../../radar/presentation/providers/interactions_provider.dart';
import '../../domain/entities/chat_message.dart';
import '../providers/chat_provider.dart';
import '../widgets/conversation_avatar.dart';
import 'conversation_page.dart';

/// Pessoa com quem já houve alguma interação (enviada ou recebida).
class _Contact {
  final String id;
  final String name;
  final String photoUrl;
  final InteractionRecord last;
  final int count;

  const _Contact({
    required this.id,
    required this.name,
    required this.photoUrl,
    required this.last,
    required this.count,
  });
}

enum _Filter { all, received, sent }

/// Caixa de entrada: lista de pessoas que interagiram com você ou com quem
/// você interagiu. Tocar em uma pessoa abre a conversa.
class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final _searchController = TextEditingController();
  _Filter _filter = _Filter.all;
  String _query = '';

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    if (user != null) {
      Future.microtask(
          () => ref.read(interactionsProvider.notifier).load(user.id));
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_Contact> _contacts(List<InteractionRecord> records) {
    final byPeer = <String, List<InteractionRecord>>{};
    for (final r in records) {
      if (_filter == _Filter.received && !r.incoming) continue;
      if (_filter == _Filter.sent && r.incoming) continue;
      byPeer.putIfAbsent(r.toUserId, () => []).add(r);
    }
    final contacts = byPeer.values.map((list) {
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      final last = list.first;
      return _Contact(
        id: last.toUserId,
        name: last.toUserName,
        photoUrl: last.toUserPhotoUrl,
        last: last,
        count: list.length,
      );
    }).where((c) {
      return _query.isEmpty || c.name.toLowerCase().contains(_query);
    }).toList()
      ..sort((a, b) => b.last.createdAt.compareTo(a.last.createdAt));
    return contacts;
  }

  void _open(_Contact c) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ConversationPage(
          peerId: c.id,
          peerName: c.name,
          peerPhotoUrl: c.photoUrl,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final blocked = ref.watch(blockedUsersProvider);
    final records = ref
        .watch(interactionsProvider)
        .where((r) => !blocked.contains(r.toUserId))
        .toList();
    final contacts = _contacts(records);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Conversas',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 26, letterSpacing: -0.5),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Pesquisar conversas',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: AppColors.primary.withAlpha(18),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _chip('Todas', _Filter.all),
                _chip('Recebidas', _Filter.received),
                _chip('Enviadas', _Filter.sent),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: contacts.isEmpty
                ? _EmptyState(filtered: records.isNotEmpty)
                : ListView.builder(
                    itemCount: contacts.length,
                    itemBuilder: (context, i) => _ContactTile(
                      contact: contacts[i],
                      onTap: () => _open(contacts[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, _Filter value) {
    final selected = _filter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        showCheckmark: false,
        onSelected: (_) => setState(() => _filter = value),
        selectedColor: AppColors.primary.withAlpha(40),
        labelStyle: TextStyle(
          color: selected ? AppColors.primary : AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
        side: BorderSide(
          color: selected ? AppColors.primary : Colors.black12,
        ),
      ),
    );
  }
}

class _ContactTile extends ConsumerWidget {
  final _Contact contact;
  final VoidCallback onTap;

  const _ContactTile({required this.contact, required this.onTap});

  String _time(DateTime d) {
    final now = DateTime.now();
    final sameDay = d.year == now.year && d.month == now.month && d.day == now.day;
    if (sameDay) {
      return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    }
    final yesterday = now.subtract(const Duration(days: 1));
    if (d.year == yesterday.year && d.month == yesterday.month && d.day == yesterday.day) {
      return 'Ontem';
    }
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  String _messagePreview(ChatMessage m, String me) {
    final prefix = m.senderId == me ? 'Você: ' : '';
    switch (m.type) {
      case ChatMessageType.text:
        return '$prefix${m.content}';
      case ChatMessageType.audio:
        return '$prefix🎤 Áudio';
      case ChatMessageType.video:
        return '$prefix🎬 Vídeo';
      case ChatMessageType.image:
        return '$prefix📷 Foto';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(authProvider).user?.id ?? 'anonymous';
    final convId = conversationIdFor(me, contact.id);
    final messages = ref.watch(chatMessagesProvider(convId)).asData?.value;
    final lastMessage = (messages == null || messages.isEmpty) ? null : messages.last;

    final interactionText = contact.last.incoming
        ? contact.last.type.receivedMessage
        : contact.last.type.sentMessage.replaceFirst(RegExp(r'\s*(para|:)$'), '');
    final preview = lastMessage != null
        ? _messagePreview(lastMessage, me)
        : '${contact.last.type.emoji} ${contact.last.incoming ? 'Ele(a) $interactionText' : interactionText}';
    final time = lastMessage != null &&
            lastMessage.createdAt.isAfter(contact.last.createdAt)
        ? lastMessage.createdAt
        : contact.last.createdAt;
    final isNew = contact.last.incoming && lastMessage == null;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                ConversationAvatar(name: contact.name, photoUrl: contact.photoUrl),
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Text(contact.last.type.emoji, style: const TextStyle(fontSize: 14)),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          contact.name,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isNew ? FontWeight.w800 : FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        _time(time),
                        style: TextStyle(
                          fontSize: 12,
                          color: isNew ? AppColors.primary : AppColors.textSecondary,
                          fontWeight: isNew ? FontWeight.w700 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          preview,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isNew ? AppColors.textPrimary : AppColors.textSecondary,
                            fontWeight: isNew ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ),
                      if (isNew)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool filtered;
  const _EmptyState({required this.filtered});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.forum_outlined, size: 56, color: AppColors.primary.withAlpha(140)),
            const SizedBox(height: 16),
            Text(
              filtered ? 'Nada encontrado' : 'Nenhuma conversa ainda',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              filtered
                  ? 'Tente outro filtro ou outra pesquisa.'
                  : 'Envie um beijo, abraço, aperto de mão ou passeio no bosque.\nQuando alguém interagir com você, aparece aqui.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
