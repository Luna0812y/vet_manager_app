import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:vet_manager/services/clinica_service.dart';
import 'package:vet_manager/services/user_service.dart';

class CriarAgendamentoScreen extends StatefulWidget {
  final Map<String, dynamic> pet;

  CriarAgendamentoScreen({required this.pet});

  @override
  _CriarAgendamentoScreenState createState() => _CriarAgendamentoScreenState();
}

class _CriarAgendamentoScreenState extends State<CriarAgendamentoScreen> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isLoading = false;
  String _errorMessage = "";

  final ClinicaService clinicService = ClinicaService();
  final UserService _userService = UserService();

  List<Map<String, dynamic>> _clinicas = [];
  Map<String, dynamic>? _clinicaSelecionada;

  int? _userId;
  String? _token;

  List<Map<String, dynamic>> _agendamentos = [];
  bool _isLoadingAgendamentos = false;

  @override
  void initState() {
    super.initState();
    _loadClinicas();
    _loadUserId();
    _loadToken();
    _fetchAgendamentos();
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

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString("token");
    if (token != null && token.isNotEmpty) {
      setState(() {
        _token = token;
      });
    } else {
      print("Token inválido. Por favor, faça login novamente.");
    }
  }

  Future<void> _loadClinicas() async {
    try {
      List<Map<String, dynamic>> clinicas = await clinicService.fetchClinics();
      setState(() {
        _clinicas = clinicas;
        if (_clinicas.isNotEmpty) {
          _clinicaSelecionada =
              _clinicas[0]; // Seleciona a primeira clínica por padrão
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Erro ao carregar clínicas.";
      });
    }
  }

  Future<void> _createAgendamento() async {
    if (_selectedDate == null || _selectedTime == null) {
      setState(() {
        _errorMessage = "Por favor, selecione data e horário.";
      });
      return;
    }

    if (_clinicaSelecionada == null) {
      setState(() {
        _errorMessage = "Por favor, selecione uma clínica.";
      });
      return;
    }

    if (_userId == null) {
      setState(() {
        _errorMessage = "Usuário não identificado.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });

    try {
      // Prepara a data e hora
      final DateTime agendamentoDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      // Formata a data e horário
      String dataAgendamento = agendamentoDateTime.toIso8601String();
      String horarioAgendamento =
          "${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}";

      // URL da API
      final String apiUrl = 'https://vetmanager-cvof.onrender.com/agendamentos';

      // Corpo da requisição
      final Map<String, dynamic> requestBody = {
        'data_agendamento': dataAgendamento,
        'horario_agendamento': horarioAgendamento,
        'status_agendamento': 'AGENDADO',
        'id_tipo_servico': 1, // Substitua com o ID real, se necessário
        'id_pet': widget.pet['id_pet'],
        'id_clinica': _clinicaSelecionada?['id_clinica'],
      };

      if (_token == null || _token!.isEmpty) {
        print("Token inválido. Por favor, faça login novamente.");
        return;
      }

      // Cabeçalhos da requisição
      final Map<String, String> headers = {
        "Content-Type": "application/json",
        "Authorization": "Bearer $_token"
      };

      // Faz a requisição POST
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Atualiza a lista de agendamentos
        _fetchAgendamentos();

        // Exibe mensagem de sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Agendamento criado com sucesso!")),
        );
      } else {
        setState(() {
          _errorMessage =
              "Erro ao criar agendamento. Verifique os dados e tente novamente.";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage =
            "Erro ao criar agendamento. Tente novamente mais tarde.";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchAgendamentos() async {
    setState(() {
      _isLoadingAgendamentos = true;
    });

    try {
      if (_token == null || _token!.isEmpty) {
        print("Token inválido. Por favor, faça login novamente.");
        return;
      }

      // URL da API
      final String apiUrl = 'https://vetmanager-cvof.onrender.com/agendamentos';

      // Cabeçalhos da requisição
      final Map<String, String> headers = {
        "Content-Type": "application/json",
        "Authorization": "Bearer $_token"
      };

      // Faz a requisição GET
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: headers,
      );

      if (response.statusCode == 200) {
        List<dynamic> agendamentosJson = json.decode(response.body);

        setState(() {
          _agendamentos = agendamentosJson
              .map((agendamento) => agendamento as Map<String, dynamic>)
              .toList();
        });
      } else {
        setState(() {
          _errorMessage =
              "Erro ao carregar agendamentos. Tente novamente mais tarde.";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage =
            "Erro ao carregar agendamentos. Tente novamente mais tarde.";
      });
    } finally {
      setState(() {
        _isLoadingAgendamentos = false;
      });
    }
  }

  // Métodos para selecionar data e hora
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (pickedDate != null)
      setState(() {
        _selectedDate = pickedDate;
      });
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (pickedTime != null)
      setState(() {
        _selectedTime = pickedTime;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Nova Consulta"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "Pet Selecionado: ${widget.pet['nome_pet']}",
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            // Dropdown para seleção da clínica
            if (_clinicas.isNotEmpty)
              DropdownButtonFormField<Map<String, dynamic>>(
                decoration: InputDecoration(
                  labelText: 'Selecione a Clínica',
                  border: OutlineInputBorder(),
                ),
                value: _clinicaSelecionada,
                onChanged: (Map<String, dynamic>? newValue) {
                  setState(() {
                    _clinicaSelecionada = newValue;
                  });
                },
                items: _clinicas.map((clinica) {
                  return DropdownMenuItem<Map<String, dynamic>>(
                    value: clinica,
                    child: Text(clinica['nome_clinica']),
                  );
                }).toList(),
              ),
            SizedBox(height: 16),
            ListTile(
              title: Text(
                _selectedDate == null
                    ? 'Selecione a Data'
                    : 'Data: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
              ),
              trailing: Icon(Icons.calendar_today),
              onTap: () => _selectDate(context),
            ),
            ListTile(
              title: Text(
                _selectedTime == null
                    ? 'Selecione o Horário'
                    : 'Horário: ${_selectedTime!.format(context)}',
              ),
              trailing: Icon(Icons.access_time),
              onTap: () => _selectTime(context),
            ),
            if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,
                style: TextStyle(color: Colors.red),
              ),
            SizedBox(height: 16),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _createAgendamento,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal, // Cor de fundo
                      foregroundColor: Colors.white, // Cor do texto
                      padding: EdgeInsets.symmetric(
                          vertical: 16, horizontal: 32), // Padding maior
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(30), // Bordas arredondadas
                      ),
                      elevation: 5, // Sombra para destacar o botão
                    ),
                    child: Text(
                      "Agendar Consulta",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
            SizedBox(height: 24),
            Divider(),
            SizedBox(height: 16),
            Text(
              "Agendamentos",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _isLoadingAgendamentos
                ? CircularProgressIndicator()
                : _agendamentos.isEmpty
                    ? Text("Nenhum agendamento encontrado.")
                    : Expanded(
                        child: ListView.builder(
                          itemCount: _agendamentos.length,
                          itemBuilder: (context, index) {
                            final agendamento = _agendamentos[index];
                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                leading: Icon(Icons.calendar_today,
                                    color: Colors.teal),
                                title: Text(
                                    "Data: ${DateTime.parse(agendamento['data_agendamento']).day}/${DateTime.parse(agendamento['data_agendamento']).month}/${DateTime.parse(agendamento['data_agendamento']).year}"),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        "Horário: ${agendamento['horario_agendamento']}"),
                                    Text(
                                        "Status: ${agendamento['status_agendamento']}"),
                                    Text(
                                        "Clínica: ${agendamento['nome_clinica'] ?? 'Não informado'}"),
                                  ],
                                ),
                                trailing: Icon(
                                  agendamento['status_agendamento'] ==
                                          'AGENDADO'
                                      ? Icons.check_circle
                                      : Icons.cancel,
                                  color: agendamento['status_agendamento'] ==
                                          'AGENDADO'
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ],
        ),
      ),
    );
  }
}
