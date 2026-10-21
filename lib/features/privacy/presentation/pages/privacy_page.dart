import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/privacy_provider.dart';

class PrivacyPage extends ConsumerWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(privacySettingsProvider);
    final n = ref.read(privacySettingsProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: const Text('Privacidade')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          const _Header('Localização'),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              'Sua posição exata nunca precisa sair do aparelho: antes de enviar, '
              'ela é movida para o centro de uma área, então quem está perto não '
              'consegue descobrir onde você realmente está.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ),
          RadioGroup<LocationPrecision>(
            groupValue: s.precision,
            onChanged: (v) {
              if (v != null) n.setPrecision(v);
            },
            child: Column(
              children: [
                for (final p in LocationPrecision.values)
                  RadioListTile<LocationPrecision>(
                    value: p,
                    title: Text(p.label),
                    subtitle: Text(p.description),
                    activeColor: AppColors.primary,
                  ),
              ],
            ),
          ),
          SwitchListTile(
            value: s.approximateDistance,
            onChanged: n.setApproximateDistance,
            activeThumbColor: AppColors.primary,
            title: const Text('Mostrar distância aproximada'),
            subtitle: const Text(
                'Exibe faixas ("a menos de 500 m") em vez de metros exatos, '
                'o que dificulta localizar alguém por triangulação.'),
          ),
          const Divider(),
          const _Header('Mensagens'),
          SwitchListTile(
            value: s.readReceipts,
            onChanged: n.setReadReceipts,
            activeThumbColor: AppColors.primary,
            title: const Text('Confirmação de leitura'),
            subtitle: const Text(
                'Quando desligada, você não avisa que leu e também não vê se '
                'leram as suas mensagens.'),
          ),
          const ListTile(
            leading: Icon(Icons.timer_outlined),
            title: Text('Conversas efêmeras'),
            subtitle: Text(
                'Convites "Sair juntos" têm conversa de 24 h para incentivar o encontro.'),
          ),
          const ListTile(
            leading: Icon(Icons.shield_outlined),
            title: Text('Bloqueio e denúncia'),
            subtitle: Text(
                'Use o escudo no chat ou na mesa do Kiss Me Now. Bloqueados somem de tudo.'),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String text;
  const _Header(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Text(text,
            style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: AppColors.primary)),
      );
}
