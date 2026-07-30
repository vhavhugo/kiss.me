import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Camada de celebração multissensorial para matches (Linne, 2026)
class MatchCelebrationOverlay extends StatelessWidget {
  final String userName;
  final VoidCallback onDismiss;

  const MatchCelebrationOverlay({
    super.key,
    required this.userName,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withAlpha(200),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.primaryGradient,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withAlpha(150),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 80),
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
            Text(
              "UM BEIJO FOI RETRIBUÍDO!",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.0,
                shadows: [
                  Shadow(color: AppColors.primary.withAlpha(200), blurRadius: 10),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Você e $userName estão conectados agora.",
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 60),
            ElevatedButton(
              onPressed: onDismiss,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                minimumSize: const Size(200, 60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text("IR PARA O CHAT", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
