import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Componente que unifica a visão Global e Local da IA (Radensky, 2021)
class AiTrustSystem extends StatelessWidget {
  final String localJustification;
  final double score;

  const AiTrustSystem({
    super.key,
    required this.localJustification,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLocalExplanation(context),
        const SizedBox(height: 15),
        _buildGlobalContextLink(context),
      ],
    );
  }

  Widget _buildLocalExplanation(BuildContext context) {
    // Explicação Local: Confiança imediata em momentos críticos (Alam, 2021)
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withAlpha(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology, color: AppColors.primary, size: 20),
              const SizedBox(width: 10),
              Text(
                "POR QUE ESTA CONEXÃO?",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary.withAlpha(200),
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              Text(
                "${(score * 100).toInt()}%",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            localJustification,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlobalContextLink(BuildContext context) {
    // Acesso à Explicação Global: Melhora a compreensão posterior (Alam, 2021)
    return InkWell(
      onTap: () => _showGlobalLogic(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.info_outline, size: 14, color: Colors.black38),
            const SizedBox(width: 6),
            Text(
              "Como funciona nossa tecnologia de busca?",
              style: TextStyle(
                fontSize: 12,
                color: Colors.black38,
                decoration: TextDecoration.underline,
                decorationColor: Colors.black12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showGlobalLogic(BuildContext context) {
    // Base: Decisões humanas e linguagem simples são as mais confiáveis (Tehreem, 2025)
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Nossa Lógica de Match",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 20),
            _buildStep("1. Hiperlocalização", "Buscamos pessoas reais no seu raio de movimento atual."),
            _buildStep("2. Interesses Públicos", "Analisamos afinidades que você e o outro perfil compartilham."),
            _buildStep("3. Presença Social", "Priorizamos quem está on-line agora para interações imediatas."),
            const SizedBox(height: 20),
            const Text(
              "Combinamos IA com bom senso humano para reduzir a fadiga de escolha e gerar conexões de qualidade.",
              style: TextStyle(fontSize: 14, color: Colors.black45, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text("Entendido"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(desc, style: const TextStyle(color: Colors.black54, fontSize: 14)),
        ],
      ),
    );
  }
}
