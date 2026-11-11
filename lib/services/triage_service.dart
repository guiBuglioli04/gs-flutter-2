import 'dart:math';
import '../models/enums.dart';
import '../models/patient_model.dart';
import '../models/vital_signs_model.dart';
import '../models/triage_model.dart';
import 'risk_calculator.dart';
import 'storage_service.dart';

/// Serviço de Gestão de Triagens e Pacientes Comunitários (RF01 a RF04)
class TriageService {
  static final TriageService instance = TriageService._internal();
  TriageService._internal() {
    _initInitialData();
  }

  final List<Patient> _registeredPatients = [];
  final List<Triage> _triages = [];
  bool _isInitialized = false;

  List<Triage> get allTriages => List.unmodifiable(_triages);
  List<Patient> get registeredPatients => List.unmodifiable(_registeredPatients);

  /// Inicializa dados prévios realistas para demonstração imediata do app
  Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;
    final favList = await StorageService.getFavorites();
    for (int i = 0; i < _triages.length; i++) {
      if (favList.contains(_triages[i].protocol)) {
        _triages[i] = _triages[i].copyWith(isFavorite: true);
      }
    }
  }

  void _initInitialData() {
    // 1. Base comunitária de pacientes cadastrados (RF01)
    _registeredPatients.addAll([
      const Patient(
        id: 'P01',
        name: 'Dona Maria de Lourdes Silva',
        cpf: '123.456.789-00',
        age: 68,
        gender: 'Feminino',
        community: 'Comunidade Ribeirinha Lago Verde',
        phone: '(92) 98451-2231',
        chronicConditions: ['Hipertensão', 'Diabetes Tipo 2'],
        activeRegistered: true,
      ),
      const Patient(
        id: 'P02',
        name: 'Seu Raimundo Nonato Ferreira',
        cpf: '234.567.890-11',
        age: 74,
        gender: 'Masculino',
        community: 'Assentamento Esperança',
        phone: '(92) 99120-4490',
        chronicConditions: ['Doença Pulmonar Obstrutiva'],
        activeRegistered: true,
      ),
      const Patient(
        id: 'P03',
        name: 'Ana Vitória Cabral',
        cpf: '345.678.901-22',
        age: 32,
        gender: 'Feminino',
        community: 'Vila Periférica Nova Aliança',
        phone: '(11) 97321-5582',
        chronicConditions: [],
        activeRegistered: true,
      ),
      const Patient(
        id: 'P04',
        name: 'Tiago Jaci Tupinambá',
        cpf: '456.789.012-33',
        age: 45,
        gender: 'Masculino',
        community: 'Aldeia Indígena Rio Solimões',
        phone: '(97) 98112-9011',
        chronicConditions: ['Hipertensão'],
        activeRegistered: true,
      ),
      const Patient(
        id: 'P05',
        name: 'Clarice Mendes da Rocha',
        cpf: '567.890.123-44',
        age: 58,
        gender: 'Feminino',
        community: 'Morro da Conquista',
        phone: '(21) 98845-6677',
        chronicConditions: ['Diabetes Tipo 1'],
        activeRegistered: true,
      ),
    ]);

    // 2. Fichas de triagem já cadastradas com diferentes níveis de gravidade
    _triages.addAll([
      // Caso Urgente
      Triage(
        protocol: 'SP-2026-101',
        patient: _registeredPatients[1], // Seu Raimundo
        vitalSigns: const VitalSigns(
          systolicBP: 190,
          diastolicBP: 115,
          bloodGlucose: 310,
          temperature: 37.2,
          heartRate: 112,
          oxygenSaturation: 91,
        ),
        symptoms: const [
          'Dor no peito opressiva',
          'Falta de ar aguda / dispneia severa',
          'Tontura / vertigem forte',
        ],
        observations:
            'Paciente idoso queixando-se de dor torácica irradiando para o braço há 40 minutos. Não tomou medicação contínua hoje.',
        riskLevel: RiskLevel.urgente,
        riskReason:
            'Atenção Médica Imediata: identificados fatores clínicos críticos (Crise Hipertensiva Severa 190/115 mmHg, Hiperglicemia Crítica 310 mg/dL, Dessaturação 91%, Dor no peito opressiva).',
        status: TriageStatus.pendente,
        createdAt: DateTime.now().subtract(const Duration(minutes: 25)),
        isFavorite: true,
      ),

      // Caso Moderado
      Triage(
        protocol: 'SP-2026-102',
        patient: _registeredPatients[0], // Dona Maria
        vitalSigns: const VitalSigns(
          systolicBP: 155,
          diastolicBP: 95,
          bloodGlucose: 230,
          temperature: 38.2,
          heartRate: 88,
          oxygenSaturation: 96,
        ),
        symptoms: const [
          'Cefaleia intensa e persistente',
          'Febre persistente (> 38°C)',
          'Tontura / vertigem forte',
        ],
        observations:
            'Relata dor de cabeça pulsátil desde o início da manhã e calafrios. Hidratação oral iniciada pelo agente comunitário.',
        riskLevel: RiskLevel.moderado,
        riskReason:
            'Atenção Preventiva Prioritária: Pressão arterial elevada (155/95 mmHg), Hiperglicemia moderada (230 mg/dL) e febre (38.2 °C).',
        status: TriageStatus.pendente,
        createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 10)),
        isFavorite: false,
      ),

      // Caso Baixo com Orientação Emitida (Exemplo de Deslocamento Evitado)
      Triage(
        protocol: 'SP-2026-103',
        patient: _registeredPatients[2], // Ana Vitória
        vitalSigns: const VitalSigns(
          systolicBP: 120,
          diastolicBP: 80,
          bloodGlucose: 92,
          temperature: 36.6,
          heartRate: 72,
          oxygenSaturation: 99,
        ),
        symptoms: const [
          'Coriza / espirros',
          'Dores musculares leves',
        ],
        observations:
            'Quadro gripal leve de 2 dias. Sem sinais respiratórios graves. Procurou posto para orientações de autocuidado.',
        riskLevel: RiskLevel.baixo,
        riskReason:
            'Quadro Estável: sinais vitais normais e ausência de fatores de gravidade clínica.',
        status: TriageStatus.orientacaoEmitida,
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        orientation: MedicalOrientation(
          conduct:
              'Repouso domiciliar, aumento da ingestão de líquidos (mínimo 2L/dia) e analgesia com paracetamol conforme prescrito em caso de dor. Retornar se surgir febre alta ou falta de ar.',
          referralNeeded: false,
          referralUnit: 'Resolução Domiciliar / Sem Deslocamento',
          doctorName: 'Dr. Leonardo Vasconcelos',
          professionalRegister: 'CRM-SP 189422',
          emittedAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 15)),
        ),
        isFavorite: false,
      ),

      // Caso Moderado já com Orientação
      Triage(
        protocol: 'SP-2026-104',
        patient: _registeredPatients[4], // Clarice
        vitalSigns: const VitalSigns(
          systolicBP: 145,
          diastolicBP: 92,
          bloodGlucose: 215,
          temperature: 36.8,
          heartRate: 82,
          oxygenSaturation: 97,
        ),
        symptoms: const [
          'Visão turva ou embaçada',
          'Sede excessiva',
        ],
        observations:
            'Paciente diabética relata alteração visual transitória e polidipsia nos últimos 3 dias.',
        riskLevel: RiskLevel.moderado,
        riskReason:
            'Atenção Preventiva: descompensação glicêmica com PA discretamente elevada.',
        status: TriageStatus.orientacaoEmitida,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        orientation: MedicalOrientation(
          conduct:
              'Ajuste temporário da dose de insulina conforme protocolo da UBS, dieta hipoglicídica e agendamento de teleconsulta com endocrinologista para próxima semana.',
          referralNeeded: false,
          referralUnit: 'Teleorientação Preventiva',
          doctorName: 'Dra. Sofia Lima',
          professionalRegister: 'CRM-SP 210874',
          emittedAt: DateTime.now().subtract(const Duration(hours: 4)),
        ),
        isFavorite: false,
      ),
    ]);
  }

  /// RF01 - Validação de Cadastro Ativo do Paciente
  Patient? findPatientByCpf(String cpf) {
    final cleanCpf = cpf.replaceAll(RegExp(r'[^0-9]'), '');
    for (final patient in _registeredPatients) {
      final patClean = patient.cpf.replaceAll(RegExp(r'[^0-9]'), '');
      if (patClean == cleanCpf && patient.activeRegistered) {
        return patient;
      }
    }
    return null;
  }

  /// Cadastra novo paciente caso não exista
  Patient registerPatient({
    required String name,
    required String cpf,
    required int age,
    required String gender,
    required String community,
    required String phone,
    List<String> chronicConditions = const [],
  }) {
    final newPatient = Patient(
      id: 'P0${_registeredPatients.length + 1}',
      name: name,
      cpf: cpf,
      age: age,
      gender: gender,
      community: community,
      phone: phone,
      chronicConditions: chronicConditions,
      activeRegistered: true,
    );
    _registeredPatients.add(newPatient);
    return newPatient;
  }

  /// RF02 / RF03 - Registra nova ficha de triagem preventiva
  Triage createTriage({
    required Patient patient,
    required VitalSigns vitalSigns,
    required List<String> symptoms,
    required String observations,
  }) {
    // Avalia o risco clinicamente
    final assessment = RiskCalculator.assess(
      vitals: vitalSigns,
      symptoms: symptoms,
    );

    // Gera protocolo único (RF02)
    final randomNum = 100 + Random().nextInt(900);
    final protocol = 'SP-2026-$randomNum';

    final triage = Triage(
      protocol: protocol,
      patient: patient,
      vitalSigns: vitalSigns,
      symptoms: symptoms,
      observations: observations,
      riskLevel: assessment.level,
      riskReason: assessment.justification,
      status: TriageStatus.pendente,
      createdAt: DateTime.now(),
      isFavorite: false,
    );

    // Insere no topo da fila
    _triages.insert(0, triage);
    return triage;
  }

  /// RF04 - Emite Orientação Médica / Conduta
  bool emitMedicalOrientation({
    required String protocol,
    required String conduct,
    required bool referralNeeded,
    String referralUnit = '',
    required String doctorName,
    required String professionalRegister,
  }) {
    final index = _triages.indexWhere((t) => t.protocol == protocol);
    if (index == -1) return false;

    final orientation = MedicalOrientation(
      conduct: conduct,
      referralNeeded: referralNeeded,
      referralUnit: referralUnit,
      doctorName: doctorName,
      professionalRegister: professionalRegister,
      emittedAt: DateTime.now(),
    );

    _triages[index] = _triages[index].copyWith(
      status: TriageStatus.orientacaoEmitida,
      orientation: orientation,
    );
    return true;
  }

  /// Alterna o status de favorito de uma triagem
  Future<void> toggleFavorite(String protocol) async {
    final index = _triages.indexWhere((t) => t.protocol == protocol);
    if (index != -1) {
      final currentFav = _triages[index].isFavorite;
      _triages[index] = _triages[index].copyWith(isFavorite: !currentFav);

      final favs = _triages
          .where((t) => t.isFavorite)
          .map((t) => t.protocol)
          .toList();
      await StorageService.saveFavorites(favs);
    }
  }

  /// Filtra e busca triagens
  List<Triage> filterTriages({
    RiskLevel? riskFilter,
    String query = '',
    bool onlyFavorites = false,
    TriageStatus? statusFilter,
  }) {
    return _triages.where((triage) {
      // Filtro de Favoritos
      if (onlyFavorites && !triage.isFavorite) return false;

      // Filtro de Nível de Risco
      if (riskFilter != null && triage.riskLevel != riskFilter) return false;

      // Filtro de Status
      if (statusFilter != null && triage.status != statusFilter) return false;

      // Busca textual (Nome, CPF, Protocolo ou Comunidade)
      if (query.trim().isNotEmpty) {
        final q = query.toLowerCase().trim();
        final matchProtocol = triage.protocol.toLowerCase().contains(q);
        final matchName = triage.patient.name.toLowerCase().contains(q);
        final matchCpf = triage.patient.cpf.toLowerCase().contains(q);
        final matchCommunity = triage.patient.community.toLowerCase().contains(q);
        return matchProtocol || matchName || matchCpf || matchCommunity;
      }

      return true;
    }).toList()
      ..sort((a, b) {
        // Ordenação prioritária: Urgente > Moderado > Baixo, depois mais recente
        final priorityA = _riskPriorityValue(a.riskLevel);
        final priorityB = _riskPriorityValue(b.riskLevel);
        if (priorityA != priorityB) {
          return priorityB.compareTo(priorityA); // Maior prioridade primeiro
        }
        return b.createdAt.compareTo(a.createdAt);
      });
  }

  int _riskPriorityValue(RiskLevel level) {
    switch (level) {
      case RiskLevel.urgente:
        return 3;
      case RiskLevel.moderado:
        return 2;
      case RiskLevel.baixo:
        return 1;
    }
  }

  // Estatísticas de Impacto para o Dashboard e Pitch
  int get countTotal => _triages.length;
  int get countUrgent =>
      _triages.where((t) => t.riskLevel == RiskLevel.urgente).length;
  int get countModerate =>
      _triages.where((t) => t.riskLevel == RiskLevel.moderado).length;
  int get countLow =>
      _triages.where((t) => t.riskLevel == RiskLevel.baixo).length;
  int get countPending =>
      _triages.where((t) => t.status == TriageStatus.pendente).length;
  int get countResolved =>
      _triages.where((t) => t.status == TriageStatus.orientacaoEmitida).length;

  /// Indicador de Deslocamentos Evitados (Meta ODS 3 e ODS 10)
  int get countAvoidedTrips => _triages
      .where((t) =>
          t.status == TriageStatus.orientacaoEmitida &&
          t.orientation != null &&
          !t.orientation!.referralNeeded)
      .length;
}
