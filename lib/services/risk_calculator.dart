import '../models/enums.dart';
import '../models/vital_signs_model.dart';

class RiskAssessment {
  final RiskLevel level;
  final String justification;
  final List<String> flaggedFactors;

  const RiskAssessment({
    required this.level,
    required this.justification,
    required this.flaggedFactors,
  });
}

/// Motor de Classificação Automática de Risco Clínico (RF03)
/// Analisa sinais vitais e sintomas informados para triagem comunitária rápida.
class RiskCalculator {
  static const List<String> urgentSymptoms = [
    'Dor no peito opressiva',
    'Falta de ar aguda / dispneia severa',
    'Perda de consciência / desmaio',
    'Sinais de AVC (fraqueza súbita / fala arrastada)',
    'Convulsão recente',
    'Hemorragia ativa',
  ];

  static const List<String> moderateSymptoms = [
    'Cefaleia intensa e persistente',
    'Tontura / vertigem forte',
    'Vômitos contínuos / desidratação',
    'Febre persistente (> 38°C)',
    'Dor abdominal moderada a intensa',
    'Visão turva ou embaçada',
  ];

  static RiskAssessment assess({
    required VitalSigns vitals,
    required List<String> symptoms,
  }) {
    final List<String> urgentFactors = [];
    final List<String> moderateFactors = [];

    // 1. Avaliação de Pressão Arterial
    if (vitals.systolicBP >= 180 || vitals.diastolicBP >= 110) {
      urgentFactors.add(
          'Crise Hipertensiva Severa (${vitals.systolicBP}/${vitals.diastolicBP} mmHg)');
    } else if (vitals.systolicBP >= 140 || vitals.diastolicBP >= 90) {
      moderateFactors.add(
          'Pressão Arterial Elevada (${vitals.systolicBP}/${vitals.diastolicBP} mmHg)');
    }

    // 2. Avaliação de Glicemia Capilar
    if (vitals.bloodGlucose >= 300) {
      urgentFactors.add(
          'Hiperglicemia Crítica (${vitals.bloodGlucose.toStringAsFixed(0)} mg/dL)');
    } else if (vitals.bloodGlucose < 50) {
      urgentFactors.add(
          'Hipoglicemia Severa (${vitals.bloodGlucose.toStringAsFixed(0)} mg/dL)');
    } else if (vitals.bloodGlucose >= 200) {
      moderateFactors.add(
          'Hiperglicemia Moderada (${vitals.bloodGlucose.toStringAsFixed(0)} mg/dL)');
    } else if (vitals.bloodGlucose < 70) {
      moderateFactors.add(
          'Hipoglicemia Moderada (${vitals.bloodGlucose.toStringAsFixed(0)} mg/dL)');
    }

    // 3. Avaliação de Temperatura Corporal
    if (vitals.temperature >= 39.5) {
      urgentFactors.add(
          'Hipertermia Crítica (${vitals.temperature.toStringAsFixed(1)} °C)');
    } else if (vitals.temperature < 35.0) {
      urgentFactors.add(
          'Hipotermia Significativa (${vitals.temperature.toStringAsFixed(1)} °C)');
    } else if (vitals.temperature >= 37.8) {
      moderateFactors.add(
          'Estado Febril (${vitals.temperature.toStringAsFixed(1)} °C)');
    }

    // 4. Frequência Cardíaca e SpO2
    if (vitals.heartRate >= 130 || vitals.heartRate < 45) {
      urgentFactors.add('Frequência Cardíaca Crítica (${vitals.heartRate} bpm)');
    } else if (vitals.heartRate > 100 || vitals.heartRate < 55) {
      moderateFactors.add('Frequência Cardíaca Alterada (${vitals.heartRate} bpm)');
    }

    if (vitals.oxygenSaturation > 0 && vitals.oxygenSaturation < 92) {
      urgentFactors.add('Dessaturação de Oxigênio (${vitals.oxygenSaturation}%)');
    } else if (vitals.oxygenSaturation >= 92 && vitals.oxygenSaturation <= 94) {
      moderateFactors.add('Saturação Limítrofe (${vitals.oxygenSaturation}%)');
    }

    // 5. Sintomas Críticos
    for (final symptom in symptoms) {
      if (urgentSymptoms.contains(symptom)) {
        urgentFactors.add('Sintoma Crítico: $symptom');
      } else if (moderateSymptoms.contains(symptom)) {
        moderateFactors.add('Sintoma de Alerta: $symptom');
      }
    }

    // Decisão Final do Risco
    if (urgentFactors.isNotEmpty) {
      return RiskAssessment(
        level: RiskLevel.urgente,
        justification:
            'Atenção Médica Imediata: identificados fatores clínicos críticos (${urgentFactors.join(", ")}). Requer teleorientação emergencial ou transporte para hospital.',
        flaggedFactors: urgentFactors,
      );
    }

    if (moderateFactors.isNotEmpty) {
      return RiskAssessment(
        level: RiskLevel.moderado,
        justification:
            'Atenção Preventiva Prioritária: identificadas alterações nos sinais vitais ou sintomas de alerta (${moderateFactors.join(", ")}). Recomenda-se teleorientação no mesmo dia.',
        flaggedFactors: moderateFactors,
      );
    }

    return const RiskAssessment(
      level: RiskLevel.baixo,
      justification:
          'Quadro Estável: sinais vitais dentro das faixas normais e ausência de sintomas de alarme. Orientação de suporte e prevenção primária.',
      flaggedFactors: [],
    );
  }
}
