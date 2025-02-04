import 'dart:convert';
import 'package:http/http.dart' as http;

class ClinicaService {
  static const String baseUrl = "http://192.168.11.9:3000/";

  Future<List<Map<String, dynamic>>> fetchClinics() async {
    final response = await http.get(Uri.parse("$baseUrl/clinicas"));

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception("Erro ao carregar clínicas");
    }
  }

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
