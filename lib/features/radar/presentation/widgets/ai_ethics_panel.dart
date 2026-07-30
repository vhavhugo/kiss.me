import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class AiEthicsPanel extends StatelessWidget {
  const AiEthicsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology_outlined, color: AppColors.primary, size: 24),
              const SizedBox(width: 12),
              Text(
                "Nossa Ética Algorítmica",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.black.withAlpha(200),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          _buildEthicsItem(
            Icons.balance_rounded,
            "Imparcialidade",
            "Nossa IA ignora raça e classe social, focando apenas em compatibilidade emocional e geográfica.",
          ),
          const SizedBox(height: 12),
          _buildEthicsItem(
            Icons.visibility_outlined,
            "Transparência Total",
            "Você sempre saberá por que alguém apareceu na sua mesa através dos nossos selos de afinidade.",
          ),
          const SizedBox(height: 12),
          _buildEthicsItem(
            Icons.security_update_good_rounded,
            "Privacidade On-Device",
            "Seus dados sensíveis são processados localmente e nunca usados para vigilância.",
          ),
        ],
      ),
    );
  }

  Widget _buildEthicsItem(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.black38),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black45,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
