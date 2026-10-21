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

  /// Edita o texto de uma mensagem própria.
  Future<void> editText({
    required String conversationId,
    required String messageId,
    required String newText,
  });

  /// "Apagar para mim": esconde a mensagem apenas para [userId].
  Future<void> deleteForMe({
    required String conversationId,
    required String messageId,
    required String userId,
  });

  /// "Apagar para todos": remove o conteúdo para os dois lados.
  Future<void> deleteForEveryone({
    required String conversationId,
    required String messageId,
  });

  /// Marca como visualizadas as mensagens recebidas por [userId].
  Future<void> markRead({
    required String conversationId,
    required String userId,
  });
}
