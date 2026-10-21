import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_colors.dart';
import '../chat/presentation/pages/conversation_page.dart';
import '../radar/domain/entities/user_entity.dart';
import 'pix_payload.dart';

const _countKey = 'dreams_supported_count_v1';

Future<void> showSponsorDreamSheet(BuildContext context, UserEntity user) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _SponsorSheet(user: user),
  );
}

class _SponsorSheet extends StatefulWidget {
  final UserEntity user;
  const _SponsorSheet({required this.user});

  @override
  State<_SponsorSheet> createState() => _SponsorSheetState();
}

class _SponsorSheetState extends State<_SponsorSheet> {
  static const _amounts = [20.0, 50.0, 100.0, 200.0];
  double? _amount = 50;
  int _supported = 0;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((p) {
      if (mounted) setState(() => _supported = p.getInt(_countKey) ?? 0);
    });
  }

  String _date(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  Widget _progress(UserEntity u) {
    final goal = u.dreamGoal!;
    final pct = (u.dreamRaised / goal).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 10,
              color: AppColors.primary,
              backgroundColor: AppColors.primary.withAlpha(30),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'R\$ ${u.dreamRaised.toStringAsFixed(0)} de R\$ ${goal.toStringAsFixed(0)} '
            '(${(pct * 100).round()}%) · informado por $_firstName',
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          if (pct >= 0.7 && pct < 1)
            const Text('Quase lá! Falta pouco para a meta. 🎉',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  String get _firstName => widget.user.name.split(',').first.trim();

  void _chat() {
    final u = widget.user;
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ConversationPage(
          peerId: u.id,
          peerName: u.name,
          peerPhotoUrl: u.photoUrl,
        ),
      ),
    );
  }

  Future<void> _copy(String text, String message) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _paid() async {
    final prefs = await SharedPreferences.getInstance();
    final n = (prefs.getInt(_countKey) ?? 0) + 1;
    await prefs.setInt(_countKey, n);
    if (!mounted) return;
    setState(() => _supported = n);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Obrigado por apoiar o sonho de $_firstName! 💚')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final u = widget.user;
    final key = (u.pixKey ?? '').trim();
    final payload = key.isEmpty
        ? null
        : buildPixPayload(
            key: key,
            name: _firstName,
            city: u.city ?? '',
            amount: _amount,
          );
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
            20, 0, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Apoiar o sonho de $_firstName',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text(u.dream ?? '',
                style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            if ((u.dreamGoal ?? 0) > 0) _progress(u),
            Chip(
              avatar: Icon(
                  u.pureDonation
                      ? Icons.favorite_rounded
                      : Icons.card_giftcard_rounded,
                  size: 18,
                  color: AppColors.primary),
              label: Text(u.pureDonation
                  ? 'Doação pura, sem contrapartida'
                  : 'Contrapartida: ${(u.sponsorReward ?? '').isEmpty ? 'combinada em conversa' : u.sponsorReward}'),
            ),
            const SizedBox(height: 12),
            if (payload != null) ...[
              const Text('Valor (opcional)',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              Wrap(
                spacing: 8,
                children: [
                  for (final a in _amounts)
                    ChoiceChip(
                      label: Text('R\$ ${a.toStringAsFixed(0)}'),
                      selected: _amount == a,
                      onSelected: (v) => setState(() => _amount = v ? a : null),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                style:
                    FilledButton.styleFrom(backgroundColor: AppColors.primary),
                onPressed: () => _copy(payload,
                    'Pix copia e cola copiado. Cole no app do seu banco.'),
                icon: const Icon(Icons.pix_rounded),
                label: const Text('Copiar Pix copia e cola'),
              ),
              TextButton.icon(
                onPressed: () => _copy(key, 'Chave Pix copiada.'),
                icon: const Icon(Icons.copy_rounded, size: 18),
                label: Text('Copiar só a chave ($key)'),
              ),
              OutlinedButton.icon(
                onPressed: _paid,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Já fiz o Pix'),
              ),
              if (_supported > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text('Você já apoiou $_supported sonho(s).',
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12)),
                ),
              const SizedBox(height: 8),
            ],
            OutlinedButton.icon(
              onPressed: _chat,
              icon: const Icon(Icons.chat_bubble_outline_rounded),
              label: Text(payload == null
                  ? 'Conversar para combinar o apoio'
                  : 'Prefiro conversar antes'),
            ),
            if (u.dreamUpdates.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text('Atualizações',
                  style: TextStyle(fontWeight: FontWeight.w800)),
              for (final up in u.dreamUpdates.take(5))
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.update_rounded, size: 20),
                  title: Text(up.text),
                  subtitle: Text(_date(up.date)),
                ),
            ],
            const SizedBox(height: 12),
            const Text(
              'O pagamento é feito direto entre vocês, pelo app do seu banco; o '
              'Kiss Me não recebe nem confirma o valor. Apoie só quem você '
              'confia e confira o nome do recebedor antes de confirmar. Nunca '
              'pague para "liberar" algo.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
