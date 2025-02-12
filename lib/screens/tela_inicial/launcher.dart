import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:vet_manager/screens/agendamento.dart';
import 'package:vet_manager/screens/mapa.dart';
import 'package:vet_manager/screens/pets/lista_pets.dart';
import 'package:vet_manager/screens/user/profile_screen.dart';
import 'package:vet_manager/services/clinica_service.dart';
import 'package:vet_manager/services/user_service.dart';
import 'package:vet_manager/screens/tela_inicial/avaliar.dart';
import 'package:vet_manager/screens/tela_inicial/clinica_card.dart';

// Tela inicial principal
class LauncherScreen extends StatefulWidget {
  const LauncherScreen({super.key});

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

  @override
  void initState() {
    super.initState();
    _loadClinicas();
  }

  // Busca dados das clínicas através do service
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

  // Gerencia a seleção de itens na barra de navegação inferior
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
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const ProfileScreen()));
        break;
    }
  }

  // Método principal de construção da interface
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeaderBanner(),
            const SizedBox(height: 16),
            _buildClinicasSection(),
            const SizedBox(height: 24),
            _buildServicesSection(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // Constrói a barra superior
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.teal,
      elevation: 0,
      toolbarHeight: 0,
    );
  }

  // Banner de boas-vindas com imagem de fundo
  Widget _buildHeaderBanner() {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/banner.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.teal.withOpacity(0.7),
        ),
        child: const Center(
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
    );
  }

  // Seção do carrossel de clínicas
  Widget _buildClinicasSection() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
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
        const SizedBox(height: 8),
        _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage.isNotEmpty
                ? Center(child: Text(_errorMessage))
                : _clinicas.isEmpty
                    ? const Center(child: Text("Nenhuma clínica encontrada."))
                    : CarouselSlider(
                        options: CarouselOptions(
                          height: 250,
                          enlargeCenterPage: true,
                          enableInfiniteScroll: false,
                        ),
                        items: _clinicas.map((clinica) {
                          int index = _clinicas.indexOf(clinica);
                          return Builder(
                            builder: (BuildContext context) {
                              return ClinicaCard(
                                name: clinica['nome_clinica'] ?? '',
                                address:
                                    clinica['localizacao']['endereco'] ?? '',

                                rating: clinica['avaliacao_clinica'] ??
                                    0, // Nova propriedade
                                image:
                                    'assets/images/clinica${(index % 3) + 1}.png',
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ReviewScreen(
                                        name: clinica['nome_clinica'] ?? '',
                                        address: clinica['localizacao']
                                                ['endereco'] ??
                                            '',
                                        image:
                                            'assets/images/clinica${(index % 3) + 1}.png',
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        }).toList(),
                      ),
      ],
    );
  }

  // Informações dos serviços
  Widget _buildServicesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nossos Serviços',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildServiceCards(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildServiceCards() {
    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            icon: Icons.calendar_month,
            title: 'Agendamento Fácil',
            description: 'Marque consultas com poucos cliques',
            color: Colors.teal.shade100,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildInfoCard(
            icon: Icons.pets,
            title: 'Perfil do Pet',
            description: 'Histórico e informações do seu pet',
            color: Colors.teal.shade100,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      color: color,
      child: Container(
        height: 120,
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: Colors.teal),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              description,
              style: const TextStyle(fontSize: 11),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // Barra de navegação inferior
  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
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
    );
  }
}
