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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
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
            child: Icon(
              _getIcon(),
              color: _getColor(),
              size: 32,
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIcon() {
    switch (type) {
      case ActionType.kiss: return Icons.face_retouching_natural;
      case ActionType.hug: return Icons.favorite_outline;
      case ActionType.handshake: return Icons.handshake_outlined;
      case ActionType.drink: return Icons.local_bar_outlined;
    }
  }

  Color _getColor() {
    switch (type) {
      case ActionType.kiss: return Colors.pink;
      case ActionType.hug: return Colors.blue;
      case ActionType.handshake: return Colors.orange;
      case ActionType.drink: return Colors.purple;
    }
  }
}
