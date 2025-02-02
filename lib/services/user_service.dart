import 'dart:convert';
import 'package:http/http.dart' as http;

class UserService {
  static const String _baseUrl = 'http://localhost:3000'; 

  // Função para registrar o usuário
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
      'cpf_usuario': cpfUsuario,
    };

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/cadastro'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(userData),
      );

      // Verifica o status da resposta
      if (response.statusCode == 201) {
        return true; // Cadastro bem-sucedido
      } else {
        throw Exception('Falha ao cadastrar usuário');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }
}
