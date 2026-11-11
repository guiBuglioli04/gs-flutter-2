import 'package:flutter/material.dart';

/// Paleta de cores oficial do SaúdePerto
/// Alinhada com acessibilidade, alto contraste e classificação de risco clínico.
class AppColors {
  // Primárias (Verde Petróleo / Teal Saúde)
  static const Color primary = Color(0xFF00695C);
  static const Color primaryDark = Color(0xFF004D40);
  static const Color primaryLight = Color(0xFFE0F2F1);
  static const Color accent = Color(0xFF00897B);

  // Classificação de Risco Clínico (RF03)
  static const Color riskLow = Color(0xFF2E7D32); // Baixo - Verde
  static const Color riskLowBg = Color(0xFFE8F5E9);
  static const Color riskModerate = Color(0xFFF57F17); // Moderado - Amarelo/Âmbar
  static const Color riskModerateBg = Color(0xFFFFF8E1);
  static const Color riskUrgent = Color(0xFFC62828); // Urgente - Vermelho
  static const Color riskUrgentBg = Color(0xFFFFEBEE);

  // Status de Atendimento
  static const Color statusPending = Color(0xFFE65100);
  static const Color statusPendingBg = Color(0xFFFFF3E0);
  static const Color statusCompleted = Color(0xFF1565C0);
  static const Color statusCompletedBg = Color(0xFFE3F2FD);

  // Superfícies e Neutros
  static const Color background = Color(0xFFF4F7F6);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF1A2E2B);
  static const Color textSecondary = Color(0xFF5A6E6A);
  static const Color textMuted = Color(0xFF8A9E9A);
  static const Color border = Color(0xFFCFD8DC);
  static const Color divider = Color(0xFFE0E0E0);

  // ODS Colors (ODS 3 e ODS 10)
  static const Color ods3 = Color(0xFF4C9F38); // Boa Saúde e Bem-Estar
  static const Color ods10 = Color(0xFFDD1367); // Redução das Desigualdades
}
