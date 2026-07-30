import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../profile/domain/entities/profile_authenticity_entity.dart';

class AuthenticityBadge extends StatelessWidget {
  final AuthenticityLevel level;

  const AuthenticityBadge({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    if (level == AuthenticityLevel.unverified) return const SizedBox.shrink();

    final isFull = level == AuthenticityLevel.verified;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isFull ? AppColors.online : Colors.amber,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: (isFull ? AppColors.online : Colors.amber).withAlpha(100),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isFull ? Icons.verified_rounded : Icons.shield_outlined,
            color: Colors.white,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            isFull ? "REAL" : "VERIFICANDO",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
