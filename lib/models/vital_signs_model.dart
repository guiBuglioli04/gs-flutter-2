/// Modelo de Sinais Vitais da Ficha Preventiva (RF02)
class VitalSigns {
  final int systolicBP; // Pressão Sistólica (mmHg)
  final int diastolicBP; // Pressão Diastólica (mmHg)
  final double bloodGlucose; // Glicemia Capilar (mg/dL)
  final double temperature; // Temperatura Corporal (°C)
  final int heartRate; // Frequência Cardíaca (bpm)
  final int oxygenSaturation; // SpO2 (%)

  const VitalSigns({
    required this.systolicBP,
    required this.diastolicBP,
    required this.bloodGlucose,
    required this.temperature,
    required this.heartRate,
    this.oxygenSaturation = 98,
  });

  String get bloodPressureString => '$systolicBP/$diastolicBP mmHg';

  bool get isBPNormal => systolicBP < 130 && diastolicBP < 85;
  bool get isBPUrgent => systolicBP >= 180 || diastolicBP >= 110;
  bool get isBPModerate =>
      (systolicBP >= 140 && systolicBP < 180) ||
      (diastolicBP >= 90 && diastolicBP < 110);

  bool get isGlucoseUrgent => bloodGlucose >= 300 || bloodGlucose < 50;
  bool get isGlucoseModerate =>
      (bloodGlucose >= 200 && bloodGlucose < 300) ||
      (bloodGlucose >= 50 && bloodGlucose < 70);

  bool get isTempUrgent => temperature >= 39.5 || temperature < 35.0;
  bool get isTempModerate => temperature >= 37.8 && temperature < 39.5;

  factory VitalSigns.fromJson(Map<String, dynamic> json) {
    return VitalSigns(
      systolicBP: json['systolicBP'] as int? ?? 120,
      diastolicBP: json['diastolicBP'] as int? ?? 80,
      bloodGlucose: (json['bloodGlucose'] as num?)?.toDouble() ?? 95.0,
      temperature: (json['temperature'] as num?)?.toDouble() ?? 36.5,
      heartRate: json['heartRate'] as int? ?? 75,
      oxygenSaturation: json['oxygenSaturation'] as int? ?? 98,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'systolicBP': systolicBP,
      'diastolicBP': diastolicBP,
      'bloodGlucose': bloodGlucose,
      'temperature': temperature,
      'heartRate': heartRate,
      'oxygenSaturation': oxygenSaturation,
    };
  }
}
