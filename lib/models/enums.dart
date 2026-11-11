import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Classificação de Risco Clínico (RF03)
enum RiskLevel {
  baixo,
  moderado,
  urgente;

  String get label {
    switch (this) {
      case RiskLevel.baixo:
        return 'Baixo Risco';
      case RiskLevel.moderado:
        return 'Risco Moderado';
      case RiskLevel.urgente:
        return 'Urgência Clínica';
    }
  }

  Color get color {
    switch (this) {
      case RiskLevel.baixo:
        return AppColors.riskLow;
      case RiskLevel.moderado:
        return AppColors.riskModerate;
      case RiskLevel.urgente:
        return AppColors.riskUrgent;
    }
  }

  Color get backgroundColor {
    switch (this) {
      case RiskLevel.baixo:
        return AppColors.riskLowBg;
      case RiskLevel.moderado:
        return AppColors.riskModerateBg;
      case RiskLevel.urgente:
        return AppColors.riskUrgentBg;
    }
  }

  IconData get icon {
    switch (this) {
      case RiskLevel.baixo:
        return Icons.check_circle_outline;
      case RiskLevel.moderado:
        return Icons.warning_amber_rounded;
      case RiskLevel.urgente:
        return Icons.error_outline;
    }
  }

  static RiskLevel fromString(String value) {
    switch (value.toLowerCase()) {
      case 'urgente':
        return RiskLevel.urgente;
      case 'moderado':
        return RiskLevel.moderado;
      case 'baixo':
      default:
        return RiskLevel.baixo;
    }
  }
}

/// Status da Ficha de Triagem (RF02 / RF04)
enum TriageStatus {
  pendente,
  orientacaoEmitida;

  String get label {
    switch (this) {
      case TriageStatus.pendente:
        return 'Pendente de Avaliação';
      case TriageStatus.orientacaoEmitida:
        return 'Orientação Emitida';
    }
  }

  Color get color {
    switch (this) {
      case TriageStatus.pendente:
        return AppColors.statusPending;
      case TriageStatus.orientacaoEmitida:
        return AppColors.statusCompleted;
    }
  }

  Color get backgroundColor {
    switch (this) {
      case TriageStatus.pendente:
        return AppColors.statusPendingBg;
      case TriageStatus.orientacaoEmitida:
        return AppColors.statusCompletedBg;
    }
  }

  IconData get icon {
    switch (this) {
      case TriageStatus.pendente:
        return Icons.hourglass_top_rounded;
      case TriageStatus.orientacaoEmitida:
        return Icons.verified_rounded;
    }
  }

  static TriageStatus fromString(String value) {
    if (value.toLowerCase().contains('emitid')) {
      return TriageStatus.orientacaoEmitida;
    }
    return TriageStatus.pendente;
  }
}

/// Estado do Consumo do WebService REST (Requisito 4)
enum WebServiceState {
  initial,
  loading,
  success,
  error;
}
