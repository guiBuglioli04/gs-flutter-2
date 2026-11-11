/// Modelo do Cidadão / Paciente Comunitário (RF01)
class Patient {
  final String id;
  final String name;
  final String cpf;
  final int age;
  final String gender;
  final String community;
  final String phone;
  final List<String> chronicConditions;
  final bool activeRegistered;

  const Patient({
    required this.id,
    required this.name,
    required this.cpf,
    required this.age,
    required this.gender,
    required this.community,
    required this.phone,
    required this.chronicConditions,
    this.activeRegistered = true,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      cpf: json['cpf'] as String? ?? '',
      age: json['age'] as int? ?? 0,
      gender: json['gender'] as String? ?? 'Outro',
      community: json['community'] as String? ?? 'Comunidade Geral',
      phone: json['phone'] as String? ?? '',
      chronicConditions: (json['chronicConditions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      activeRegistered: json['activeRegistered'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'cpf': cpf,
      'age': age,
      'gender': gender,
      'community': community,
      'phone': phone,
      'chronicConditions': chronicConditions,
      'activeRegistered': activeRegistered,
    };
  }

  Patient copyWith({
    String? id,
    String? name,
    String? cpf,
    int? age,
    String? gender,
    String? community,
    String? phone,
    List<String>? chronicConditions,
    bool? activeRegistered,
  }) {
    return Patient(
      id: id ?? this.id,
      name: name ?? this.name,
      cpf: cpf ?? this.cpf,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      community: community ?? this.community,
      phone: phone ?? this.phone,
      chronicConditions: chronicConditions ?? this.chronicConditions,
      activeRegistered: activeRegistered ?? this.activeRegistered,
    );
  }
}
