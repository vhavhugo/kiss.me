enum ActionType { kiss, hug, handshake, walk }

extension ActionTypeLabels on ActionType {
  String get label {
    switch (this) {
      case ActionType.kiss:
        return 'Beijo';
      case ActionType.hug:
        return 'Abraço';
      case ActionType.handshake:
        return 'Aperto de mão';
      case ActionType.walk:
        return 'Passeio no bosque';
    }
  }

  String get emoji {
    switch (this) {
      case ActionType.kiss:
        return '💋';
      case ActionType.hug:
        return '🤗';
      case ActionType.handshake:
        return '🤝';
      case ActionType.walk:
        return '🌳';
    }
  }

  String get receivedMessage {
    switch (this) {
      case ActionType.kiss:
        return 'te enviou um beijo';
      case ActionType.hug:
        return 'te enviou um abraço';
      case ActionType.handshake:
        return 'te estendeu a mão';
      case ActionType.walk:
        return 'te convidou para um passeio no bosque';
    }
  }

  String get sentMessage {
    switch (this) {
      case ActionType.kiss:
        return 'Você enviou um beijo para';
      case ActionType.hug:
        return 'Você enviou um abraço para';
      case ActionType.handshake:
        return 'Você enviou um aperto de mão para';
      case ActionType.walk:
        return 'Você convidou para um passeio no bosque:';
    }
  }
}

class InteractionEntity {
  final String fromUserId;
  final String toUserId;
  final ActionType type;
  final String answer;

  InteractionEntity({
    required this.fromUserId,
    required this.toUserId,
    required this.type,
    this.answer = '',
  });
}

/// Registro salvo no usuário e exibido nas notificações.
class InteractionRecord {
  final String toUserId;
  final String toUserName;
  final String toUserPhotoUrl;
  final ActionType type;
  final DateTime createdAt;

  /// true quando a outra pessoa interagiu com você.
  final bool incoming;

  const InteractionRecord({
    required this.toUserId,
    required this.toUserName,
    required this.toUserPhotoUrl,
    required this.type,
    required this.createdAt,
    this.incoming = false,
  });

  Map<String, dynamic> toJson() => {
        'toUserId': toUserId,
        'toUserName': toUserName,
        'toUserPhotoUrl': toUserPhotoUrl,
        'type': type.name,
        'createdAt': createdAt.toIso8601String(),
        'incoming': incoming,
      };

  factory InteractionRecord.fromJson(Map<String, dynamic> json) {
    return InteractionRecord(
      toUserId: json['toUserId'] as String? ?? '',
      toUserName: json['toUserName'] as String? ?? '',
      toUserPhotoUrl: json['toUserPhotoUrl'] as String? ?? '',
      type: ActionType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => ActionType.kiss,
      ),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      incoming: json['incoming'] as bool? ?? false,
    );
  }
}
