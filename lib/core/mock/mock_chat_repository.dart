import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import '../../features/chat/domain/entities/chat_message.dart';
import '../../features/chat/domain/repositories/chat_repository.dart';

class MockChatRepository implements ChatRepository {
  final Map<String, List<ChatMessage>> _conversations = {};
  final Map<String, StreamController<List<ChatMessage>>> _controllers = {};

  List<ChatMessage> _messagesOf(String conversationId) {
    return _conversations.putIfAbsent(conversationId, () {
      final peer = conversationId
          .split('|')
          .where((id) => id.startsWith('mock-user-'))
          .firstOrNull;
      if (peer == null) return <ChatMessage>[];
      return [
        ChatMessage(
          id: 'seed-$conversationId',
          senderId: peer,
          type: ChatMessageType.text,
          content: 'Oi! Vi que você interagiu comigo aqui no Kiss Me 😊',
          createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
      ];
    });
  }

  StreamController<List<ChatMessage>> _controllerOf(String conversationId) {
    return _controllers.putIfAbsent(
      conversationId,
      () => StreamController<List<ChatMessage>>.broadcast(),
    );
  }

  @override
  Stream<List<ChatMessage>> watchMessages(String conversationId) async* {
    yield List.unmodifiable(_messagesOf(conversationId));
    yield* _controllerOf(conversationId).stream;
  }

  void _add(String conversationId, ChatMessage message) {
    final list = _messagesOf(conversationId)..add(message);
    _controllerOf(conversationId).add(List.unmodifiable(list));
  }

  @override
  Future<void> sendText({
    required String conversationId,
    required String senderId,
    required String text,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _add(
      conversationId,
      ChatMessage(
        id: 'mock-msg-${DateTime.now().microsecondsSinceEpoch}',
        senderId: senderId,
        type: ChatMessageType.text,
        content: text,
        createdAt: DateTime.now(),
      ),
    );
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
    var content = fileName;
    if (!kIsWeb) {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/${DateTime.now().microsecondsSinceEpoch}_$fileName');
      await file.writeAsBytes(Uint8List.fromList(bytes));
      content = file.path;
    }
    _add(
      conversationId,
      ChatMessage(
        id: 'mock-msg-${DateTime.now().microsecondsSinceEpoch}',
        senderId: senderId,
        type: type,
        content: content,
        fileName: fileName,
        createdAt: DateTime.now(),
      ),
    );
  }
}
