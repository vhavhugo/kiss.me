import 'package:flutter/material.dart';
import '../../domain/entities/interaction_entity.dart';

class ActionButton extends StatelessWidget {
  final ActionType type;
  final VoidCallback onTap;

  const ActionButton({
    super.key,
    required this.type,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: type.label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(40),
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _getColor().withAlpha(25),
              border: Border.all(color: _getColor(), width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: _getColor().withAlpha(40),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Center(child: _buildSymbol()),
          ),
        ),
      ),
    );
  }

  Widget _buildSymbol() {
    if (type == ActionType.kiss) {
      return ClipOval(
        child: Image.asset(
          'assets/images/kiss_action_icon.png',
          width: 58,
          height: 58,
          fit: BoxFit.cover,
        ),
      );
    }
    return Text(type.emoji, style: const TextStyle(fontSize: 32));
  }

  Color _getColor() {
    switch (type) {
      case ActionType.kiss: return Colors.pink;
      case ActionType.hug: return Colors.blue;
      case ActionType.handshake: return Colors.orange;
      case ActionType.walk: return Colors.green;
    }
  }
}
