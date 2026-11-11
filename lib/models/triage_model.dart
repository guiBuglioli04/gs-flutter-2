import 'enums.dart';
import 'patient_model.dart';
import 'vital_signs_model.dart';

/// Modelo de Conduta / Teleorientação Médica Emitida (RF04)
class MedicalOrientation {
  final String conduct; // Conduta clínica e recomendações
  final bool referralNeeded; // Encaminhamento presencial necessário?
  final String referralUnit; // Unidade de referência se necessário
  final String doctorName; // Nome do médico ou enfermeiro de teleorientação
  final String professionalRegister; // CRM / COREN
  final DateTime emittedAt;

  const MedicalOrientation({
    required this.conduct,
    required this.referralNeeded,
    this.referralUnit = '',
    required this.doctorName,
    required this.professionalRegister,
    required this.emittedAt,
  });

  factory MedicalOrientation.fromJson(Map<String, dynamic> json) {
    return MedicalOrientation(
      conduct: json['conduct'] as String? ?? '',
      referralNeeded: json['referralNeeded'] as bool? ?? false,
      referralUnit: json['referralUnit'] as String? ?? '',
      doctorName: json['doctorName'] as String? ?? '',
      professionalRegister: json['professionalRegister'] as String? ?? '',
      emittedAt: json['emittedAt'] != null
          ? DateTime.parse(json['emittedAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conduct': conduct,
      'referralNeeded': referralNeeded,
      'referralUnit': referralUnit,
      'doctorName': doctorName,
      'professionalRegister': professionalRegister,
      'emittedAt': emittedAt.toIso8601String(),
    };
  }
}

/// Ficha de Triagem Preventiva (RF02, RF03, RF04)
class Triage {
  final String protocol; // Protocolo único (ex: SP-2026-1042)
  final Patient patient;
  final VitalSigns vitalSigns;
  final List<String> symptoms;
  final String observations;
  final RiskLevel riskLevel;
  final String riskReason;
  final TriageStatus status;
  final DateTime createdAt;
  final MedicalOrientation? orientation;
  final bool isFavorite;

  const Triage({
    required this.protocol,
    required this.patient,
    required this.vitalSigns,
    required this.symptoms,
    required this.observations,
    required this.riskLevel,
    required this.riskReason,
    this.status = TriageStatus.pendente,
    required this.createdAt,
    this.orientation,
    this.isFavorite = false,
  });

  Triage copyWith({
    String? protocol,
    Patient? patient,
    VitalSigns? vitalSigns,
    List<String>? symptoms,
    String? observations,
    RiskLevel? riskLevel,
    String? riskReason,
    TriageStatus? status,
    DateTime? createdAt,
    MedicalOrientation? orientation,
    bool? isFavorite,
  }) {
    return Triage(
      protocol: protocol ?? this.protocol,
      patient: patient ?? this.patient,
      vitalSigns: vitalSigns ?? this.vitalSigns,
      symptoms: symptoms ?? this.symptoms,
      observations: observations ?? this.observations,
      riskLevel: riskLevel ?? this.riskLevel,
      riskReason: riskReason ?? this.riskReason,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      orientation: orientation ?? this.orientation,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  factory Triage.fromJson(Map<String, dynamic> json) {
    return Triage(
      protocol: json['protocol'] as String? ?? '',
      patient: Patient.fromJson(json['patient'] as Map<String, dynamic>),
      vitalSigns: VitalSigns.fromJson(json['vitalSigns'] as Map<String, dynamic>),
      symptoms: (json['symptoms'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      observations: json['observations'] as String? ?? '',
      riskLevel: RiskLevel.fromString(json['riskLevel'] as String? ?? 'baixo'),
      riskReason: json['riskReason'] as String? ?? '',
      status: TriageStatus.fromString(json['status'] as String? ?? 'pendente'),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      orientation: json['orientation'] != null
          ? MedicalOrientation.fromJson(
              json['orientation'] as Map<String, dynamic>)
          : null,
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'protocol': protocol,
      'patient': patient.toJson(),
      'vitalSigns': vitalSigns.toJson(),
      'symptoms': symptoms,
      'observations': observations,
      'riskLevel': riskLevel.name,
      'riskReason': riskReason,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'orientation': orientation?.toJson(),
      'isFavorite': isFavorite,
    };
  }
}
