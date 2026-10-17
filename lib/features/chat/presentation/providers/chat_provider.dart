import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/mock/mock_chat_repository.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';

/// Id estável da conversa entre dois usuários, igual para ambos os lados.
String conversationIdFor(String userA, String userB) {
  final ids = [userA, userB]..sort();
  return ids.join('|');
}

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final isMock = ref.watch(isMockModeProvider);
  if (isMock) {
    return MockChatRepository();
  }
  return ChatRepositoryImpl(Supabase.instance.client);
});

final chatMessagesProvider =
    StreamProvider.family<List<ChatMessage>, String>((ref, conversationId) {
  final isMock = ref.watch(isMockModeProvider);
  if (!isMock && Supabase.instance.client.auth.currentSession == null) {
    throw StateError('Usuário não autenticado no Supabase.');
  }
  return ref.watch(chatRepositoryProvider).watchMessages(conversationId);
});

final chatControllerProvider = Provider<ChatController>((ref) {
  return ChatController(ref.watch(chatRepositoryProvider));
});

class ChatController {
  final ChatRepository _repository;

  ChatController(this._repository);

  Future<void> sendText(String conversationId, String senderId, String text) {
    return _repository.sendText(
      conversationId: conversationId,
      senderId: senderId,
      text: text,
    );
  }

  Future<void> sendMedia({
    required String conversationId,
    required String senderId,
    required ChatMessageType type,
    required String fileName,
    required List<int> bytes,
  }) {
    return _repository.sendMedia(
      conversationId: conversationId,
      senderId: senderId,
      type: type,
      fileName: fileName,
      bytes: bytes,
    );
  }
}