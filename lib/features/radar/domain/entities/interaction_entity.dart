enum ActionType { kiss, hug, handshake, drink }

class InteractionEntity {
  final String fromUserId;
  final String toUserId;
  final ActionType type;
  final String answer;

  InteractionEntity({
    required this.fromUserId,
    required this.toUserId,
    required this.type,
    required this.answer,
  });
}
