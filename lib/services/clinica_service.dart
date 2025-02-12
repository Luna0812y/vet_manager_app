import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ClinicaService {
  static const String baseUrl = "https://vetmanager-cvof.onrender.com";
  String? token;

  // Buscar todas as clínicas
  Future<List<Map<String, dynamic>>> fetchClinics() async {
    token = await getToken();
    String url = "$baseUrl/clinicas";

    final response = await http.get(
      Uri.parse(url),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception("Erro ao carregar clínicas");
    }
  }

  // Pegar o token do usuário
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token"); // Retorna null se não existir
  }

  // Cadastrar uma clínica
  Future<void> cadastrarClinica(Map<String, dynamic> clinica) async {
    final response = await http.post(
      Uri.parse("$baseUrl/clinicas"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(clinica),
    );

    if (response.statusCode != 201) {
      throw Exception("Erro ao cadastrar clínica");
    }
  }
}
