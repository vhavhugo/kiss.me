import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ConversationAvatar extends StatelessWidget {
  final String name;
  final String photoUrl;
  final double radius;

  const ConversationAvatar({
    super.key,
    required this.name,
    required this.photoUrl,
    this.radius = 28,
  });

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primary.withAlpha(40),
      foregroundImage: photoUrl.isEmpty ? null : NetworkImage(photoUrl),
      onForegroundImageError: photoUrl.isEmpty ? null : (_, _) {},
      child: Text(
        initial,
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w800,
          fontSize: radius * 0.8,
        ),
      ),
    );
  }
}
