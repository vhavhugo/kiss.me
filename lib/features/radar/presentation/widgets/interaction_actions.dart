import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/interaction_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../providers/interactions_provider.dart';

/// Envia a brincadeira, salva no usuário e confirma com um aviso na tela.
Future<void> sendInteractionFromUi(
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
    return;
  }
  await ref.read(interactionsProvider.notifier).send(
        fromUserId: user.id,
        target: target,
        type: type,
      );
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(content: Text('${type.label} enviado para ${target.name}!')),
    );
}
