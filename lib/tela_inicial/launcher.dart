import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'dart:io';
import 'avaliar.dart';

class LauncherScreen extends StatefulWidget {
  @override
  _LauncherScreenState createState() => _LauncherScreenState();
}

class _LauncherScreenState extends State<LauncherScreen> {
  File? _selectedImage; // Armazena a imagem selecionada
  int _selectedIndex = 0; // Índice do item selecionado no BottomNavigationBar

  // Função para selecionar a imagem
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery); // Seleciona da galeria
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path); // Salva o caminho da imagem selecionada
      });
    }
  }

  // Função para mudar a tela conforme o item selecionado no BottomNavigationBar
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/launcher');
        break;
      case 1:
        Navigator.pushNamed(context, '/maps');  // Navega para o mapa
        break;
      case 2:
        Navigator.pushNamed(context, '/clinica');  // Tela do pet (criar essa tela se necessário)
        break;
      case 3:
        Navigator.pushNamed(context, '/user');  // Tela do perfil (criar essa tela se necessário)
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height; // Altura da tela

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 0,
        toolbarHeight: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Header (Meu Pet)
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.teal,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: _pickImage, // Permite anexar imagem ao clicar
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: _selectedImage != null
                            ? Image.file(
                                _selectedImage!, // Usando Image.file para arquivos de imagem
                                height: 120, // Tamanho fixo da imagem
                                width: 120, // Tamanho fixo da imagem
                                fit: BoxFit.cover,
                              )
                            : Container(
                                height: 120, // Tamanho fixo
                                width: 120, // Tamanho fixo
                                color: Colors.grey[300],
                                child: Icon(
                                  Icons.add_a_photo,
                                  color: Colors.grey[700],
                                ),
                              ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Meu Pet',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '12 minutes',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // Título "Clínicas mais bem avaliadas"
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Clínicas mais bem avaliadas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 8),

            // Lista de clínicas
            Container(
              height: screenHeight * 0.3, // Limita o tamanho da lista de clínicas
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16),
                children: [
                  ClinicCard(
                    name: 'VETERINARY CLINIC',
                    address: 'Rua das Acácias, 123 - Bairro Jardim Florido, São Paulo, SP',
                    image: 'assets/images/clinica1.jpg',
                    onTap: () {
                      // Navega para a tela de avaliação e passa os dados da clínica
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReviewScreen(
                            name: 'VETERINARY CLINIC',
                            address: 'Rua das Acácias, 123 - Bairro Jardim Florido, São Paulo, SP',
                            image: 'assets/images/clinica1.jpg', // Caminho correto para a imagem
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(width: 16),
                  ClinicCard(
                    name: 'VEININAY CLINIC',
                    address: 'Avenida Central, 456 - Bairro Belo Horizonte, Rio de Janeiro, RJ',
                    image: 'assets/images/clinica2.webp',
                    onTap: () {
                      // Navega para a tela de avaliação e passa os dados da clínica
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReviewScreen(
                            name: 'VEININAY CLINIC',
                            address: 'Avenida Central, 456 - Bairro Belo Horizonte, Rio de Janeiro, RJ',
                            image: 'assets/images/clinica2.webp',
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.shifting,
        currentIndex: _selectedIndex, // Atualiza a seleção
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Discover',
            backgroundColor: Colors.white,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Maps',
            backgroundColor: Colors.white,
          ),
          BottomNavigationBarItem(
            icon: Icon(Symbols.clinical_notes),
            label: 'Clinica',
            backgroundColor: Colors.white,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
            backgroundColor: Colors.white,
          ),
        ],
      ),
    );
  }
}

class ClinicCard extends StatelessWidget {
  final String name;
  final String address;
  final String image;
  final VoidCallback onTap;

  ClinicCard({
    required this.name,
    required this.address,
    required this.image,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            spreadRadius: 2,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: onTap, // Função de navegação para a tela de avaliação
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.asset(
                image,
                height: 120, // Tamanho fixo da imagem
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                address,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}