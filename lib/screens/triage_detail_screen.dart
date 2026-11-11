import 'package:flutter/material.dart';
import '../models/enums.dart';
import '../models/triage_model.dart';
import '../services/risk_calculator.dart';
import '../services/triage_service.dart';
import '../theme/app_colors.dart';
import '../widgets/risk_badge.dart';
import '../widgets/vital_sign_card.dart';

/// Tela Principal 4: Detalhes da Ficha & Teleorientação Médica (RF04, Requisito 3 e 6)
/// Demonstra passagem de parâmetros e emissão de conduta clínica
class TriageDetailScreen extends StatefulWidget {
  final Triage triage;

  const TriageDetailScreen({
    super.key,
    required this.triage,
  });

  @override
  State<TriageDetailScreen> createState() => _TriageDetailScreenState();
}

class _TriageDetailScreenState extends State<TriageDetailScreen> {
  final TriageService _triageService = TriageService.instance;
  late Triage _currentTriage;

  // Controladores para Emissão de Orientação Médica (RF04)
  final _conductController = TextEditingController();
  final _doctorNameController =
      TextEditingController(text: 'Dr. Leonardo Vasconcelos');
  final _crmController = TextEditingController(text: 'CRM-SP 189422');
  final _unitController = TextEditingController(text: 'UBS Central / Hospital');
  bool _referralNeeded = false;
  bool _isSavingOrientation = false;

  @override
  void initState() {
    super.initState();
    _currentTriage = widget.triage;
  }

