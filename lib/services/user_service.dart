import 'dart:convert';
import 'package:http/http.dart' as http;

class UserService {
  static const String _baseUrl = 'http://192.168.11.9:3000/users'; // Android Emulator

  Future<bool> registerUser({
    required String nomeUsuario,
    required String emailUsuario,
    required String senhaUsuario,
    required String cpfUsuario,
  }) async {
    final Map<String, dynamic> userData = {
      'name': nomeUsuario,
      'email': emailUsuario,
      'password': senhaUsuario,
      'cpf': cpfUsuario,
    };

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/cadastro'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(userData),
      );

      if (response.statusCode == 201) {
        return true;
      } else if (response.statusCode == 409) {
        throw Exception('Usuário já existe');
      } else if (response.statusCode == 400) {
        throw Exception('Dados de entrada inválidos');
      } else {
        throw Exception('Erro ao cadastrar usuário');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  Future<String?> loginUser({
    required String email,
    required String senha,

  }) async {
    final Map<String, dynamic> loginData = {
      'email': email,
      'password': senha,
    };

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(loginData),
        
        );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data["token"]; // Retorna o token JWT
      } else if (response.statusCode == 401) {
        throw Exception('Credenciais inválidas');
      } else {
        throw Exception('Erro ao realizar login');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
    
  }
}
