enum ChatMessageType { text, audio, video, image }

class ChatMessage {
  final String id;
  final String senderId;
  final ChatMessageType type;
  final String content;
  final DateTime createdAt;
  final String? fileName;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.type,
    required this.content,
    required this.createdAt,
    this.fileName,
  });
}