  @override
  void dispose() {
    _conductController.dispose();
    _doctorNameController.dispose();
    _crmController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  void _toggleFavorite() async {
    await _triageService.toggleFavorite(_currentTriage.protocol);
    setState(() {
      _currentTriage =
          _currentTriage.copyWith(isFavorite: !_currentTriage.isFavorite);
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _currentTriage.isFavorite
              ? 'Ficha adicionada aos favoritos prioritários.'
              : 'Ficha removida dos favoritos.',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // RF04: Emite a Teleorientação Médica
  void _submitMedicalOrientation() {
    final conduct = _conductController.text.trim();
    final doctor = _doctorNameController.text.trim();
    final crm = _crmController.text.trim();

    if (conduct.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, informe a conduta ou orientação médica.'),
        ),
      );
      return;
    }

    setState(() {
      _isSavingOrientation = true;
    });

    final success = _triageService.emitMedicalOrientation(
      protocol: _currentTriage.protocol,
      conduct: conduct,
      referralNeeded: _referralNeeded,
      referralUnit: _referralNeeded ? _unitController.text.trim() : 'Resolução Remota / Sem Deslocamento',
      doctorName: doctor.isEmpty ? 'Médico de Teleorientação' : doctor,
      professionalRegister: crm.isEmpty ? 'CRM' : crm,
    );

    if (success) {
      final updated = _triageService.allTriages
          .firstWhere((t) => t.protocol == _currentTriage.protocol);

      setState(() {
        _currentTriage = updated;
        _isSavingOrientation = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Teleorientação emitida com sucesso! Status alterado para "Orientação Emitida".',
          ),
          backgroundColor: AppColors.primary,
        ),
      );
    } else {
      setState(() {
        _isSavingOrientation = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final patient = _currentTriage.patient;
    final vitals = _currentTriage.vitalSigns;
    final formattedDate =
        '${_currentTriage.createdAt.day.toString().padLeft(2, '0')}/${_currentTriage.createdAt.month.toString().padLeft(2, '0')}/${_currentTriage.createdAt.year} às ${_currentTriage.createdAt.hour.toString().padLeft(2, '0')}:${_currentTriage.createdAt.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(
        title: Text('Protocolo ${_currentTriage.protocol}'),
        actions: [
          IconButton(
            icon: Icon(
              _currentTriage.isFavorite ? Icons.star : Icons.star_border,
              color: _currentTriage.isFavorite ? Colors.amber : Colors.white,
            ),
            tooltip: _currentTriage.isFavorite
                ? 'Remover favorito'
                : 'Adicionar aos favoritos',
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Principal: Identificação do Paciente e Risco
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: _currentTriage.riskLevel.color.withValues(alpha: 0.5),
                  width: 1.5,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RiskBadge(level: _currentTriage.riskLevel),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _currentTriage.status.backgroundColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(_currentTriage.status.icon,
                                  size: 14, color: _currentTriage.status.color),
                              const SizedBox(width: 4),
                              Text(
                                _currentTriage.status.label,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: _currentTriage.status.color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Nome e Idade
                    Text(
                      patient.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${patient.gender} • ${patient.age} anos • CPF: ${patient.cpf}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Comunidade e Contato
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 16, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            patient.community,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (patient.phone.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.phone,
                              size: 15, color: AppColors.textMuted),
                          const SizedBox(width: 4),
                          Text(
                            patient.phone,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],

                    const Divider(height: 20, color: AppColors.divider),

                    // Justificativa do Motor de Risco (RF03)
                    Text(
                      'Avaliação Clínica Automatizada:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _currentTriage.riskLevel.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _currentTriage.riskReason,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Triagem registrada em: $formattedDate',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Sinais Vitais em Grid (RF02)
            const Text(
              'Sinais Vitais Coletados',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: VitalSignCard(
                    label: 'Pressão Arterial',
                    value: '${vitals.systolicBP}/${vitals.diastolicBP}',
                    unit: 'mmHg',
                    icon: Icons.favorite,
                    statusColor: vitals.isBPUrgent
                        ? AppColors.riskUrgent
                        : (vitals.isBPModerate
                            ? AppColors.riskModerate
                            : AppColors.riskLow),
                    statusLabel: vitals.isBPUrgent
                        ? 'Crise Hipertensiva'
                        : (vitals.isBPModerate ? 'Elevada' : 'Normal'),
                  ),
                ),
                Expanded(
                  child: VitalSignCard(
                    label: 'Glicemia Capilar',
                    value: vitals.bloodGlucose.toStringAsFixed(0),
                    unit: 'mg/dL',
                    icon: Icons.water_drop,
                    statusColor: vitals.isGlucoseUrgent
                        ? AppColors.riskUrgent
                        : (vitals.isGlucoseModerate
                            ? AppColors.riskModerate
                            : AppColors.riskLow),
                    statusLabel: vitals.isGlucoseUrgent
                        ? 'Crítica'
                        : (vitals.isGlucoseModerate ? 'Alterada' : 'Adequada'),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: VitalSignCard(
                    label: 'Temperatura',
                    value: vitals.temperature.toStringAsFixed(1),
                    unit: '°C',
                    icon: Icons.thermostat,
                    statusColor: vitals.isTempUrgent
                        ? AppColors.riskUrgent
                        : (vitals.isTempModerate
                            ? AppColors.riskModerate
                            : AppColors.riskLow),
                    statusLabel: vitals.isTempUrgent
                        ? 'Febre Alta'
                        : (vitals.isTempModerate ? 'Febril' : 'Afebril'),
                  ),
                ),
                Expanded(
                  child: VitalSignCard(
                    label: 'Freq. Cardíaca',
                    value: '${vitals.heartRate}',
                    unit: 'bpm',
                    icon: Icons.speed,
                    statusColor:
                        vitals.heartRate > 100 || vitals.heartRate < 55
                            ? AppColors.riskModerate
                            : AppColors.riskLow,
                    statusLabel: vitals.heartRate > 100
                        ? 'Taquicardia'
                        : (vitals.heartRate < 55 ? 'Bradicardia' : 'Normal'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Sintomas Relatados
            const Text(
              'Sintomas Informados',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_currentTriage.symptoms.isEmpty)
                      const Text(
                        'Nenhum sintoma agudo informado (triagem preventiva de rotina).',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _currentTriage.symptoms.map((symptom) {
                          final isUrgent =
                              RiskCalculator.urgentSymptoms.contains(symptom);
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: isUrgent
                                  ? AppColors.riskUrgentBg
                                  : AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isUrgent
                                    ? AppColors.riskUrgent.withValues(alpha: 0.5)
                                    : AppColors.primary.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isUrgent
                                      ? Icons.warning_rounded
                                      : Icons.check_circle_outline,
                                  size: 14,
                                  color: isUrgent
                                      ? AppColors.riskUrgent
                                      : AppColors.primary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  symptom,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isUrgent
                                        ? AppColors.riskUrgent
                                        : AppColors.primaryDark,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    if (_currentTriage.observations.isNotEmpty) ...[
                      const Divider(height: 20),
                      const Text(
                        'Observações de Campo:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _currentTriage.observations,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // SEÇÃO RF04: Teleorientação Médica Remota
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Teleorientação Médica (RF04)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (_currentTriage.status == TriageStatus.orientacaoEmitida)
                  const Chip(
                    avatar: Icon(Icons.check_circle,
                        size: 16, color: AppColors.riskLow),
                    label: Text(
                      'Emitida',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.riskLow),
                    ),
                    backgroundColor: AppColors.riskLowBg,
                  ),
              ],
            ),
            const SizedBox(height: 10),

            if (_currentTriage.status == TriageStatus.orientacaoEmitida &&
                _currentTriage.orientation != null)
              // Exibição da Conduta Já Emitida
              Card(
                elevation: 2,
                color: const Color(0xFFF9FDFB),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFF80CBC4), width: 1.5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const CircleAvatar(
                                radius: 16,
                                backgroundColor: AppColors.primary,
                                child: Icon(Icons.medical_services_rounded,
                                    size: 18, color: Colors.white),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _currentTriage.orientation!.doctorName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    _currentTriage.orientation!.professionalRegister,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _currentTriage.orientation!.referralNeeded
                                  ? AppColors.riskUrgentBg
                                  : AppColors.riskLowBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _currentTriage.orientation!.referralNeeded
                                  ? 'Encaminhamento Hospitalar'
                                  : 'Resolução Domiciliar',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: _currentTriage.orientation!.referralNeeded
                                    ? AppColors.riskUrgent
                                    : AppColors.riskLow,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      const Text(
                        'Conduta Clínica e Prescrição:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _currentTriage.orientation!.conduct,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                          height: 1.4,
                        ),
                      ),
                      if (_currentTriage.orientation!.referralNeeded &&
                          _currentTriage.orientation!.referralUnit.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.riskUrgentBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.local_hospital_rounded,
                                  size: 16, color: AppColors.riskUrgent),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Unidade Indicada: ${_currentTriage.orientation!.referralUnit}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.riskUrgent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              )
            else
              // Formulário para o Médico/Enfermeiro Emitir a Orientação
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Registrar Conduta Remota para este Paciente',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Avalie os sinais vitais acima e oriente o agente comunitário sobre hidratação, medicação de alívio ou transporte de urgência.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _conductController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'Conduta e Orientações Médicas *',
                          hintText:
                              'ex: Iniciar hidratação oral vigorosa com SRO. Administrar paracetamol 500mg em caso de dor...',
                          alignLabelWithHint: true,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          'Exige Encaminhamento Presencial?',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: const Text(
                          'Marque se o caso não puder ser resolvido remotamente e necessitar de transporte até o hospital.',
                          style: TextStyle(fontSize: 11),
                        ),
                        value: _referralNeeded,
                        activeThumbColor: AppColors.riskUrgent,
                        onChanged: (val) {
                          setState(() {
                            _referralNeeded = val;
                          });
                        },
                      ),
                      if (_referralNeeded) ...[
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _unitController,
                          decoration: const InputDecoration(
                            labelText: 'Unidade Hospitalar de Destino',
                            prefixIcon: Icon(Icons.local_hospital_outlined),
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _doctorNameController,
                              decoration: const InputDecoration(
                                labelText: 'Profissional Avaliador',
                                prefixIcon: Icon(Icons.person_pin),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: _crmController,
                              decoration: const InputDecoration(
                                labelText: 'CRM / COREN',
                                prefixIcon: Icon(Icons.badge),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isSavingOrientation
                              ? null
                              : _submitMedicalOrientation,
                          icon: _isSavingOrientation
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.check_circle_outline),
                          label: const Text('Salvar e Emitir Teleorientação'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
