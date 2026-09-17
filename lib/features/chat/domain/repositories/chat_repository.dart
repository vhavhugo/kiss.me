import '../entities/chat_message.dart';

abstract class ChatRepository {
  Stream<List<ChatMessage>> watchMessages(String conversationId);

  Future<void> sendText({
    required String conversationId,
    required String senderId,
    required String text,
  });

  Future<void> sendMedia({
    required String conversationId,
    required String senderId,
    required ChatMessageType type,
    required String fileName,
    required List<int> bytes,
  });
}