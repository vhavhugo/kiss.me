import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/safety_provider.dart';

const _reasons = [
  'Perfil falso ou golpe',
  'Fotos inadequadas',
  'Assédio ou mensagens ofensivas',
  'Menor de idade',
  'Outro motivo',
];

/// Menu de segurança: denunciar ou bloquear. Retorna true se a pessoa
/// foi bloqueada (para a tela removê-la da mesa).
Future<bool> showSafetySheet(
  BuildContext context,
  WidgetRef ref, {
  required String userId,
  required String userName,
}) async {
  final action = await showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(userName,
                style: const TextStyle(fontWeight: FontWeight.w800)),
            subtitle: const Text('Segurança em primeiro lugar'),
          ),
          ListTile(
            leading: const Icon(Icons.flag_outlined, color: Colors.orange),
            title: const Text('Denunciar'),
            subtitle: const Text('Nossa equipe analisa o perfil'),
            onTap: () => Navigator.pop(ctx, 'report'),
          ),
          ListTile(
            leading: const Icon(Icons.block, color: Colors.redAccent),
            title: const Text('Bloquear'),
            subtitle: const Text('Vocês não se veem mais'),
            onTap: () => Navigator.pop(ctx, 'block'),
          ),
        ],
      ),
    ),
  );
  if (action == null || !context.mounted) return false;

  final notifier = ref.read(blockedUsersProvider.notifier);
  final messenger = ScaffoldMessenger.of(context);

  if (action == 'block') {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Bloquear $userName?'),
        content: const Text(
            'Essa pessoa não aparecerá mais para você e não poderá interagir.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Bloquear')),
        ],
      ),
    );
    if (ok != true) return false;
    await notifier.block(userId);
    messenger.showSnackBar(SnackBar(content: Text('$userName foi bloqueado(a).')));
    return true;
  }

  String reason = _reasons.first;
  final details = TextEditingController();
  final send = await showDialog<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        title: const Text('Denunciar'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioGroup<String>(
                groupValue: reason,
                onChanged: (v) => setState(() => reason = v ?? reason),
                child: Column(
                  children: [
                    for (final r in _reasons)
                      RadioListTile<String>(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(r),
                        value: r,
                      ),
                  ],
                ),
              ),
              TextField(
                controller: details,
                maxLines: 3,
                maxLength: 300,
                decoration: const InputDecoration(
                    hintText: 'Detalhes (opcional)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Denunciar')),
        ],
      ),
    ),
  );
  final text = details.text.trim();
  if (send != true) return false;

  await notifier.report(UserReport(
    reportedId: userId,
    reason: reason,
    details: text,
    createdAt: DateTime.now(),
  ));
  // Quem denuncia também deixa de ver a pessoa.
  await notifier.block(userId);
  messenger.showSnackBar(const SnackBar(
      content: Text('Denúncia enviada. A pessoa foi bloqueada para você.')));
  return true;
}
