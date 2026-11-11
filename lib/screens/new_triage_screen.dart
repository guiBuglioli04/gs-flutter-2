import 'package:flutter/material.dart';
import '../models/enums.dart';
import '../models/patient_model.dart';
import '../models/vital_signs_model.dart';
import '../services/risk_calculator.dart';
import '../services/triage_service.dart';
import '../theme/app_colors.dart';
import '../widgets/risk_badge.dart';

/// Tela Principal 3: Registo de Ficha de Triagem Preventiva (RF01, RF02, RF03)
class NewTriageScreen extends StatefulWidget {
  const NewTriageScreen({super.key});

  @override
  State<NewTriageScreen> createState() => _NewTriageScreenState();
}

class _NewTriageScreenState extends State<NewTriageScreen> {
  final _formKey = GlobalKey<FormState>();
  final TriageService _triageService = TriageService.instance;

  // Controladores do Paciente (RF01)
  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _communityController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String _selectedGender = 'Feminino';
  Patient? _foundPatient;
  bool _isNewPatient = false;
  bool _searchedCpf = false;

  // Controladores de Sinais Vitais (RF02)
  final TextEditingController _systolicController =
      TextEditingController(text: '120');
  final TextEditingController _diastolicController =
      TextEditingController(text: '80');
  final TextEditingController _glucoseController =
      TextEditingController(text: '95');
  final TextEditingController _tempController =
      TextEditingController(text: '36.5');
  final TextEditingController _heartRateController =
      TextEditingController(text: '75');
  final TextEditingController _spo2Controller =
      TextEditingController(text: '98');

  // Sintomas e Observações
  final List<String> _availableSymptoms = [
    'Dor no peito opressiva',
    'Falta de ar aguda / dispneia severa',
    'Cefaleia intensa e persistente',
    'Tontura / vertigem forte',
    'Febre persistente (> 38°C)',
    'Vômitos contínuos / desidratação',
    'Visão turva ou embaçada',
    'Coriza / espirros leves',
    'Tosse leve sem falta de ar',
    'Dores musculares leves',
    'Acompanhamento de rotina / sem queixa aguda',
  ];
  final Set<String> _selectedSymptoms = {};
  final TextEditingController _obsController = TextEditingController();

  // Prévia de Risco Dinâmica (RF03)
  RiskAssessment _currentAssessment = const RiskAssessment(
    level: RiskLevel.baixo,
    justification: 'Sinais vitais normais.',
    flaggedFactors: [],
  );

  @override
  void initState() {
    super.initState();
    _recalculateRisk();
  }

  @override
  void dispose() {
    _cpfController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _communityController.dispose();
    _phoneController.dispose();
    _systolicController.dispose();
    _diastolicController.dispose();
    _glucoseController.dispose();
    _tempController.dispose();
    _heartRateController.dispose();
    _spo2Controller.dispose();
    _obsController.dispose();
    super.dispose();
  }

  // RF01: Validação de Cadastro Ativo do Paciente
  void _searchCpf() {
    final cpf = _cpfController.text.trim();
    if (cpf.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe um CPF para consulta')),
      );
      return;
    }

