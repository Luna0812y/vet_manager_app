import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vet_manager/screens/login.dart';

import '../../models/user.dart';
import '../../services/user_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<User> _userFuture;
  final UserService _userService = UserService();
  File? _image;

  @override
  void initState() {
    super.initState();
    _userFuture = _loadUserData(); // 🔹 Inicializa o Future corretamente
  }

  Future<User> _loadUserData() async {
    try {
      return await _userService
          .fetchUserData(); // 🔹 Agora busca o usuário autenticado via /me
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro ao carregar perfil: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
      rethrow;
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });

      try {
        await _userService.uploadProfilePicture(_image!);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Imagem enviada com sucesso!"),
          backgroundColor: Colors.green,
        ));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Erro ao enviar imagem"),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  /// Função para fazer logout
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Remove os dados do usuário armazenados

    // Redireciona para a tela de login
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Perfil do Usuário"),
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<User>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("Erro ao carregar dados do usuário."));
          } else if (!snapshot.hasData) {
            return const Center(child: Text("Usuário não encontrado."));
          }

          final user = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _image != null
                    ? CircleAvatar(
                        radius: 50,
                        backgroundImage: FileImage(_image!),
                      )
                    : const Icon(Icons.account_circle, size: 100, color: Colors.teal),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: const Text("Alterar Foto"),
                ),
                const SizedBox(height: 20),
                _buildInfoRow("Nome", user.name),
                _buildInfoRow("Email", user.email),
                _buildInfoRow("CPF", user.cpf),
                const Spacer(), // Empurra o botão de logout para o final da tela
                ElevatedButton.icon(
                  onPressed: _logout,
                  icon: const Icon(
                    Icons.logout,
                    color: Colors.white,
                  ),
                  label: const Text("Sair"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$label:",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
