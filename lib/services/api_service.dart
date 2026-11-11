import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/health_unit_model.dart';

/// Serviço de Consumo de WebService REST (Requisito 4)
/// Consome dados de unidades de saúde e teleatendimento comunitário via HTTP
class ApiService {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com/users';

  /// Realiza a requisição GET via pacote http e converte JSON em modelos Dart
  Future<List<HealthUnit>> getHealthUnits({bool forceError = false}) async {
    if (forceError) {
      await Future.delayed(const Duration(milliseconds: 700));
      throw Exception(
          'Erro de conexão: Servidor indisponível no momento ou falha de rede temporária.');
    }

    try {
      final response = await http
          .get(
            Uri.parse(baseUrl),
            headers: {
              'Accept': 'application/json',
              'User-Agent': 'SaudePerto-Flutter/1.0',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((jsonItem) => HealthUnit.fromJson(jsonItem)).toList();
      } else {
        throw Exception(
            'Falha na comunicação com a API REST: Código HTTP ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception(
          'Tempo limite excedido ao conectar com a central de unidades de saúde.');
    } catch (e) {
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Failed host lookup')) {
        throw Exception(
            'Sem conexão com a internet. Verifique sua rede e tente novamente.');
      }
      rethrow;
    }
  }
}