    final patient = _triageService.findPatientByCpf(cpf);
    setState(() {
      _searchedCpf = true;
      if (patient != null) {
        _foundPatient = patient;
        _nameController.text = patient.name;
        _ageController.text = patient.age.toString();
        _communityController.text = patient.community;
        _phoneController.text = patient.phone;
        _selectedGender = patient.gender;
        _isNewPatient = false;
      } else {
        _foundPatient = null;
        _isNewPatient = true;
        _nameController.clear();
        _ageController.clear();
        _communityController.text = 'Comunidade Isolada / Sem UBS';
        _phoneController.clear();
      }
    });
  }

  // RF03: Recalcula o Risco Clínico em Tempo Real
  void _recalculateRisk() {
    final sys = int.tryParse(_systolicController.text) ?? 120;
    final dia = int.tryParse(_diastolicController.text) ?? 80;
    final gluc = double.tryParse(_glucoseController.text.replaceAll(',', '.')) ?? 95.0;
    final temp = double.tryParse(_tempController.text.replaceAll(',', '.')) ?? 36.5;
    final hr = int.tryParse(_heartRateController.text) ?? 75;
    final spo2 = int.tryParse(_spo2Controller.text) ?? 98;

    final vitals = VitalSigns(
      systolicBP: sys,
      diastolicBP: dia,
      bloodGlucose: gluc,
      temperature: temp,
      heartRate: hr,
      oxygenSaturation: spo2,
    );

    final assessment = RiskCalculator.assess(
      vitals: vitals,
      symptoms: _selectedSymptoms.toList(),
    );

    setState(() {
      _currentAssessment = assessment;
    });
  }

  void _submitTriage() {
    if (!_formKey.currentState!.validate()) return;

    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe o nome do paciente')),
      );
      return;
    }

    // Cria ou recupera o paciente
    Patient patient;
    if (_foundPatient != null && !_isNewPatient) {
      patient = _foundPatient!;
    } else {
      patient = _triageService.registerPatient(
        name: _nameController.text.trim(),
        cpf: _cpfController.text.trim().isEmpty
            ? '000.000.000-00'
            : _cpfController.text.trim(),
        age: int.tryParse(_ageController.text) ?? 30,
        gender: _selectedGender,
        community: _communityController.text.trim().isEmpty
            ? 'Comunidade Ribeirinha / Rural'
            : _communityController.text.trim(),
        phone: _phoneController.text.trim(),
      );
    }

    // Constrói os sinais vitais
    final sys = int.tryParse(_systolicController.text) ?? 120;
    final dia = int.tryParse(_diastolicController.text) ?? 80;
    final gluc = double.tryParse(_glucoseController.text.replaceAll(',', '.')) ?? 95.0;
    final temp = double.tryParse(_tempController.text.replaceAll(',', '.')) ?? 36.5;
    final hr = int.tryParse(_heartRateController.text) ?? 75;
    final spo2 = int.tryParse(_spo2Controller.text) ?? 98;

    final vitals = VitalSigns(
      systolicBP: sys,
      diastolicBP: dia,
      bloodGlucose: gluc,
      temperature: temp,
      heartRate: hr,
      oxygenSaturation: spo2,
    );

    // Registra a triagem
    final triage = _triageService.createTriage(
      patient: patient,
      vitalSigns: vitals,
      symptoms: _selectedSymptoms.toList(),
      observations: _obsController.text.trim(),
    );

    // Exibe diálogo de confirmação com protocolo gerado
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              _currentAssessment.level.icon,
              color: _currentAssessment.level.color,
            ),
            const SizedBox(width: 8),
            const Text('Ficha Registrada!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Protocolo Clínico:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    triage.protocol,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text('Paciente: ${patient.name}'),
            const SizedBox(height: 4),
            Row(
              children: [
                const Text('Gravidade: '),
                RiskBadge(level: _currentAssessment.level, compact: true),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _currentAssessment.justification,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context, triage);
            },
            child: const Text('Concluir e Ir para Fila'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Ficha de Triagem'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // CARD RF03: Prévia Dinâmica do Motor de Risco
              Card(
                elevation: 3,
                color: _currentAssessment.level.backgroundColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: _currentAssessment.level.color,
                    width: 2,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.auto_graph_rounded,
                                  size: 18, color: AppColors.textPrimary),
                              SizedBox(width: 6),
                              Text(
                                'Classificação Automática de Risco',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          RiskBadge(level: _currentAssessment.level),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _currentAssessment.justification,
                        style: TextStyle(
                          fontSize: 12,
                          color: _currentAssessment.level.color,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // SEÇÃO 1: Dados do Cidadão (RF01)
              const Text(
                '1. Identificação do Paciente (RF01)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      // Campo CPF com botão de busca na base comunitária
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _cpfController,
                              decoration: const InputDecoration(
                                labelText: 'CPF do Paciente',
                                hintText: 'ex: 123.456.789-00',
                                prefixIcon: Icon(Icons.badge_outlined),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _searchCpf,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 15),
                            ),
                            child: const Text('Validar'),
                          ),
                        ],
                      ),
                      if (_searchedCpf) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _foundPatient != null
                                ? const Color(0xFFE8F5E9)
                                : const Color(0xFFFFF3E0),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _foundPatient != null
                                    ? Icons.check_circle
                                    : Icons.person_add_rounded,
                                size: 16,
                                color: _foundPatient != null
                                    ? AppColors.riskLow
                                    : Colors.orange[800],
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  _foundPatient != null
                                      ? 'Paciente ativo na base comunitária: ${_foundPatient!.name}'
                                      : 'CPF não cadastrado. Preencha os dados abaixo para cadastrar.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: _foundPatient != null
                                        ? AppColors.riskLow
                                        : Colors.orange[900],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nome Completo do Cidadão *',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (val) => val == null || val.trim().isEmpty
                            ? 'Informe o nome'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: TextFormField(
                              controller: _ageController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Idade *',
                                prefixIcon: Icon(Icons.cake_outlined),
                              ),
                              validator: (val) =>
                                  val == null || val.trim().isEmpty
                                      ? 'Obrigatório'
                                      : null,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 2,
                            child: DropdownButtonFormField<String>(
                              initialValue: _selectedGender,
                              decoration: const InputDecoration(
                                labelText: 'Gênero',
                                prefixIcon: Icon(Icons.wc_outlined),
                              ),
                              items: const [
                                DropdownMenuItem(
                                    value: 'Feminino', child: Text('Feminino')),
                                DropdownMenuItem(
                                    value: 'Masculino',
                                    child: Text('Masculino')),
                                DropdownMenuItem(
                                    value: 'Outro', child: Text('Outro')),
                              ],
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _selectedGender = val);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _communityController,
                        decoration: const InputDecoration(
                          labelText: 'Comunidade / Localidade Isolada',
                          hintText: 'ex: Comunidade Ribeirinha Rio Negro',
                          prefixIcon: Icon(Icons.home_outlined),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Telefone / Contato Comunitário',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // SEÇÃO 2: Sinais Vitais (RF02)
              const Text(
                '2. Registro de Sinais Vitais (RF02)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      // Pressão Arterial
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _systolicController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'PA Sistólica (Máx)',
                                suffixText: 'mmHg',
                                prefixIcon: Icon(Icons.favorite_outline),
                              ),
                              onChanged: (_) => _recalculateRisk(),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: _diastolicController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'PA Diastólica (Mín)',
                                suffixText: 'mmHg',
                                prefixIcon: Icon(Icons.favorite_border),
                              ),
                              onChanged: (_) => _recalculateRisk(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Glicemia e Temperatura
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _glucoseController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Glicemia Capilar',
                                suffixText: 'mg/dL',
                                prefixIcon: Icon(Icons.water_drop_outlined),
                              ),
                              onChanged: (_) => _recalculateRisk(),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: _tempController,
                              keyboardType: const TextInputType.numberWithOptions(
                                  decimal: true),
                              decoration: const InputDecoration(
                                labelText: 'Temperatura',
                                suffixText: '°C',
                                prefixIcon: Icon(Icons.thermostat_outlined),
                              ),
                              onChanged: (_) => _recalculateRisk(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Frequência Cardíaca e SpO2
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _heartRateController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Freq. Cardíaca',
                                suffixText: 'bpm',
                                prefixIcon: Icon(Icons.speed),
                              ),
                              onChanged: (_) => _recalculateRisk(),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: _spo2Controller,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Saturação SpO2',
                                suffixText: '%',
                                prefixIcon: Icon(Icons.air),
                              ),
                              onChanged: (_) => _recalculateRisk(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // SEÇÃO 3: Sintomas Relatados
              const Text(
                '3. Sintomas e Queixas Relatadas',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Selecione os sintomas informados pelo cidadão:',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _availableSymptoms.map((symptom) {
                          final isSelected =
                              _selectedSymptoms.contains(symptom);
                          final isUrgent =
                              RiskCalculator.urgentSymptoms.contains(symptom);

                          return FilterChip(
                            label: Text(symptom),
                            selected: isSelected,
                            selectedColor: isUrgent
                                ? AppColors.riskUrgentBg
                                : AppColors.primaryLight,
                            checkmarkColor: isUrgent
                                ? AppColors.riskUrgent
                                : AppColors.primary,
                            labelStyle: TextStyle(
                              fontSize: 12,
                              color: isSelected
                                  ? (isUrgent
                                      ? AppColors.riskUrgent
                                      : AppColors.primaryDark)
                                  : AppColors.textPrimary,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedSymptoms.add(symptom);
                                } else {
                                  _selectedSymptoms.remove(symptom);
                                }
                                _recalculateRisk();
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _obsController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Observações do Agente Comunitário',
                          hintText:
                              'Descreva o contexto, uso de remédios contínuos ou histórico relevante...',
                          alignLabelWithHint: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Botão de Envio e Geração de Protocolo
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _submitTriage,
                  icon: const Icon(Icons.send_rounded),
                  label: const Text('Registrar Triagem e Gerar Protocolo'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
