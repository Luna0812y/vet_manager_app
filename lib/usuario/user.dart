import 'package:material_symbols_icons/symbols.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class UserProfileScreen extends StatefulWidget {
  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  File? _profileImage; // Armazena a imagem do perfil
  int _currentIndex = 3; // Define o índice inicial para a aba do perfil

  // Método para selecionar uma imagem
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery); // Pode mudar para .camera

    if (pickedFile != null) {
      print('Imagem selecionada: ${pickedFile.path}'); // Log do caminho da imagem selecionada

      setState(() {
        _profileImage = File(pickedFile.path); // Atualiza a variável com a imagem selecionada
      });
    } else {
      print("Nenhuma imagem foi selecionada.");
    }
  }

  void _onItemTapped(int index) {
    if (index != _currentIndex) return; // Evita recarregar a tela atual

    setState(() {
      _currentIndex = index; // Atualiza o índice atual antes da navegação
    });

    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/launcher');
        break;
      case 1:
        Navigator.pushNamed(context, '/maps');
        break;
      case 2:
        Navigator.pushNamed(context, '/clinica');
        break;
      case 3:
        Navigator.pushNamed(context, '/user');
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text('Perfil do Usuário'),
        automaticallyImplyLeading: false, // Remove a seta de voltar
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            // Foto de perfil com botão para adicionar/alterar
            Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 70,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: _profileImage != null
                      ? FileImage(_profileImage!) // Exibe a imagem escolhida
                      : null,
                  child: _profileImage == null
                      ? const Icon(Icons.person, size: 60, color: Colors.white)
                      : null, // Mostra ícone apenas se não houver imagem
                ),
                Positioned(
                  bottom: 0,
                  child: GestureDetector(
                    onTap: _pickImage, // Abre o seletor de imagens
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.teal,
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'Nome do Usuário',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Mãe de Pet',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 20),
            TextButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/cadastro_pet');
              },
              icon: Icon(Icons.add, color: Colors.teal),
              label: Text(
                'Adicione um PET',
                style: TextStyle(color: Colors.teal),
              ),
            ),
            Divider(height: 30, thickness: 1),
            _buildProfileOption(Icons.person, 'Edite seu perfil'),
            _buildProfileOption(Icons.star, 'Renovar planos'),
            _buildProfileOption(Icons.settings, 'Configurações'),
            _buildProfileOption(Icons.policy, 'Termos e Política de Privacidade'),
            _buildProfileOption(Icons.exit_to_app, 'Sair'),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Atualiza o índice atual
          });
          _onItemTapped(index);
        },
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Discover',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Maps',
          ),
          BottomNavigationBarItem(
            icon: Icon(Symbols.clinical_notes),
            label: 'Clinica',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption(IconData icon, String text) {
    return ListTile(
      leading: Icon(icon, color: Colors.orange),
      title: Text(text),
      onTap: () {
        // Ação ao clicar na opção
      },
    );
  }
}


