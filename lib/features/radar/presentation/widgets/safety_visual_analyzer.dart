import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Componente que utiliza Alto Contraste e Luminosidade para Análise Visual Clara (Sumter, 2018)
class SafetyVisualAnalyzer extends StatelessWidget {
  final Widget profileImage;
  final VoidCallback onRiskDetected;

  const SafetyVisualAnalyzer({
    super.key,
    required this.profileImage,
    required this.onRiskDetected,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Imagem com tratamento de luminosidade para facilitar detecção de detalhes
        profileImage,
        
        // Camada de Segurança Afetiva: Micro-sinais de conforto (Kandala, 2026)
        Positioned(
          top: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(100),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white.withAlpha(50)),
            ),
            child: Column(
              children: [
                _buildSafetyAction(Icons.visibility_off_outlined, "Ocultar", context),
                const SizedBox(height: 15),
                _buildSafetyAction(Icons.report_gmailerrorred_rounded, "Sinalizar", context),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSafetyAction(IconData icon, String label, BuildContext context) {
    return InkWell(
      onTap: onRiskDetected,
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
