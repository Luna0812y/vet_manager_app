import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PetService {
  final String baseUrl = 'https://vetmanager-cvof.onrender.com';

  // Buscar todos os pets
  Future<List> fetchPets() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString("token");

    if (token == null || token.isEmpty) {
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
      return [];
    }
  }

  // Deletar um pet
  Future<bool> deletePet(int petId) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString("token");

    if (token == null || token.isEmpty) {
      return false;
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/pets/$petId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    return response.statusCode == 200;
  }

  // Adicionar um novo pet
  Future<bool> addPet({
    required String name,
    required String breed,
    required String raca,
    required int altura,
    required double peso,
    required String sexo,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString("token");

    if (token == null || token.isEmpty) {
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
        'altura_pet': altura,
        'peso_pet': peso,
        'sexo_pet': sexo,
      }),
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }
}
