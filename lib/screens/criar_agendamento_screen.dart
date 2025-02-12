import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vet_manager/services/agendamento_service.dart';
import 'dart:convert';
import 'package:vet_manager/services/clinica_service.dart';
import 'package:vet_manager/services/pet_service.dart';
import 'package:vet_manager/services/user_service.dart';

class CriarAgendamentoScreen extends StatefulWidget {
  const CriarAgendamentoScreen({super.key});

  @override
  _CriarAgendamentoScreenState createState() => _CriarAgendamentoScreenState();
}

class _CriarAgendamentoScreenState extends State<CriarAgendamentoScreen> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isLoading = false;
  String _errorMessage = "";

  final ClinicaService clinicService = ClinicaService();
  final PetService petService = PetService();
  final UserService _userService = UserService();

  List<Map<String, dynamic>> _clinicas = [];
  List<Map<String, dynamic>> _pets = [];
  Map<String, dynamic>? _clinicaSelecionada;
  Map<String, dynamic>? _petSelecionado;

  int? _userId;
  String? _token;

  List<Map<String, dynamic>> _tiposServico = [];
  List<Map<String, dynamic>> _trabalhos = [];
  Map<String, dynamic>? _tipoServicoSelecionado;
  Map<String, dynamic>? _trabalhoSelecionado;

  @override
  void initState() {
    super.initState();
    _loadUserId();
    _loadToken();
    _loadClinicas();
    _loadPets();
  }

  Future<void> _loadUserId() async {
    int? userId = await _userService.getUserIdFromToken();
    if (userId != null) {
      setState(() {
        _userId = userId;
      });
    }
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString("token");
    if (token != null && token.isNotEmpty) {
      setState(() {
        _token = token;
      });
    }
  }

  Future<void> _loadClinicas() async {
    try {
      List<Map<String, dynamic>> clinicas = await clinicService.fetchClinics();
      setState(() {
        _clinicas = clinicas;
        if (_clinicas.isNotEmpty) {
          _clinicaSelecionada = _clinicas[0];
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Erro ao carregar clínicas";
      });
    }
  }

  Future<void> _loadPets() async {
    try {
      List<dynamic> data = await petService.fetchPets();
      List<Map<String, dynamic>> pets = data.cast<Map<String, dynamic>>();

      setState(() {
        _pets = pets;
        if (_pets.isNotEmpty) {
          _petSelecionado = _pets[0];
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Erro ao carregar pets";
      });
    }
  }

  void _updateServicosETrabalhos(Map<String, dynamic>? clinica) {
    if (clinica == null) {
      setState(() {
        _tiposServico = [];
        _trabalhos = [];
        _tipoServicoSelecionado = null;
        _trabalhoSelecionado = null;
      });
      return;
    }

    // Extract unique services from the selected clinic
    List<Map<String, dynamic>> servicos = [];
    for (var servico in clinica['servicos'] ?? []) {
      servicos.add({
        'id_servico': servico['id_servico'],
        'nome_servico': servico['nome_servico'],
        'trabalhos': servico['trabalhos'],
      });
    }

    setState(() {
      _tiposServico = servicos;
      _tipoServicoSelecionado =
          _tiposServico.isNotEmpty ? _tiposServico[0] : null;
      _updateTrabalhos(_tipoServicoSelecionado);
    });
  }

  void _updateTrabalhos(Map<String, dynamic>? servico) {
    if (servico == null) {
      setState(() {
        _trabalhos = [];
        _trabalhoSelecionado = null;
      });
      return;
    }

    // Get trabalhos directly from the selected service
    List<Map<String, dynamic>> trabalhos = (servico['trabalhos'] as List? ?? [])
        .map((trabalho) => {
              'id_servico': servico['id_servico'],
              'id_trabalho': trabalho['id_trabalho'],
              'nome_trabalho': trabalho['nome_trabalho'],
              'nome_servico': servico['nome_servico'],
            })
        .toList();

    setState(() {
      _trabalhos = trabalhos;
      _trabalhoSelecionado = _trabalhos.isNotEmpty ? _trabalhos[0] : null;
    });
  }

  Widget _buildServicoETrabalhoDropdowns() {
    return Column(
      children: [
        DropdownButtonFormField<Map<String, dynamic>>(
          decoration: const InputDecoration(
            labelText: 'Selecione o Tipo de Serviço',
            border: OutlineInputBorder(),
          ),
          value: _tipoServicoSelecionado,
          onChanged: (newValue) {
            setState(() {
              _tipoServicoSelecionado = newValue;
              _updateTrabalhos(newValue);
            });
          },
          items: _tiposServico.map((servico) {
            return DropdownMenuItem(
              value: servico,
              child: Text(servico['nome_servico'] ?? 'Serviço sem nome'),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        DropdownButtonFormField<Map<String, dynamic>>(
          decoration: const InputDecoration(
            labelText: 'Selecione o Trabalho',
            border: OutlineInputBorder(),
          ),
          value: _trabalhoSelecionado,
          onChanged: (newValue) {
            setState(() {
              _trabalhoSelecionado = newValue;
            });
          },
          items: _trabalhos.map((trabalho) {
            return DropdownMenuItem(
              value: trabalho,
              child: Text(trabalho['nome_trabalho'] ?? 'Trabalho sem nome'),
            );
          }).toList(),
        ),
      ],
    );
  }

  Future<void> _cadastrarAgendamento() async {
    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });

    if (_selectedDate == null ||
        _selectedTime == null ||
        _petSelecionado == null ||
        _clinicaSelecionada == null ||
        _trabalhoSelecionado == null) {
      setState(() {
        _errorMessage = "Preencha todos os campos!";
        _isLoading = false;
      });
      return;
    }

    try {
      final dataCompleta = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      final agendamentoData = {
        "data_agendamento": dataCompleta.toUtc().toIso8601String(),
        "horario_agendamento":
            "${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}",
        "status_agendamento": "AGENDADO",
        "id_pet": _petSelecionado!["id_pet"],
        "id_clinica": _clinicaSelecionada!["id_clinica"],
        "id_tipo_servico": _trabalhoSelecionado!["id_servico"],
        "id_trabalho": _trabalhoSelecionado!["id_trabalho"],
      };

      final success =
          await AgendamentoService().criarAgendamento(agendamentoData);

      if (success) {
        Navigator.pop(context, true);
      } else {
        setState(() {
          _errorMessage = "Não foi possível criar o agendamento";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Erro ao criar agendamento: ${e.toString()}";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Nova Consulta"), backgroundColor: Colors.teal),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<Map<String, dynamic>>(
              decoration: const InputDecoration(
                labelText: 'Selecione o Pet',
                border: OutlineInputBorder(),
              ),
              value: _petSelecionado,
              onChanged: (newValue) {
                setState(() {
                  _petSelecionado = newValue;
                });
              },
              items: _pets.map((pet) {
                return DropdownMenuItem(
                  value: pet,
                  child: Text(pet['nome_pet'] ?? 'Nome não encontrado'),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<Map<String, dynamic>>(
              decoration: const InputDecoration(
                labelText: 'Selecione a Clínica',
                border: OutlineInputBorder(),
              ),
              value: _clinicaSelecionada,
              onChanged: (newValue) {
                setState(() {
                  _clinicaSelecionada = newValue;
                  _updateServicosETrabalhos(newValue);
                });
              },
              items: _clinicas.map((clinica) {
                return DropdownMenuItem(
                  value: clinica,
                  child: Text(clinica['nome_clinica'] ?? 'Clínica sem nome'),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            _buildServicoETrabalhoDropdowns(),
            const SizedBox(height: 20),
            ListTile(
              title: Text(_selectedDate == null
                  ? 'Selecione a Data'
                  : 'Data: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (pickedDate != null) {
                  setState(() {
                    _selectedDate = pickedDate;
                  });
                }
              },
            ),
            ListTile(
              title: Text(_selectedTime == null
                  ? 'Selecione o Horário'
                  : 'Horário: ${_selectedTime!.format(context)}'),
              trailing: const Icon(Icons.access_time),
              onTap: () async {
                final pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (pickedTime != null) {
                  setState(() {
                    _selectedTime = pickedTime;
                  });
                }
              },
            ),
            const SizedBox(height: 30),
            _isLoading
                ? const CircularProgressIndicator()
                : Container(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.pets, color: Colors.white),
                      label: const Text(
                        "Agendar Consulta",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 5,
                      ),
                      onPressed: _cadastrarAgendamento,
                    ),
                  ),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
