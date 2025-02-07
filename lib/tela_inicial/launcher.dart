import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vet_manager/screens/clinicas.dart';
import 'package:vet_manager/screens/profile_screen.dart';
import 'package:vet_manager/widgets/clinica_card.dart';
import 'package:vet_manager/services/clinica_service.dart';
import 'package:vet_manager/services/user_service.dart';
import 'dart:io';
import 'avaliar.dart';

class LauncherScreen extends StatefulWidget {
  @override
  _LauncherScreenState createState() => _LauncherScreenState();
}

class _LauncherScreenState extends State<LauncherScreen> {
  File? _selectedImage;
  int _selectedIndex = 0;
  final ClinicaService _clinicaService = ClinicaService();
  final UserService _userService = UserService();
  List<Map<String, dynamic>> _clinicas = [];
  bool _isLoading = true;
  String _errorMessage = "";
  int? _userId; 

  @override
  void initState() {
    super.initState();
    _loadClinicas();
    _loadUserId();
  }

  Future<void> _loadClinicas() async {
    try {
      List<Map<String, dynamic>> clinicas = await _clinicaService.fetchClinics();
      setState(() {
        _clinicas = clinicas;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Erro ao carregar clínicas.";
        _isLoading = false;
      });
    }
  }

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt("userId");
    });
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/launcher');
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ClinicasScreen()),
        );
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/pet');
        break;
      case 3:
        if (_userId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfileScreen(),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Erro ao carregar perfil do usuário.")),
          );
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

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
                      onTap: _pickImage,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: _selectedImage != null
                            ? Image.file(
                                _selectedImage!,
                                height: 120,
                                width: 120,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                height: 120,
                                width: 120,
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

            // Exibição dinâmica das clínicas
            Container(
              height: screenHeight * 0.3,
              child: _isLoading
                  ? Center(child: CircularProgressIndicator()) // Mostra um indicador de carregamento
                  : _errorMessage.isNotEmpty
                      ? Center(child: Text(_errorMessage)) // Exibe erro caso ocorra
                      : _clinicas.isEmpty
                          ? Center(child: Text("Nenhuma clínica encontrada."))
                          : ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              itemCount: _clinicas.length,
                              itemBuilder: (context, index) {
                                final clinica = _clinicas[index];
                                return Padding(
                                  padding: EdgeInsets.only(right: 16),
                                  child: ClinicCard(
                                    name: clinica['nome_clinica'],
                                    address: clinica['endereco_clinica'],
                                    image: 'assets/images/clinica1.jpg',
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ReviewScreen(
                                            name: clinica['nome_clinica'],
                                            address: clinica['endereco_clinica'],
                                            image: 'assets/images/clinica1.jpg',
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Discover',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Clinics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pets),
            label: 'Pet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        onTap: _onItemTapped,
      ),
    );
  }
}
