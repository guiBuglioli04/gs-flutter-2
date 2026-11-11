import 'package:flutter_test/flutter_test.dart';
import 'package:gs_flutter_2/models/enums.dart';
import 'package:gs_flutter_2/models/vital_signs_model.dart';
import 'package:gs_flutter_2/services/risk_calculator.dart';
import 'package:gs_flutter_2/services/triage_service.dart';
import 'package:gs_flutter_2/main.dart';

void main() {
  group('Motor de Classificação de Risco Clínico (RF03)', () {
    test('Classifica caso crítico como URGENTE', () {
      const vitals = VitalSigns(
        systolicBP: 195,
        diastolicBP: 115,
        bloodGlucose: 320,
        temperature: 37.0,
        heartRate: 110,
        oxygenSaturation: 90,
      );

      final assessment = RiskCalculator.assess(
        vitals: vitals,
        symptoms: ['Dor no peito opressiva'],
      );

      expect(assessment.level, equals(RiskLevel.urgente));
      expect(assessment.flaggedFactors.isNotEmpty, isTrue);
    });

    test('Classifica caso com pressão limítrofe e febre como MODERADO', () {
      const vitals = VitalSigns(
        systolicBP: 150,
        diastolicBP: 95,
        bloodGlucose: 140,
        temperature: 38.5,
        heartRate: 85,
        oxygenSaturation: 97,
      );

      final assessment = RiskCalculator.assess(
        vitals: vitals,
        symptoms: ['Cefaleia intensa e persistente'],
      );

      expect(assessment.level, equals(RiskLevel.moderado));
    });

    test('Classifica caso com sinais normais como BAIXO', () {
      const vitals = VitalSigns(
        systolicBP: 120,
        diastolicBP: 80,
        bloodGlucose: 95,
        temperature: 36.5,
        heartRate: 72,
        oxygenSaturation: 99,
      );

      final assessment = RiskCalculator.assess(
        vitals: vitals,
        symptoms: ['Coriza / espirros leves'],
      );

      expect(assessment.level, equals(RiskLevel.baixo));
    });
  });

  group('Serviço de Triagens e Pacientes Comunitários (RF01 e RF02)', () {
    test('Consulta e valida paciente ativo por CPF (RF01)', () {
      final service = TriageService.instance;
      final patient = service.findPatientByCpf('123.456.789-00');

      expect(patient, isNotNull);
      expect(patient!.name, contains('Maria de Lourdes'));
      expect(patient.activeRegistered, isTrue);
    });

    test('Criação de nova triagem gera protocolo único e adiciona à fila', () {
      final service = TriageService.instance;
      final patient = service.registeredPatients.first;

      const vitals = VitalSigns(
        systolicBP: 120,
        diastolicBP: 80,
        bloodGlucose: 90,
        temperature: 36.6,
        heartRate: 70,
      );

      final initialCount = service.allTriages.length;
      final triage = service.createTriage(
        patient: patient,
        vitalSigns: vitals,
        symptoms: ['Acompanhamento de rotina / sem queixa aguda'],
        observations: 'Teste automatizado',
      );

      expect(triage.protocol, startsWith('SP-2026-'));
      expect(service.allTriages.length, equals(initialCount + 1));
      expect(service.allTriages.first.protocol, equals(triage.protocol));
    });
  });

  group('Smoke Test do Aplicativo SaúdePerto', () {
    testWidgets('Inicializa o aplicativo SaúdePerto e renderiza o Splash',
        (WidgetTester tester) async {
      await tester.pumpWidget(const SaudePertoApp());
      expect(find.text('SaúdePerto'), findsOneWidget);
      // Avança a transição do splash
      await tester.pump(const Duration(seconds: 3));
      await tester.pump(const Duration(milliseconds: 600));
    });
  });
}
