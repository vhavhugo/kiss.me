import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/chat_message.dart';
import '../providers/chat_provider.dart';
import 'video_call_page.dart';

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final _messageController = TextEditingController();
  final _offlineMessages = <ChatMessage>[];
  bool _isSending = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatMessagesProvider);
    final currentUserId = ref.watch(authProvider).user?.id ?? 'anonymous';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        titleSpacing: 20,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Conversas', style: TextStyle(fontWeight: FontWeight.w800)),
            Text('Mensagens em tempo real', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Iniciar chamada de vídeo',
            icon: const Icon(Icons.video_call_rounded),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => VideoCallPage(
                  callId: '${chatConversationId}_${DateTime.now().millisecondsSinceEpoch}',
                  userId: currentUserId,
                  isCaller: true,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _ConnectionBanner(
            messages: messages,
            onRetry: () => ref.invalidate(chatMessagesProvider),
          ),
          Expanded(
            child: messages.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _buildOfflineMessages(),
              data: (items) => ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                itemCount: items.length,
                itemBuilder: (context, index) => _MessageBubble(
                  message: items[index],
                  isMine: items[index].senderId == currentUserId,
                ),
              ),
            ),
          ),
          _buildComposer(currentUserId),
        ],
      ),
    );
  }

  Widget _buildOfflineMessages() {
    if (_offlineMessages.isEmpty) {
      _offlineMessages.add(ChatMessage(
        id: 'offline-welcome',
        senderId: 'kiss-me',
        type: ChatMessageType.text,
        content: 'Você está no modo offline. Suas mensagens ficam disponíveis nesta sessão até o Supabase voltar.',
        createdAt: DateTime.now(),
      ));
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      itemCount: _offlineMessages.length,
      itemBuilder: (context, index) => _MessageBubble(
        message: _offlineMessages[index],
        isMine: _offlineMessages[index].senderId == ref.read(authProvider).user?.id,
      ),
    );
  }

  Widget _buildComposer(String senderId) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            IconButton(
              tooltip: 'Enviar áudio',
              onPressed: _isSending ? null : () => _pickMedia(senderId, ChatMessageType.audio),
              icon: const Icon(Icons.mic_none_rounded),
              color: AppColors.primary,
            ),
            IconButton(
              tooltip: 'Enviar vídeo',
              onPressed: _isSending ? null : () => _pickMedia(senderId, ChatMessageType.video),
              icon: const Icon(Icons.videocam_outlined),
              color: AppColors.primary,
            ),
            Expanded(
              child: TextField(
                controller: _messageController,
                minLines: 1,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Escreva uma mensagem',
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onSubmitted: (_) => _sendText(senderId),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              tooltip: 'Enviar mensagem',
              onPressed: _isSending ? null : () => _sendText(senderId),
              style: IconButton.styleFrom(backgroundColor: AppColors.primary),
              icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendText(String senderId) async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    _messageController.clear();
    final sent = await _runSend(() => ref.read(chatControllerProvider).sendText(senderId, text));
    if (!sent && mounted) {
      setState(() => _offlineMessages.add(_localMessage(senderId, ChatMessageType.text, text)));
    }
  }

  Future<void> _pickMedia(String senderId, ChatMessageType type) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      withData: true,
      allowedExtensions: type == ChatMessageType.audio
          ? ['mp3', 'm4a', 'aac', 'wav', 'ogg']
          : ['mp4', 'mov', 'm4v', 'webm'],
    );
    if (!mounted || result == null || result.files.isEmpty) return;
    final file = result.files.single;
    final bytes = file.bytes;
    if (bytes == null || bytes.isEmpty) {
      _showError('Não foi possível ler o arquivo selecionado.');
      return;
    }
    const maxMediaBytes = 25 * 1024 * 1024;
    if (bytes.length > maxMediaBytes) {
      _showError('O arquivo precisa ter no máximo 25 MB.');
      return;
    }
    final sent = await _runSend(() => ref.read(chatControllerProvider).sendMedia(
          senderId: senderId,
          type: type,
          fileName: file.name,
          bytes: bytes,
        ));
    if (!sent && mounted) {
      setState(() => _offlineMessages.add(_localMessage(senderId, type, file.name)));
    }
  }

  ChatMessage _localMessage(String senderId, ChatMessageType type, String content) {
    return ChatMessage(
      id: 'offline-${DateTime.now().microsecondsSinceEpoch}',
      senderId: senderId,
      type: type,
      content: content,
      createdAt: DateTime.now(),
    );
  }

  Future<bool> _runSend(Future<void> Function() action) async {
    setState(() => _isSending = true);
    try {
      await action();
      return true;
    } catch (_) {
      if (mounted) _showError('Sem conexão. A mensagem foi mantida localmente.');
      return false;
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMine;

  const _MessageBubble({required this.message, required this.isMine});

  @override
  Widget build(BuildContext context) {
    final foreground = isMine ? Colors.white : AppColors.textPrimary;
    final icon = message.type == ChatMessageType.audio ? Icons.audiotrack_rounded : Icons.videocam_rounded;
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 300),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: isMine ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: isMine ? null : Border.all(color: Colors.black12),
        ),
        child: message.type == ChatMessageType.text
          ? _MessageText(message: message, foreground: foreground)
            : Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(icon, color: foreground),
                const SizedBox(width: 10),
                Flexible(child: Text(message.content, style: TextStyle(color: foreground))),
              ]),
      ),
    );
  }
}

class _MessageText extends StatelessWidget {
  final ChatMessage message;
  final Color foreground;

  const _MessageText({required this.message, required this.foreground});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(message.content, style: TextStyle(color: foreground, fontSize: 15)),
        const SizedBox(height: 4),
        Text(
          _formatTime(message.createdAt),
          style: TextStyle(color: foreground.withAlpha(170), fontSize: 10),
        ),
      ],
    );
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _ConnectionBanner extends StatelessWidget {
  final AsyncValue<List<ChatMessage>> messages;
  final VoidCallback onRetry;

  const _ConnectionBanner({required this.messages, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final isConnected = messages.hasValue && !messages.hasError;
    final color = isConnected ? AppColors.online : AppColors.actionHug;
    final label = isConnected ? 'Conectado em tempo real' : 'Reconectando ao chat';
    return Container(
      width: double.infinity,
      color: color.withAlpha(24),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
      child: Row(
        children: [
          Icon(Icons.circle, size: 8, color: color),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
          if (messages.hasError) ...[
            const Spacer(),
            TextButton(
              onPressed: onRetry,
              child: const Text('Verificar'),
            ),
          ],
        ],
      ),
    );
  }
}
