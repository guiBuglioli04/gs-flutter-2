import 'package:flutter/material.dart';
import '../models/triage_model.dart';
import '../theme/app_colors.dart';
import 'risk_badge.dart';

/// Widget Reutilizável: Card de Triagem para Fila Prioritária (RF04)
class TriageCard extends StatelessWidget {
  final Triage triage;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;

  const TriageCard({
    super.key,
    required this.triage,
    required this.onTap,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final patient = triage.patient;
    final vitals = triage.vitalSigns;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: triage.riskLevel.color.withValues(alpha: 0.35),
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Linha Superior: Protocolo, Badge de Risco e Botão de Favorito
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          triage.protocol,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      RiskBadge(level: triage.riskLevel, compact: true),
                    ],
                  ),
                  IconButton(
                    icon: Icon(
                      triage.isFavorite ? Icons.star : Icons.star_border,
                      color: triage.isFavorite ? Colors.amber : AppColors.textMuted,
                      size: 22,
                    ),
                    onPressed: onToggleFavorite,
                    tooltip: triage.isFavorite
                        ? 'Remover dos favoritos'
                        : 'Marcar como prioritário favorito',
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Nome do Paciente e Idade
              Row(
                children: [
                  const Icon(Icons.person, size: 18, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${patient.name}, ${patient.age} anos',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // Comunidade / Território
              Row(
                children: [
                  const Icon(Icons.location_on_outlined,
                      size: 15, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      patient.community,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const Divider(height: 18, color: AppColors.divider),

              // Resumo dos Sinais Vitais em Pills
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _vitalPill(
                    label: 'PA',
                    value: '${vitals.systolicBP}/${vitals.diastolicBP}',
                    unit: 'mmHg',
                    isAlert: vitals.isBPUrgent || vitals.isBPModerate,
                    alertColor: vitals.isBPUrgent
                        ? AppColors.riskUrgent
                        : AppColors.riskModerate,
                  ),
                  _vitalPill(
                    label: 'Glicemia',
                    value: vitals.bloodGlucose.toStringAsFixed(0),
                    unit: 'mg/dL',
                    isAlert: vitals.isGlucoseUrgent || vitals.isGlucoseModerate,
                    alertColor: vitals.isGlucoseUrgent
                        ? AppColors.riskUrgent
                        : AppColors.riskModerate,
                  ),
                  _vitalPill(
                    label: 'Temp',
                    value: vitals.temperature.toStringAsFixed(1),
                    unit: '°C',
                    isAlert: vitals.isTempUrgent || vitals.isTempModerate,
                    alertColor: vitals.isTempUrgent
                        ? AppColors.riskUrgent
                        : AppColors.riskModerate,
                  ),
                  _vitalPill(
                    label: 'SpO2',
                    value: '${vitals.oxygenSaturation}',
                    unit: '%',
                    isAlert: vitals.oxygenSaturation < 95,
                    alertColor: vitals.oxygenSaturation < 92
                        ? AppColors.riskUrgent
                        : AppColors.riskModerate,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Linha Inferior: Status e Detalhes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: triage.status.backgroundColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          triage.status.icon,
                          size: 13,
                          color: triage.status.color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          triage.status.label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: triage.status.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: const [
                      Text(
                        'Ver Detalhes',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(width: 2),
                      Icon(Icons.chevron_right, size: 18, color: AppColors.primary),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _vitalPill({
    required String label,
    required String value,
    required String unit,
    required bool isAlert,
    required Color alertColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: isAlert
            ? alertColor.withValues(alpha: 0.12)
            : const Color(0xFFF1F5F4),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isAlert ? alertColor.withValues(alpha: 0.5) : Colors.transparent,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isAlert ? alertColor : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            '$value $unit',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isAlert ? alertColor : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
