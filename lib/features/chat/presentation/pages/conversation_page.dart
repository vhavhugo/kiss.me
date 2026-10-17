import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/chat_message.dart';
import '../providers/chat_provider.dart';
import '../widgets/conversation_avatar.dart';
import '../widgets/media_messages.dart';
import 'video_call_page.dart';

class ConversationPage extends ConsumerStatefulWidget {
  final String peerId;
  final String peerName;
  final String peerPhotoUrl;

  const ConversationPage({
    super.key,
    required this.peerId,
    required this.peerName,
    required this.peerPhotoUrl,
  });

  @override
  ConsumerState<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends ConsumerState<ConversationPage> {
  late final String _conversationId;

  final _messageController = TextEditingController();
  final _offlineMessages = <ChatMessage>[];
  bool _isSending = false;

  final _recorder = AudioRecorder();
  bool _isRecording = false;
  bool _cancelOnRelease = false;
  bool _holdMode = false;
  Duration _recordElapsed = Duration.zero;
  Timer? _recordTimer;
  static const _maxRecording = Duration(minutes: 5);

  @override
  void initState() {
    super.initState();
    final me = ref.read(authProvider).user?.id ?? 'anonymous';
    _conversationId = conversationIdFor(me, widget.peerId);
  }

  @override
  void dispose() {
    _recordTimer?.cancel();
    _recorder.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatMessagesProvider(_conversationId));
    final currentUserId = ref.watch(authProvider).user?.id ?? 'anonymous';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            ConversationAvatar(
              name: widget.peerName,
              photoUrl: widget.peerPhotoUrl,
              radius: 18,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.peerName,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Enviar vídeo do aparelho ou da nuvem',
            icon: const Icon(Icons.video_library_outlined),
            onPressed: _isSending
                ? null
                : () => _pickExistingVideo(currentUserId),
          ),
          IconButton(
            tooltip: 'Iniciar chamada de vídeo',
            icon: const Icon(Icons.video_call_rounded),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => VideoCallPage(
                  callId: '${_conversationId}_${DateTime.now().millisecondsSinceEpoch}',
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
            onRetry: () => ref.invalidate(chatMessagesProvider(_conversationId)),
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
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: ValueListenableBuilder<TextEditingValue>(
          valueListenable: _messageController,
          builder: (context, value, _) {
            final hasText = value.text.trim().isNotEmpty;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: _isRecording
                      ? _buildRecordingBar()
                      : TextField(
                          controller: _messageController,
                          minLines: 1,
                          maxLines: 4,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration(
                            hintText: 'Escreva uma mensagem',
                            filled: true,
                            fillColor: AppColors.surface,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            suffixIcon: hasText
                                ? null
                                : IconButton(
                                    tooltip: 'Gravar vídeo',
                                    onPressed: _isSending ? null : () => _recordVideo(senderId),
                                    icon: const Icon(Icons.photo_camera_outlined),
                                    color: AppColors.primary,
                                  ),
                          ),
                          onSubmitted: (_) => _sendText(senderId),
                        ),
                ),
                const SizedBox(width: 8),
                if (hasText && !_isRecording)
                  IconButton.filled(
                    tooltip: 'Enviar mensagem',
                    onPressed: _isSending ? null : () => _sendText(senderId),
                    style: IconButton.styleFrom(backgroundColor: AppColors.primary),
                    icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                  )
                else
                  _buildMicButton(senderId),
              ],
            );
          },
        ),
      ),
    );
  }

  /// O botão fica sempre na árvore para o gesto de "segurar" não se perder
  /// quando a barra de gravação aparece.
  Widget _buildMicButton(String senderId) {
    final active = _isRecording;
    final color = !active
        ? AppColors.primary
        : (_cancelOnRelease ? Colors.grey : Colors.redAccent);
    return GestureDetector(
      key: const ValueKey('mic_button'),
      onTap: () {
        if (_isRecording) {
          _finishRecording(senderId);
        } else {
          _startRecording();
        }
      },
      onLongPressStart: (_) {
        if (!_isRecording) {
          _holdMode = true;
          _startRecording();
        }
      },
      onLongPressMoveUpdate: (d) {
        if (!_holdMode) return;
        final cancel = d.offsetFromOrigin.dx < -80;
        if (cancel != _cancelOnRelease) setState(() => _cancelOnRelease = cancel);
      },
      onLongPressEnd: (_) {
        if (_holdMode) _finishRecording(senderId);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: active ? 56 : 48,
        height: active ? 56 : 48,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Icon(
          active ? Icons.send_rounded : Icons.mic_rounded,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildRecordingBar() {
    final m = _recordElapsed.inMinutes.toString().padLeft(2, '0');
    final sec = (_recordElapsed.inSeconds % 60).toString().padLeft(2, '0');
    final color = _cancelOnRelease ? Colors.grey : Colors.redAccent;
    return Container(
      height: 48,
      padding: const EdgeInsets.only(left: 4, right: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Cancelar gravação',
            onPressed: _cancelRecording,
            icon: const Icon(Icons.delete_outline_rounded),
            color: Colors.redAccent,
          ),
          Icon(Icons.fiber_manual_record, color: color, size: 12),
          const SizedBox(width: 6),
          Text('$m:$sec', style: const TextStyle(fontWeight: FontWeight.w700)),
          const Spacer(),
          Flexible(
            child: Text(
              _cancelOnRelease
                  ? 'Solte para cancelar'
                  : (_holdMode ? '◀ Deslize para cancelar' : 'Toque para enviar'),
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: color, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _startRecording() async {
    if (kIsWeb) {
      _showError('A gravação de áudio está disponível no aplicativo do celular.');
      return;
    }
    try {
      if (!await _recorder.hasPermission()) {
        _holdMode = false;
        _showError('Permita o uso do microfone para gravar áudios.');
        return;
      }
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/kissme_audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _recorder.start(const RecordConfig(encoder: AudioEncoder.aacLc), path: path);
      if (!mounted) return;
      setState(() {
        _isRecording = true;
        _cancelOnRelease = false;
        _recordElapsed = Duration.zero;
      });
      _recordTimer?.cancel();
      _recordTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(() => _recordElapsed += const Duration(seconds: 1));
        if (_recordElapsed >= _maxRecording) {
          _finishRecording(ref.read(authProvider).user?.id ?? 'anonymous');
        }
      });
    } catch (_) {
      _holdMode = false;
      _showError('Não foi possível iniciar a gravação.');
    }
  }

  Future<void> _cancelRecording() async {
    if (!_isRecording) return;
    setState(() => _cancelOnRelease = true);
    await _finishRecording(ref.read(authProvider).user?.id ?? 'anonymous');
  }

  Future<void> _finishRecording(String senderId) async {
    if (!_isRecording) return;
    _recordTimer?.cancel();
    final cancelled = _cancelOnRelease || _recordElapsed < const Duration(seconds: 1);
    final tooShort = !_cancelOnRelease && cancelled;
    setState(() {
      _isRecording = false;
      _cancelOnRelease = false;
      _holdMode = false;
    });
    final path = await _recorder.stop();
    if (path == null) return;
    final file = File(path);
    try {
      if (cancelled) {
        if (tooShort) _showError('Áudio muito curto. Grave por pelo menos 1 segundo.');
        return;
      }
      final bytes = await file.readAsBytes();
      await _sendMediaBytes(senderId, ChatMessageType.audio, 'Áudio ${_formatDuration(_recordElapsed)}.m4a', bytes);
    } finally {
      if (await file.exists()) await file.delete();
    }
  }

  String _formatDuration(Duration d) =>
      '${d.inMinutes.toString().padLeft(2, '0')}-${(d.inSeconds % 60).toString().padLeft(2, '0')}';

  Future<void> _recordVideo(String senderId) async {
    try {
      final video = await ImagePicker().pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(minutes: 2),
      );
      if (video == null || !mounted) return;
      final bytes = await video.readAsBytes();
      await _sendMediaBytes(senderId, ChatMessageType.video, video.name, bytes);
    } catch (_) {
      _showError('Não foi possível abrir a câmera. Verifique a permissão.');
    }
  }

  Future<void> _pickExistingVideo(String senderId) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      withData: true,
    );
    if (!mounted || result == null || result.files.isEmpty) return;
    final file = result.files.single;
    final bytes = file.bytes;
    if (bytes == null || bytes.isEmpty) {
      _showError('Não foi possível ler o vídeo selecionado.');
      return;
    }
    await _sendMediaBytes(senderId, ChatMessageType.video, file.name, bytes);
  }

  Future<void> _sendMediaBytes(
    String senderId,
    ChatMessageType type,
    String fileName,
    List<int> bytes,
  ) async {
    const maxMediaBytes = 25 * 1024 * 1024;
    if (bytes.length > maxMediaBytes) {
      _showError('O arquivo precisa ter no máximo 25 MB.');
      return;
    }
    final sent = await _runSend(() => ref.read(chatControllerProvider).sendMedia(
          conversationId: _conversationId,
          senderId: senderId,
          type: type,
          fileName: fileName,
          bytes: bytes,
        ));
    if (!sent && mounted) {
      setState(() => _offlineMessages.add(_localMessage(senderId, type, fileName)));
    }
  }

  Future<void> _sendText(String senderId) async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    _messageController.clear();
    final sent = await _runSend(() => ref.read(chatControllerProvider).sendText(_conversationId, senderId, text));
    if (!sent && mounted) {
      setState(() => _offlineMessages.add(_localMessage(senderId, ChatMessageType.text, text)));
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
    final isVideo = message.type == ChatMessageType.video;
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 300),
        margin: const EdgeInsets.only(bottom: 10),
        padding: isVideo
            ? const EdgeInsets.all(4)
            : const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: isMine ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: isMine ? null : Border.all(color: Colors.black12),
        ),
        child: switch (message.type) {
          ChatMessageType.text => _MessageText(message: message, foreground: foreground),
          ChatMessageType.video => VideoMessagePreview(
              source: message.content,
              fileName: message.fileName,
              isMine: isMine,
            ),
          ChatMessageType.audio => AudioMessageBubble(
              source: message.content,
              fileName: message.fileName,
              foreground: foreground,
            ),
        },
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
