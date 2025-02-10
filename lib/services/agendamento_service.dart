import 'dart:convert';
import 'package:http/http.dart' as http;

class AgendamentoService {
  final String baseUrl = "https://vetmanager-cvof.onrender.com/agendamentos"; // Substitua pela URL da sua API

    Future<List<Map<String, dynamic>>> fetchAgendamentos(int userId) async {
    final url = Uri.parse("$baseUrl/?user_id=$userId");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);
        return jsonData.cast<Map<String, dynamic>>();
      } else {
        throw Exception("Erro ao buscar agendamentos. Código: ${response.statusCode}");
      }
    } catch (e) {
      print("Erro: $e");
      return [];
    }
  }

  /// 🔹 Cadastrar um novo agendamento
  Future<bool> criarAgendamento(Map<String, dynamic> agendamento) async {
    final url = Uri.parse("$baseUrl");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(agendamento),
      );

      if (response.statusCode == 201) {
        return true; // Sucesso ao criar
      } else {
        print("Erro ao criar agendamento: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Erro ao enviar requisição: $e");
      return false;
    }
  }
}
