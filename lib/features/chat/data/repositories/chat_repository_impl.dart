import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final SupabaseClient _supabase;
  static const _mediaBucket = 'chat-media';

  ChatRepositoryImpl(this._supabase);

  @override
  Stream<List<ChatMessage>> watchMessages(String conversationId) {
    return _supabase
        .from('chat_messages')
        .stream(primaryKey: ['id'])
        .eq('conversation_id', conversationId)
        .order('created_at')
        .limit(100)
        .map((rows) => rows.map(_fromRow).toList());
  }

  @override
  Future<void> sendText({
    required String conversationId,
    required String senderId,
    required String text,
  }) async {
    await _supabase.from('chat_messages').insert({
      'conversation_id': conversationId,
      'sender_id': senderId,
      'message_type': 'text',
      'content': text,
    }).timeout(const Duration(seconds: 10));
  }

  @override
  Future<void> sendMedia({
    required String conversationId,
    required String senderId,
    required ChatMessageType type,
    required String fileName,
    required List<int> bytes,
  }) async {
    final safeName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    final path = '$conversationId/${DateTime.now().microsecondsSinceEpoch}_$safeName';
    await _supabase.storage
      .from(_mediaBucket)
      .uploadBinary(path, Uint8List.fromList(bytes))
      .timeout(const Duration(seconds: 60));
    final url = _supabase.storage.from(_mediaBucket).getPublicUrl(path);
    await _supabase.from('chat_messages').insert({
      'conversation_id': conversationId,
      'sender_id': senderId,
      'message_type': type.name,
      'content': url,
      'file_name': fileName,
    }).timeout(const Duration(seconds: 10));
  }

  ChatMessage _fromRow(Map<String, dynamic> row) {
    return ChatMessage(
      id: row['id'].toString(),
      senderId: row['sender_id'] as String,
      type: ChatMessageType.values.byName(row['message_type'] as String),
      content: row['content'] as String,
      createdAt: DateTime.parse(row['created_at'] as String),
      fileName: row['file_name'] as String?,
      readAt: _date(row['read_at']),
      editedAt: _date(row['edited_at']),
      deletedAt: _date(row['deleted_at']),
      hiddenBy: (row['hidden_by'] as List? ?? const []).cast<String>(),
    );
  }

  DateTime? _date(Object? value) =>
      value == null ? null : DateTime.tryParse(value as String);

  @override
  Future<void> editText({
    required String conversationId,
    required String messageId,
    required String newText,
  }) async {
    await _supabase
        .from('chat_messages')
        .update({
          'content': newText,
          'edited_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', messageId)
        .eq('message_type', 'text')
        .isFilter('deleted_at', null)
        .timeout(const Duration(seconds: 10));
  }

  @override
  Future<void> deleteForMe({
    required String conversationId,
    required String messageId,
    required String userId,
  }) async {
    await _supabase
        .rpc('chat_hide_message', params: {'p_message_id': int.parse(messageId)})
        .timeout(const Duration(seconds: 10));
  }

  @override
  Future<void> deleteForEveryone({
    required String conversationId,
    required String messageId,
  }) async {
    final row = await _supabase
        .from('chat_messages')
        .select('content, message_type')
        .eq('id', messageId)
        .maybeSingle();
    await _supabase
        .from('chat_messages')
        .update({
          'content': '',
          'deleted_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', messageId)
        .timeout(const Duration(seconds: 10));

    // Remove também o arquivo do armazenamento.
    final url = row?['content'] as String?;
    if (row != null && row['message_type'] != 'text' && url != null) {
      final marker = '/$_mediaBucket/';
      final at = url.indexOf(marker);
      if (at >= 0) {
        try {
          await _supabase.storage
              .from(_mediaBucket)
              .remove([Uri.decodeComponent(url.substring(at + marker.length))]);
        } catch (_) {}
      }
    }
  }

  @override
  Future<void> markRead({
    required String conversationId,
    required String userId,
  }) async {
    await _supabase
        .from('chat_messages')
        .update({'read_at': DateTime.now().toUtc().toIso8601String()})
        .eq('conversation_id', conversationId)
        .neq('sender_id', userId)
        .isFilter('read_at', null)
        .isFilter('deleted_at', null);
  }
}