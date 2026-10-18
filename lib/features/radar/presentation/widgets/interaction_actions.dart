import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/interaction_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../providers/interactions_provider.dart';

/// Pede que a pessoa responda uma pergunta do perfil antes de enviar o ícone.
/// Retorna a resposta ou null se cancelar.
Future<String?> _askIcebreaker(
  BuildContext context,
  UserEntity target,
  ActionType type,
) {
  final questions = target.icebreakers.map((q) => q.text).toList();
  var selected = questions.first;
  final controller = TextEditingController();

  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 0, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${type.emoji}  Antes de enviar, quebre o gelo',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                'Responda uma pergunta de ${target.name.split(',').first}. Nada de "oi, tudo bem?".',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final q in questions)
                    ChoiceChip(
                      label: Text(q, softWrap: true),
                      selected: selected == q,
                      onSelected: (_) => setState(() => selected = q),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                autofocus: true,
                maxLength: 200,
                maxLines: 3,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Sua resposta',
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: controller.text.trim().length < 3
                      ? null
                      : () => Navigator.pop(
                          ctx, '$selected\n${controller.text.trim()}'),
                  icon: Text(type.emoji),
                  label: Text('Enviar ${type.label}'),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Pede a resposta do quebra-gelo, envia a brincadeira, salva no usuário e
/// confirma na tela. Retorna true se foi enviada.
Future<bool> sendInteractionFromUi(
  BuildContext context,
  WidgetRef ref, {
  required UserEntity? target,
  required ActionType type,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  final user = ref.read(authProvider).user;
  if (target == null || user == null) {
    messenger.showSnackBar(
      const SnackBar(content: Text('Nenhuma pessoa selecionada.')),
    );
    return false;
  }

  var answer = '';
  if (target.icebreakers.isNotEmpty) {
    final result = await _askIcebreaker(context, target, type);
    if (result == null) return false;
    answer = result;
  }

  await ref.read(interactionsProvider.notifier).send(
        fromUserId: user.id,
        target: target,
        type: type,
        answer: answer,
      );
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(content: Text('${type.label} enviado para ${target.name}!')),
    );
  return true;
}
