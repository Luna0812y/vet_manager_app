import 'package:flutter/material.dart';
import 'package:vet_manager/services/agendamento_service.dart';
import 'package:vet_manager/services/pet_service.dart';
import 'package:vet_manager/services/user_service.dart';
import 'criar_agendamento_screen.dart';

class AgendamentosScreen extends StatefulWidget {
  @override
  _AgendamentosScreenState createState() => _AgendamentosScreenState();
}

class _AgendamentosScreenState extends State<AgendamentosScreen> {
  final AgendamentoService _agendamentoService = AgendamentoService();
  final UserService _userService = UserService();
  final PetService _petService = PetService();

  List<Map<String, dynamic>> _agendamentos = [];
  late List _pets = [];
  Map<String, dynamic>? _selectedPet;

  bool _isLoading = true;
  String _errorMessage = "";
  int? _userId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      _userId = await _userService.getUserIdFromToken();
      if (_userId == null) throw Exception("ID do usuário não encontrado.");

      // Carrega agendamentos e pets simultaneamente
      await Future.wait([
        _loadAgendamentos(),
        _loadPets(),
      ]);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Erro ao carregar dados.";
        _isLoading = false;
      });
    }
  }

  Future<void> _loadAgendamentos() async {
    List<Map<String, dynamic>> agendamentos =
        await _agendamentoService.fetchAgendamentos(_userId!);
    setState(() {
      _agendamentos = agendamentos;
    });
  }

  Future<void> _loadPets() async {
    List pets = await _petService.fetchPets();
    setState(() {
      _pets = pets;
      if (_pets.isNotEmpty) {
        _selectedPet = _pets[0]; // Seleciona o primeiro pet por padrão
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Consultas Agendadas"),
        backgroundColor: Colors.teal,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : Column(
                  children: [
                    // Dropdown para seleção do pet
                    if (_pets.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: DropdownButtonFormField<Map<String, dynamic>>(
                          decoration: InputDecoration(
                            labelText: 'Selecione o Pet',
                            border: OutlineInputBorder(),
                          ),
                          value: _selectedPet,
                          onChanged: (Map<String, dynamic>? newValue) {
                            setState(() {
                              _selectedPet = newValue;
                            });
                          },
                          items: _pets.map((pet) {
                            return DropdownMenuItem<Map<String, dynamic>>(
                              value: pet,
                              child: Text(pet['nome_pet']),
                            );
                          }).toList(),
                        ),
                      ),
                    Expanded(
                      child: _agendamentos.isEmpty
                          ? Center(child: Text("Nenhuma consulta encontrada."))
                          : ListView.builder(
                              itemCount: _agendamentos.length,
                              itemBuilder: (context, index) {
                                final agendamento = _agendamentos[index];
                                return Card(
                                  child: ListTile(
                                    leading: Icon(Icons.calendar_today,
                                        color: Colors.teal),
                                    title: Text(
                                        "Data: ${agendamento['data_agendamento']}"),
                                    subtitle: Text(
                                        "Horário: ${agendamento['horario_agendamento']}"),
                                    trailing: Text(
                                      agendamento['status_agendamento'],
                                      style: TextStyle(
                                        color:
                                            agendamento['status_agendamento'] ==
                                                    "AGENDADO"
                                                ? Colors.green
                                                : Colors.red,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_selectedPet == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Por favor, selecione um pet.")),
            );
            return;
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CriarAgendamentoScreen(pet: _selectedPet!),
            ),
          ).then((_) => _loadAgendamentos()); // Atualiza a lista ao voltar
        },
        backgroundColor: Colors.teal,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
