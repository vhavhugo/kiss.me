import 'dart:async';
import '../../features/chat/domain/entities/chat_message.dart';
import '../../features/chat/domain/repositories/chat_repository.dart';

class MockChatRepository implements ChatRepository {
  final _messagesController = StreamController<List<ChatMessage>>.broadcast();
  final List<ChatMessage> _messages = [
    ChatMessage(
      id: 'mock-msg-1',
      senderId: 'mock-user-1',
      type: ChatMessageType.text,
      content: 'Oi! Vi que temos 94% de afinidade aqui no Kiss Me 😊',
      createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
    ChatMessage(
      id: 'mock-msg-2',
      senderId: 'mock-user-123',
      type: ChatMessageType.text,
      content: 'Oi Camila! Tudo bem? Sim, vi que você também curte café e fotografia!',
      createdAt: DateTime.now().subtract(const Duration(minutes: 8)),
    ),
    ChatMessage(
      id: 'mock-msg-3',
      senderId: 'mock-user-1',
      type: ChatMessageType.text,
      content: 'Sim! Tem uma cafeteria ótima aqui perto do centro. Topa?',
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
  ];

  MockChatRepository() {
    // Emite o estado inicial assim que houver listener
    Timer.run(() {
      if (!_messagesController.isClosed) {
        _messagesController.add(List.unmodifiable(_messages));
      }
    });
  }

  @override
  Stream<List<ChatMessage>> watchMessages(String conversationId) async* {
    yield List.unmodifiable(_messages);
    yield* _messagesController.stream;
  }

  @override
  Future<void> sendText({
    required String conversationId,
    required String senderId,
    required String text,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final newMsg = ChatMessage(
      id: 'mock-msg-${DateTime.now().millisecondsSinceEpoch}',
      senderId: senderId,
      type: ChatMessageType.text,
      content: text,
      createdAt: DateTime.now(),
    );
    _messages.add(newMsg);
    _messagesController.add(List.unmodifiable(_messages));
  }

  @override
  Future<void> sendMedia({
    required String conversationId,
    required String senderId,
    required ChatMessageType type,
    required String fileName,
    required List<int> bytes,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final newMsg = ChatMessage(
      id: 'mock-msg-${DateTime.now().millisecondsSinceEpoch}',
      senderId: senderId,
      type: type,
      content: fileName,
      createdAt: DateTime.now(),
    );
    _messages.add(newMsg);
    _messagesController.add(List.unmodifiable(_messages));
  }
}
