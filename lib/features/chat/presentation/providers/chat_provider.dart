import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';

const chatConversationId = 'demo-conversation';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepositoryImpl(Supabase.instance.client);
});

final chatMessagesProvider = StreamProvider<List<ChatMessage>>((ref) {
  if (Supabase.instance.client.auth.currentSession == null) {
    throw StateError('Usuário não autenticado no Supabase.');
  }
  return ref.watch(chatRepositoryProvider).watchMessages(chatConversationId);
});

final chatControllerProvider = Provider<ChatController>((ref) {
  return ChatController(ref.watch(chatRepositoryProvider));
});

class ChatController {
  final ChatRepository _repository;

  ChatController(this._repository);

  Future<void> sendText(String senderId, String text) {
    return _repository.sendText(
      conversationId: chatConversationId,
      senderId: senderId,
      text: text,
    );
  }

  Future<void> sendMedia({
    required String senderId,
    required ChatMessageType type,
    required String fileName,
    required List<int> bytes,
  }) {
    return _repository.sendMedia(
      conversationId: chatConversationId,
      senderId: senderId,
      type: type,
      fileName: fileName,
      bytes: bytes,
    );
  }
}