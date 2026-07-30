import 'package:flutter/material.dart';

/// Identidade Visual Científica (Jiang, 2024; Liu, 2024; Deng, 2022)
class AppColors {
  // Base teórica: Tons quentes transmitem calor e suavidade (Liu, 2024)
  // Optamos por um Coral Alaranjado (Laranja preferido por 60.2% dos usuários)
  static const Color primary = Color(0xFFFF7043); // Coral Quente
  static const Color secondary = Color(0xFFF06292); // Pink Suave para contraste
  
  // Background com baixa saturação e alta luminosidade (Deng, 2022)
  // Reduz a fadiga ocular e melhora o desempenho de busca visual
  static const Color background = Color(0xFFFDFDFD); 
  static const Color surface = Colors.white;
  
  // Paleta de Ações (Efeito Psicológico)
  static const Color actionKiss = Color(0xFFFF5252); // Paixão/Calor
  static const Color actionHug = Color(0xFFFFAB40); // Acolhimento
  static const Color actionHandshake = Color(0xFF81C784); // Confiança/Equilíbrio
  static const Color actionDate = Color(0xFF7E57C2); // Mistério/Noite
  
  // Status de Sistema
  static const Color online = Color(0xFF66BB6A);
  static const Color offline = Color(0xFFB0BEC5); // Cinza moderado (baixa irritação)
  
  static const Gradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary],
  );

  static const Color textPrimary = Color(0xFF263238); // Azul escuro dessaturado
  static const Color textSecondary = Color(0xFF78909C);
}
