import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vet_manager/models/user.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class UserService {
  static const String _baseUrl = 'http://localhost:3000/users';

  Future<bool> registerUser({
    required String nomeUsuario,
    required String emailUsuario,
    required String senhaUsuario,
    required String cpfUsuario,
  }) async {
    final Map<String, dynamic> userData = {
      'nome_usuario': nomeUsuario,
      'email_usuario': emailUsuario,
      'senha_usuario': senhaUsuario,
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

        // 🔹 **Salvar apenas o token**
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", token);

        // 🔍 **Verifica se o token contém o ID**
        int? userId = await getUserIdFromToken();
        if (userId == null) {
          throw Exception("Token inválido: ID do usuário não encontrado.");
        }

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



Future<int?> getUserIdFromToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString("token");

  if (token == null) return null;

  Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    return decodedToken["id_usuario"]; // Certifique-se de que o campo correto está no payload
  } 



    /// 🔹 **Busca os dados do usuário com o ID salvo**
    Future<User> fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    if (token == null) {
      throw Exception("Usuário não está logado.");
    }

    int? userId = await getUserIdFromToken();
    if (userId == null) {
      throw Exception("ID do usuário não encontrado no token.");
    }

    final response = await http.get(
      Uri.parse("$_baseUrl/$userId"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return User.fromMap(data);
    } else {
      throw Exception("Erro ao buscar dados do usuário. Código: ${response.statusCode}");
    }
  }


 Future<bool> uploadProfilePicture(File imageFile) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    int? userId = prefs.getInt("userId");

    if (token == null || userId == null) {
      throw Exception("Usuário não está logado.");
    }

    var request = http.MultipartRequest(
      'POST',
      Uri.parse("$_baseUrl/$userId/uploadPhoto"),
    );

    request.headers['Authorization'] = "Bearer $token";
    request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    var response = await request.send();

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception("Erro ao enviar imagem: ${response.statusCode}");
    }
  }


  /// 🔹 **Retorna o ID do usuário salvo**
  Future<int?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt("userId");
  }
}
