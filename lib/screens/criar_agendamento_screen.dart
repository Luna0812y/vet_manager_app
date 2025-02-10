import 'package:flutter/material.dart';
import 'package:vet_manager/services/agendamento_service.dart';
import 'package:vet_manager/services/user_service.dart';

class CriarAgendamentoScreen extends StatefulWidget {
  @override
  _CriarAgendamentoScreenState createState() => _CriarAgendamentoScreenState();
}

class _CriarAgendamentoScreenState extends State<CriarAgendamentoScreen> {
  final AgendamentoService _agendamentoService = AgendamentoService();
  final UserService _userService = UserService();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  final TextEditingController _petIdController = TextEditingController();
  final TextEditingController _clinicaIdController = TextEditingController();
  final TextEditingController _tipoServicoController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate)
      setState(() => _selectedDate = picked);
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime)
      setState(() => _selectedTime = picked);
  }

  Future<void> _criarAgendamento() async {
    int? userId = await _userService.getUserIdFromToken();
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao obter ID do usuário.")),
      );
      return;
    }

    final Map<String, dynamic> agendamento = {
      "data_agendamento": "${_selectedDate.toIso8601String()}",
      "horario_agendamento": "${_selectedTime.format(context)}",
      "status_agendamento": "AGENDADO",
      "id_tipo_servico": int.parse(_tipoServicoController.text),
      "id_pet": int.parse(_petIdController.text),
      "id_clinica": int.parse(_clinicaIdController.text),
    };

    bool sucesso = await _agendamentoService.criarAgendamento(agendamento);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(sucesso ? "Consulta agendada!" : "Erro ao agendar.")),
    );

    if (sucesso) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Novo Agendamento"), backgroundColor: Colors.teal),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _petIdController, decoration: InputDecoration(labelText: "ID do Pet")),
            TextField(controller: _clinicaIdController, decoration: InputDecoration(labelText: "ID da Clínica")),
            TextField(controller: _tipoServicoController, decoration: InputDecoration(labelText: "Tipo de Serviço")),
            ElevatedButton(onPressed: () => _selectDate(context), child: Text("Selecionar Data")),
            ElevatedButton(onPressed: () => _selectTime(context), child: Text("Selecionar Hora")),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _criarAgendamento, child: Text("Agendar Consulta")),
          ],
        ),
      ),
    );
  }
}
