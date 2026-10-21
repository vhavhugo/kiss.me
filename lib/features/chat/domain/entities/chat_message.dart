enum ChatMessageType { text, audio, video, image }

class ChatMessage {
  final String id;
  final String senderId;
  final ChatMessageType type;
  final String content;
  final DateTime createdAt;
  final String? fileName;

  /// Quando o destinatário visualizou a mensagem ou o arquivo.
  final DateTime? readAt;
  final DateTime? editedAt;

  /// "Apagar para todos": o conteúdo some para ambos.
  final DateTime? deletedAt;

  /// Usuários que usaram "Apagar para mim".
  final List<String> hiddenBy;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.type,
    required this.content,
    required this.createdAt,
    this.fileName,
    this.readAt,
    this.editedAt,
    this.deletedAt,
    this.hiddenBy = const [],
  });

  bool get isDeleted => deletedAt != null;
  bool get isRead => readAt != null;

  ChatMessage copyWith({
    String? content,
    DateTime? readAt,
    DateTime? editedAt,
    DateTime? deletedAt,
    List<String>? hiddenBy,
  }) {
    return ChatMessage(
      id: id,
      senderId: senderId,
      type: type,
      content: content ?? this.content,
      createdAt: createdAt,
      fileName: fileName,
      readAt: readAt ?? this.readAt,
      editedAt: editedAt ?? this.editedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      hiddenBy: hiddenBy ?? this.hiddenBy,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'senderId': senderId,
        'type': type.name,
        'content': content,
        'createdAt': createdAt.toIso8601String(),
        'fileName': fileName,
        'readAt': readAt?.toIso8601String(),
        'editedAt': editedAt?.toIso8601String(),
        'deletedAt': deletedAt?.toIso8601String(),
        'hiddenBy': hiddenBy,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    DateTime? date(String key) => DateTime.tryParse(json[key] as String? ?? '');
    return ChatMessage(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      type: ChatMessageType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => ChatMessageType.text,
      ),
      content: json['content'] as String? ?? '',
      createdAt: date('createdAt') ?? DateTime.now(),
      fileName: json['fileName'] as String?,
      readAt: date('readAt'),
      editedAt: date('editedAt'),
      deletedAt: date('deletedAt'),
      hiddenBy: (json['hiddenBy'] as List? ?? const []).cast<String>(),
    );
  }
}
