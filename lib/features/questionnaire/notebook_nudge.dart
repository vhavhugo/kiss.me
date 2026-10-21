import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_colors.dart';
import '../auth/presentation/providers/auth_provider.dart';
import '../chat/presentation/pages/conversation_page.dart';
import '../chat/presentation/providers/chat_provider.dart';
import '../radar/domain/entities/user_entity.dart';

const _questionPool = [
  ('💋', 'Você ficaria comigo?'),
  ('💍', 'Você sonha em casar?'),
  ('🎨', 'Qual o seu hobby principal?'),
  ('🎬', 'Qual seu tipo de filme predileto?'),
  ('⚽', 'Você pratica esportes?'),
  ('✈️', 'Qual sua viagem dos sonhos?'),
];

String _answeredKey(String peerId) => 'notebook_answered_v1_$peerId';

/// Escolhe 3 perguntas de forma estável para cada perfil.
List<(String, String)> _questionsFor(String peerId) {
  final start = peerId.codeUnits.fold<int>(0, (a, b) => a + b) % _questionPool.length;
  return [for (var i = 0; i < 3; i++) _questionPool[(start + i) % _questionPool.length]];
}

/// Convite para responder o Caderno de Perguntas de quem está sendo visto.
class NotebookNudge extends ConsumerStatefulWidget {
  final UserEntity user;
  const NotebookNudge({super.key, required this.user});

  @override
  ConsumerState<NotebookNudge> createState() => _NotebookNudgeState();
}

class _NotebookNudgeState extends ConsumerState<NotebookNudge> {
  bool _answered = false;

  String get _first => widget.user.name.split(',').first.trim();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final done = prefs.getBool(_answeredKey(widget.user.id)) ?? false;
    if (mounted && done != _answered) setState(() => _answered = done);
  }

  /// Gancho personalizado: usa um interesse em comum quando existe.
  String get _hook {
    final common = widget.user.affinity?.commonInterests ?? const <String>[];
    if (common.isNotEmpty) {
      return 'Vocês combinam em ${common.first.toLowerCase()}. Descubra o que mais têm em comum.';
    }
    return 'Quem responde o caderno tem muito mais chance de iniciar uma conversa de verdade.';
  }

  Future<void> _open() async {
    final sent = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _NotebookSheet(user: widget.user),
    );
    if (sent == true && mounted) {
      setState(() => _answered = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          AppColors.primary.withAlpha(30),
          AppColors.primary.withAlpha(10),
        ]),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary.withAlpha(60)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Text('📓', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _answered
                    ? 'Você respondeu o caderno de $_first'
                    : 'Gostou de $_first? Quebre o gelo!',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
            ),
          ]),
          const SizedBox(height: 6),
          Text(
            _answered
                ? 'Boa! Agora é só continuar a conversa.'
                : '$_hook Leva 1 minuto: 3 perguntas rápidas.',
            style: const TextStyle(color: AppColors.textSecondary, height: 1.3),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: _answered
                ? OutlinedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ConversationPage(
                          peerId: widget.user.id,
                          peerName: widget.user.name,
                          peerPhotoUrl: widget.user.photoUrl,
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: const Text('Abrir conversa'),
                  )
                : FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                    onPressed: _open,
                    icon: const Icon(Icons.edit_note_rounded),
                    label: Text('Responder o caderno de $_first'),
                  ),
          ),
        ],
      ),
    );
  }
}

class _NotebookSheet extends ConsumerStatefulWidget {
  final UserEntity user;
  const _NotebookSheet({required this.user});

  @override
  ConsumerState<_NotebookSheet> createState() => _NotebookSheetState();
}

class _NotebookSheetState extends ConsumerState<_NotebookSheet> {
  late final List<(String, String)> _qs = _questionsFor(widget.user.id);
  late final List<TextEditingController> _ctrls =
      List.generate(_qs.length, (_) => TextEditingController());
  bool _sending = false;

  @override
  void dispose() {
    for (final c in _ctrls) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _send() async {
    final me = ref.read(authProvider).user?.id;
    final answers = [
      for (var i = 0; i < _qs.length; i++)
        if (_ctrls[i].text.trim().isNotEmpty)
          '${_qs[i].$1} ${_qs[i].$2}\n${_ctrls[i].text.trim()}',
    ];
    if (me == null || answers.isEmpty) return;
    setState(() => _sending = true);
    try {
      await ref.read(chatControllerProvider).sendText(
            conversationIdFor(me, widget.user.id),
            me,
            'Respondi seu Caderno de Perguntas:\n\n${answers.join('\n\n')}',
          );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_answeredKey(widget.user.id), true);
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _sending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível enviar. Tente novamente.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final first = widget.user.name.split(',').first.trim();
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 0, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Caderno de $first',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            const Text(
              'Suas respostas vão como mensagem na conversa. Responda ao menos uma.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            for (var i = 0; i < _qs.length; i++) ...[
              const SizedBox(height: 16),
              Text('${_qs[i].$1} ${_qs[i].$2}',
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              TextField(
                controller: _ctrls[i],
                maxLength: 200,
                minLines: 1,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Escreva sua resposta...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                onPressed: _sending ? null : _send,
                child: Text(_sending ? 'Enviando...' : 'Enviar respostas'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
