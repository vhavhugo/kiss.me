import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Barra de progresso para motivação intrínseca (Feng, 2020)
class GamificationProgressBar extends StatelessWidget {
  final double progress;
  final String label;

  const GamificationProgressBar({
    super.key,
    required this.progress,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: Colors.black.withAlpha(150),
                letterSpacing: 0.5,
              ),
            ),
            Text(
              "${(progress * 100).toInt()}%",
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 4,
            backgroundColor: AppColors.primary.withAlpha(30),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ],
    );
  }
}
