import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/age_gate_provider.dart';
import '../providers/auth_provider.dart';

class AgeGatePage extends ConsumerStatefulWidget {
  final bool blocked;
  const AgeGatePage({super.key, this.blocked = false});

  @override
  ConsumerState<AgeGatePage> createState() => _AgeGatePageState();
}

class _AgeGatePageState extends ConsumerState<AgeGatePage> {
  DateTime? _birth;
  bool _saving = false;

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  Future<void> _pick() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birth ?? DateTime(now.year - 25, now.month, now.day),
      firstDate: DateTime(now.year - 100),
      lastDate: now,
      helpText: 'Data de nascimento',
    );
    if (picked != null) setState(() => _birth = picked);
  }

  Future<void> _confirm() async {
    final user = ref.read(authProvider).user;
    if (_birth == null || user == null) return;
    setState(() => _saving = true);
    await ref.read(ageGateProvider.notifier).declare(user.id, _birth!);
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: widget.blocked ? _blocked() : _form(),
        ),
      ),
    );
  }

  Widget _blocked() => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.block_rounded, size: 72, color: AppColors.primary),
          const SizedBox(height: 20),
          const Text('Acesso restrito',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          const Text(
            'O Kiss Me é exclusivo para maiores de 18 anos. '
            'Não é possível usar o aplicativo neste aparelho.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          TextButton(
            onPressed: () => ref.read(authProvider.notifier).logout(),
            child: const Text('Sair'),
          ),
        ],
      );

  Widget _form() => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.verified_user_outlined,
              size: 64, color: AppColors.primary),
          const SizedBox(height: 20),
          const Text('Confirme sua idade',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          const Text(
            'O Kiss Me é só para maiores de 18 anos. Informe sua data de '
            'nascimento. Guardamos apenas o resultado (maior de idade ou não), '
            'não a data digitada aqui.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 28),
          OutlinedButton.icon(
            onPressed: _pick,
            icon: const Icon(Icons.cake_outlined),
            label: Text(_birth == null
                ? 'Selecionar data de nascimento'
                : _fmt(_birth!)),
          ),
          const SizedBox(height: 16),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16)),
            onPressed: _birth == null || _saving ? null : _confirm,
            child: const Text('Confirmar'),
          ),
          TextButton(
            onPressed: () => ref.read(authProvider.notifier).logout(),
            child: const Text('Sair'),
          ),
        ],
      );
}
