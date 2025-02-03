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
}
