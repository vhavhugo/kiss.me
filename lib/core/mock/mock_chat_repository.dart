import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/chat/domain/entities/chat_message.dart';
import '../../features/chat/domain/repositories/chat_repository.dart';

/// Chat do modo demonstração. As conversas ficam salvas no aparelho
/// (SharedPreferences) e os arquivos na pasta de documentos do app.
class MockChatRepository implements ChatRepository {
  final Map<String, List<ChatMessage>> _conversations = {};
  final Map<String, StreamController<List<ChatMessage>>> _controllers = {};

  static String _key(String conversationId) => 'chat_v1_$conversationId';

  bool _isPeer(String id) => id.startsWith('mock-user-');

  Future<List<ChatMessage>> _messagesOf(String conversationId) async {
    final cached = _conversations[conversationId];
    if (cached != null) return cached;

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(conversationId));
    List<ChatMessage> list;
    if (raw != null) {
      list = (jsonDecode(raw) as List)
          .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      final peer = conversationId.split('|').where(_isPeer).firstOrNull;
      list = peer == null
          ? <ChatMessage>[]
          : [
              ChatMessage(
                id: 'seed-$conversationId',
                senderId: peer,
                type: ChatMessageType.text,
                content: 'Oi! Vi que você interagiu comigo aqui no Kiss Me 😊',
                createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
              ),
            ];
    }
    // Pode ter sido carregada por outra chamada enquanto aguardávamos.
    final result = _conversations.putIfAbsent(conversationId, () => list);
    if (raw == null && result.isNotEmpty) await _save(conversationId);
    return result;
  }

  StreamController<List<ChatMessage>> _controllerOf(String conversationId) {
    return _controllers.putIfAbsent(
      conversationId,
      () => StreamController<List<ChatMessage>>.broadcast(),
    );
  }

  Future<void> _save(String conversationId) async {
    final list = _conversations[conversationId] ?? const <ChatMessage>[];
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key(conversationId),
      jsonEncode(list.map((m) => m.toJson()).toList()),
    );
  }

  Future<void> _publish(String conversationId) async {
    await _save(conversationId);
    _controllerOf(conversationId)
        .add(List.unmodifiable(_conversations[conversationId]!));
  }

  @override
  Stream<List<ChatMessage>> watchMessages(String conversationId) async* {
    yield List.unmodifiable(await _messagesOf(conversationId));
    yield* _controllerOf(conversationId).stream;
  }

  Future<void> _add(String conversationId, ChatMessage message) async {
    final list = await _messagesOf(conversationId);
    list.add(message);
    await _publish(conversationId);

    // Demonstração: a outra pessoa "visualiza" o que você enviou.
    if (!_isPeer(message.senderId)) {
      Timer(const Duration(seconds: 3), () => _peerReads(conversationId, message.id));
    }
  }

  Future<void> _peerReads(String conversationId, String messageId) async {
    final list = await _messagesOf(conversationId);
    final i = list.indexWhere((m) => m.id == messageId);
    if (i < 0 || list[i].isRead || list[i].isDeleted) return;
    list[i] = list[i].copyWith(readAt: DateTime.now());
    await _publish(conversationId);
  }

  @override
  Future<void> sendText({
    required String conversationId,
    required String senderId,
    required String text,
  }) async {
    await _add(
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
    var content = fileName;
    if (!kIsWeb) {
      final dir = await getApplicationDocumentsDirectory();
      final media = Directory('${dir.path}/chat_media');
      if (!await media.exists()) await media.create(recursive: true);
      final safeName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
      final file = File('${media.path}/${DateTime.now().microsecondsSinceEpoch}_$safeName');
      await file.writeAsBytes(Uint8List.fromList(bytes));
      content = file.path;
    }
    await _add(
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

  Future<void> _update(
    String conversationId,
    String messageId,
    ChatMessage Function(ChatMessage) change,
  ) async {
    final list = await _messagesOf(conversationId);
    final i = list.indexWhere((m) => m.id == messageId);
    if (i < 0) return;
    list[i] = change(list[i]);
    await _publish(conversationId);
  }

  @override
  Future<void> editText({
    required String conversationId,
    required String messageId,
    required String newText,
  }) {
    return _update(
      conversationId,
      messageId,
      (m) => m.type == ChatMessageType.text && !m.isDeleted
          ? m.copyWith(content: newText, editedAt: DateTime.now())
          : m,
    );
  }

  @override
  Future<void> deleteForMe({
    required String conversationId,
    required String messageId,
    required String userId,
  }) {
    return _update(
      conversationId,
      messageId,
      (m) => m.hiddenBy.contains(userId)
          ? m
          : m.copyWith(hiddenBy: [...m.hiddenBy, userId]),
    );
  }

  @override
  Future<void> deleteForEveryone({
    required String conversationId,
    required String messageId,
  }) async {
    final list = await _messagesOf(conversationId);
    final target = list.where((m) => m.id == messageId).firstOrNull;
    if (target == null) return;
    if (!kIsWeb && target.type != ChatMessageType.text) {
      try {
        final file = File(target.content);
        if (await file.exists()) await file.delete();
      } catch (_) {}
    }
    await _update(
      conversationId,
      messageId,
      (m) => m.copyWith(content: '', deletedAt: DateTime.now()),
    );
  }

  @override
  Future<void> markRead({
    required String conversationId,
    required String userId,
  }) async {
    final list = await _messagesOf(conversationId);
    var changed = false;
    final now = DateTime.now();
    for (var i = 0; i < list.length; i++) {
      final m = list[i];
      if (m.senderId != userId && !m.isRead && !m.isDeleted) {
        list[i] = m.copyWith(readAt: now);
        changed = true;
      }
    }
    if (changed) await _publish(conversationId);
  }
}
