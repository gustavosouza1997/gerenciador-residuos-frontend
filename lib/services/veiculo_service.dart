import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class VeiculoService {
  final String apiUrl = dotenv.env['API_URL'] ?? 'URL não definida';

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken') ?? '';

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Método para criar um veiculo
  Future<Map<String, dynamic>> createVeiculo(
      Map<String, dynamic> veiculoData) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$apiUrl/api/veiculo'),
      headers: headers,
      body: json.encode(veiculoData),
    );

    return _processResponse(response);
  }

  // Método para obter todos os veiculos
  Future<Map<String, dynamic>> getAllVeiculo() async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse('$apiUrl/api/veiculo/listar'),
        headers: headers);

    return _processResponse(response);
  }

  // Método para atualizar um veiculo
  Future<Map<String, dynamic>> updateVeiculo(
      String id, Map<String, dynamic> updatedData) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$apiUrl/api/veiculo/$id'),
      headers: headers,
      body: json.encode(updatedData),
    );

    return _processResponse(response);
  }

  // Método para excluir um veiculo
  Future<Map<String, dynamic>> deleteVeiculo(String id) async {
    final headers = await _getHeaders();
    final response = await http.delete(Uri.parse('$apiUrl/api/veiculo/$id'),
        headers: headers);

    return _processResponse(response);
  }

  // Função para processar as respostas das requisições
  Map<String, dynamic> _processResponse(http.Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      if (response.body.isEmpty) {
        return {'error': 'Sucesso'};
      }
      try {
        final decodedResponse = json.decode(response.body);

        if (decodedResponse is List) {
          return {'veiculos': decodedResponse};
        } else if (decodedResponse is Map<String, dynamic>) {
          return decodedResponse;
        } else {
          return {'error': 'Resposta inesperada do servidor'};
        }
      } catch (e) {
        return {'error': 'Erro ao decodificar JSON: $e'};
      }
    } else {
      return {
        'error': 'Erro ao processar a requisição: ${response.statusCode}'
      };
    }
  }
}