import 'package:flutter/material.dart';
import 'package:vet_manager/screens/agendamento.dart';
import 'package:vet_manager/screens/clinicas.dart';
import 'package:vet_manager/screens/pets.dart';
import 'package:vet_manager/screens/profile_screen.dart';
import 'package:vet_manager/tela_inicial/avaliar.dart';
import 'package:vet_manager/services/clinica_service.dart';
import 'package:vet_manager/services/user_service.dart';
import 'package:vet_manager/widgets/clinica_card.dart';

class LauncherScreen extends StatefulWidget {
  @override
  _LauncherScreenState createState() => _LauncherScreenState();
}

class _LauncherScreenState extends State<LauncherScreen> {
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
      List<Map<String, dynamic>> clinicas =
          await _clinicaService.fetchClinics();
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
    try {
      int? userId = await _userService.getUserIdFromToken();
      if (userId != null) {
        setState(() {
          _userId = userId;
        });
      } else {
        throw Exception("ID do usuário não encontrado.");
      }
    } catch (e) {
      print("Erro ao obter ID do usuário: $e");
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
            context, MaterialPageRoute(builder: (context) => ClinicasScreen()));
        break;
      case 2:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => PetListScreen()));
        break;
      case 3:
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => AgendamentosScreen()));
        break;
      case 4:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => ProfileScreen()));
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
        child: Column(
          children: [
            // Banner de Cabeçalho
            Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/banner.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.7),
                ),
                child: Center(
                  child: Text(
                    'Bem-vindo ao Vet Manager',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            // Seção de Clínicas
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Clínicas mais bem avaliadas',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _errorMessage.isNotEmpty
                      ? Center(child: Text(_errorMessage))
                      : _clinicas.isEmpty
                          ? Center(child: Text("Nenhuma clínica encontrada."))
                          : GridView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.8,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                              itemCount: _clinicas.length,
                              itemBuilder: (context, index) {
                                final clinica = _clinicas[index];
                                return ClinicCard(
                                  name: clinica['nome_clinica'] ?? '',
                                  address: clinica['endereco_clinica'] ?? '',
                                  image:
                                      'assets/images/clinica${(index % 3) + 1}.jpg',
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ReviewScreen(
                                          name: clinica['nome_clinica'] ?? '',
                                          address:
                                              clinica['endereco_clinica'] ?? '',
                                          image:
                                              'assets/images/clinica${(index % 3) + 1}.jpg',
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
            ),
            SizedBox(height: 16),
            // Outras seções ou conteúdos podem ser adicionados aqui
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
            label: 'Descobrir',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Clínicas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pets),
            label: 'Pet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Agendamentos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
        onTap: _onItemTapped,
      ),
    );
  }
}
