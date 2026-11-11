/// Modelo de Unidade Básica / Posto Avançado de Saúde (Requisito 4 - Consumo WebService)
class HealthUnit {
  final int id;
  final String name;
  final String type; // UBS, Teleposto Comunitário, Hospital Regional
  final String address;
  final String city;
  final String state;
  final String phone;
  final String email;
  final double distanceKm;
  final bool isOpen24h;
  final int availableDoctors;
  final double rating;
  final String imageUrl;

  const HealthUnit({
    required this.id,
    required this.name,
    required this.type,
    required this.address,
    required this.city,
    required this.state,
    required this.phone,
    required this.email,
    required this.distanceKm,
    required this.isOpen24h,
    required this.availableDoctors,
    required this.rating,
    required this.imageUrl,
  });

  /// Construtor a partir do JSON recebido da API REST (Requisito 4)
  factory HealthUnit.fromJson(Map<String, dynamic> json) {
    // Tratamento resiliente de JSON proveniente de WebService REST
    final addressMap = json['address'] as Map<String, dynamic>?;
    final companyMap = json['company'] as Map<String, dynamic>?;

    final id = json['id'] as int? ?? 1;
    final name = json['name'] as String? ?? 'Posto de Saúde Comunitário';
    final city = addressMap?['city'] as String? ?? json['city'] as String? ?? 'Região Metropolitana';
    final street = addressMap?['street'] as String? ?? json['address'] as String? ?? 'Rua da Saúde, s/n';
    final suite = addressMap?['suite'] as String? ?? '';
    final fullAddress = suite.isNotEmpty ? '$street, $suite' : street;
    final phone = json['phone'] as String? ?? '(11) 3000-0100';
    final email = json['email'] as String? ?? 'contato@saudeperto.gov.br';

    // Gera atributos comunitários baseados no ID da API
    final types = [
      'UBS Fluvial & Ribeirinha',
      'Teleposto Comunitário Remoto',
      'Unidade Básica de Saúde (UBS)',
      'Centro de Triagem Periférica',
      'Ponto de Apoio Indígena e Rural',
      'Hospital Regional de Referência',
    ];
    final selectedType = types[id % types.length];

    final distance = ((id * 3.7) % 28.0) + 1.2;
    final is24h = id % 3 == 0;
    final doctors = (id % 5) + 1;
    final rating = 4.2 + ((id % 8) * 0.1);

    // Image URL via Picsum / Unsplash healthcare or placeholder
    final imageUrl = 'https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?w=400&auto=format&fit=crop&q=60';

    return HealthUnit(
      id: id,
      name: companyMap != null ? 'Unidade ${companyMap['name']}' : name,
      type: selectedType,
      address: fullAddress,
      city: city,
      state: 'SP / AM',
      phone: phone,
      email: email,
      distanceKm: double.parse(distance.toStringAsFixed(1)),
      isOpen24h: is24h,
      availableDoctors: doctors,
      rating: double.parse(rating.toStringAsFixed(1)),
      imageUrl: imageUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'address': address,
      'city': city,
      'state': state,
      'phone': phone,
      'email': email,
      'distanceKm': distanceKm,
      'isOpen24h': isOpen24h,
      'availableDoctors': availableDoctors,
      'rating': rating,
      'imageUrl': imageUrl,
    };
  }
}
