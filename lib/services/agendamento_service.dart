import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AgendamentoService {
  final String baseUrl =
      "https://vetmanager-cvof.onrender.com/agendamentos"; // Substitua pela URL da sua API

  // Pegar o token do usuário
  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  // Buscar todos os agendamentos
  Future<List<Map<String, dynamic>>> fetchAgendamentos() async {
    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        return [];
      }

      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            "Erro ao buscar agendamentos. Código: ${response.statusCode}");
      }
    } catch (e) {
      return [];
    }
  }

  // Detalhar um agendamento específico
  Future<List<Map<String, dynamic>>> detalharAgendamento(String id) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return [];
      }

      final response = await http.get(
        Uri.parse("$baseUrl/$id"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            "Erro ao buscar agendamento. Código: ${response.statusCode}");
      }
    } catch (e) {
      return [];
    }
  }

  // Cadastrar um novo agendamento
  Future<bool> criarAgendamento(Map<String, dynamic> agendamento) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return false;
      }

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
        body: jsonEncode(agendamento),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
