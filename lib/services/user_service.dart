import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:vet_manager/models/user.dart';

class UserService {
  static const String _baseUrl = 'http://192.168.11.9:3000/users';

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

  /// 🔹 **Faz login e salva o token + ID do usuário**
  Future<bool> loginUser({
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
        String token = data["token"];
        int userId = data["id_usuario"]; // Pegando o ID corretamente

        // 🔹 **Salvar o token e ID no SharedPreferences**
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", token);
        await prefs.setInt("userId", userId);

        return true;
      } else if (response.statusCode == 401) {
        throw Exception('Credenciais inválidas');
      } else {
        throw Exception('Erro ao realizar login');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }


  /// 🔹 **Busca os dados do usuário com o ID salvo**
  Future<User> fetchUserData([int? userId]) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? storedUserId = prefs.getInt("userId");

    userId ??= storedUserId; // Se userId for null, usa o armazenado

    if (userId == null) {
      throw Exception("Usuário não está logado.");
    }

    final response = await http.get(Uri.parse("$_baseUrl/$userId"));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return User.fromMap(data);
    } else {
      throw Exception("Erro ao buscar dados do usuário.");
    }
  }

  /// 🔹 **Retorna o ID do usuário salvo**
  Future<int?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt("userId");
  }
}
