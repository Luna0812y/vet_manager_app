import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vet_manager/models/user.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'dart:convert';
import 'dart:io';

class UserService {
  static const String _baseUrl = 'https://vetmanager-cvof.onrender.com/users';

  // Cadastrar um novo usuário
  Future<bool> registerUser({
    required String nomeUsuario,
    required String emailUsuario,
    required String senhaUsuario,
    required String cpfUsuario,
  }) async {
    final Map<String, dynamic> userData = {
      'nome_usuario': nomeUsuario.trim(),
      'email_usuario': emailUsuario.trim().toLowerCase(),
      'senha_usuario': senhaUsuario,
      'foto_usuario': "string",
      'cpf': cpfUsuario.replaceAll(RegExp(r'[^\d]'), ''),
    };

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/cadastro'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(userData),
      );

      if (response.statusCode == 201) {
        return true;
      } else if (response.statusCode == 409) {
        throw Exception('Usuário já existe');
      } else if (response.statusCode == 400) {
        throw Exception('Dados inválidos: ${response.body}');
      } else {
        throw Exception('Erro ao cadastrar usuário: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erro ao registrar usuário: $e');
    }
  }

  // Fazer login e salvar o token
  Future<bool> loginUser({
    required String email,
    required String senha,
  }) async {
    final Map<String, dynamic> loginData = {
      'email_usuario': email,
      'senha_usuario': senha,
    };

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(loginData),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        String? token = data["token"];

        if (token == null || token.isEmpty) {
          throw Exception("Token inválido: token não encontrado.");
        }

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", token);

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

  // Pegar o ID do usuário a partir do token salvo
  Future<int?> getUserIdFromToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    if (token == null) {
      return null;
    }

    try {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      int? userId = decodedToken["id"];

      if (userId == null) {
        return null;
      }

      return userId;
    } catch (e) {
      return null;
    }
  }

  // Buscar os dados do usuário
  Future<User> fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    if (token == null) {
      throw Exception("Usuário não está logado.");
    }

    final response = await http.get(
      Uri.parse("$_baseUrl/me"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return User.fromMap(data);
    } else {
      throw Exception(
          "Erro ao buscar dados do usuário. Código: ${response.statusCode}");
    }
  }

  // Fazer upload da foto de perfil do usuário
  Future<bool> uploadProfilePicture(File imageFile) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    if (token == null) {
      throw Exception("Usuário não está logado.");
    }

    int? userId = await getUserIdFromToken();
    if (userId == null) {
      throw Exception("ID do usuário não encontrado no token.");
    }

    var request = http.MultipartRequest(
      'POST',
      Uri.parse("$_baseUrl/$userId/uploadPhoto"),
    );

    request.headers['Authorization'] = "Bearer $token";
    request.files
        .add(await http.MultipartFile.fromPath('file', imageFile.path));

    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception(
            "Erro ao enviar imagem. Código: ${response.statusCode}, Mensagem: ${response.body}");
      }
    } catch (e) {
      throw Exception("Erro durante o upload da imagem: $e");
    }
  }

  // Pegar o ID do usuário
  Future<int?> getUserId() async {
    return getUserIdFromToken();
  }
}
