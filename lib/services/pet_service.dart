import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PetService {
  final String baseUrl = 'https://vetmanager-cvof.onrender.com';

  Future<List> fetchPets() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString("token");

    if (token == null || token.isEmpty) {
      print("Token inválido. Por favor, faça login novamente.");
      return [];
    }

    final response = await http.get(
      Uri.parse('$baseUrl/pets'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print("Falha ao carregar pets: ${response.statusCode}");
      return [];
    }
  }

  Future<bool> deletePet(int petId) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString("token");

    if (token == null || token.isEmpty) {
      print("Token inválido. Por favor, faça login novamente.");
      return false;
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/pets/$petId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      print("Pet deletado com sucesso!");
      return true;
    } else {
      print("Falha ao deletar pet: ${response.body}");
      return false;
    }
  }

  Future<bool> addPet({
    required String name,
    required String breed,
    required String raca,
    required int altura, // Agora int
    required double peso, // Agora double
    required String sexo,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString("token");

    if (token == null || token.isEmpty) {
      print("Token inválido. Por favor, faça login novamente.");
      return false;
    }

    final response = await http.post(
      Uri.parse('$baseUrl/pets'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'nome_pet': name,
        'especie_pet': breed,
        'raca_pet': raca,
        'altura_pet': altura, // Enviando como número
        'peso_pet': peso, // Enviando como número
        'sexo_pet': sexo, // 'M' ou 'F'
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Pet adicionado com sucesso!");
      return true;
    } else {
      print("Falha ao adicionar pet: ${response.body}");
      return false;
    }
  }
}
