import 'package:flutter/material.dart';
import 'package:vet_manager/services/agendamento_service.dart';
import 'package:vet_manager/services/user_service.dart';
import 'criar_agendamento_screen.dart'; // Import da tela de criação de agendamento

class AgendamentosScreen extends StatefulWidget {
  @override
  _AgendamentosScreenState createState() => _AgendamentosScreenState();
}

class _AgendamentosScreenState extends State<AgendamentosScreen> {
  final AgendamentoService _agendamentoService = AgendamentoService();
  final UserService _userService = UserService();
  List<Map<String, dynamic>> _agendamentos = [];
  bool _isLoading = true;
  String _errorMessage = "";
  int? _userId;

  @override
  void initState() {
    super.initState();
    _loadAgendamentos();
  }

  Future<void> _loadAgendamentos() async {
    try {
      int? userId = await _userService.getUserIdFromToken();
      if (userId == null) throw Exception("ID do usuário não encontrado.");

      List<Map<String, dynamic>> agendamentos =
          await _agendamentoService.fetchAgendamentos(userId);

      setState(() {
        _agendamentos = agendamentos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Erro ao carregar agendamentos.";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Consultas Agendadas"), backgroundColor: Colors.teal),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : _agendamentos.isEmpty
                  ? Center(child: Text("Nenhuma consulta encontrada."))
                  : ListView.builder(
                      itemCount: _agendamentos.length,
                      itemBuilder: (context, index) {
                        final agendamento = _agendamentos[index];
                        return Card(
                          child: ListTile(
                            leading: Icon(Icons.calendar_today, color: Colors.teal),
                            title: Text("Data: ${agendamento['data_agendamento']}"),
                            subtitle: Text("Horário: ${agendamento['horario_agendamento']}"),
                            trailing: Text(
                              agendamento['status_agendamento'],
                              style: TextStyle(
                                color: agendamento['status_agendamento'] == "AGENDADO"
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CriarAgendamentoScreen()),
          ).then((_) => _loadAgendamentos()); // Atualiza a lista ao voltar
        },
        backgroundColor: Colors.teal,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
