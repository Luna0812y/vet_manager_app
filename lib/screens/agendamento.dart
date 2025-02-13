import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'criar_agendamento.dart';

class AgendamentosScreen extends StatefulWidget {
  @override
  _AgendamentosScreenState createState() => _AgendamentosScreenState();
}

class _AgendamentosScreenState extends State<AgendamentosScreen> {
  List<dynamic> _agendamentos = [];
  bool _isLoading = true;
  String _errorMessage = "";

  String? _token;

  @override
  void initState() {
    super.initState();
    _loadAgendamentos();
  }

  Future<void> _loadAgendamentos() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Obtém o token armazenado no SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('token');

      if (_token == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Token de autenticação não encontrado.';
        });
        return;
      }

      final url =
          Uri.parse('https://vetmanager-cvof.onrender.com/agendamentos');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);

        setState(() {
          _agendamentos = data['agendamentos'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage =
              'Erro ao carregar agendamentos. Código: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao carregar agendamentos.';
        _isLoading = false;
      });
      print('Erro: $e');
    }
  }

  void _navigateToCriarAgendamento() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CriarAgendamentoScreen(),
      ),
    ).then((_) => _loadAgendamentos()); // Recarrega os agendamentos ao voltar
  }

  void _showAgendamentoDetails(Map<String, dynamic> agendamento) async {
    try {
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Detalhes do Agendamento'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                      'Data: ${agendamento['data_agendamento'] != null ? DateTime.parse(agendamento['data_agendamento']).toLocal().toString().substring(0, 10) : 'N/A'}'),
                  SizedBox(height: 8),
                  Text(
                      'Horário: ${agendamento['horario_agendamento'] ?? 'N/A'}'),
                  SizedBox(height: 8),
                  Text('Status: ${agendamento['status_agendamento'] ?? 'N/A'}'),
                  SizedBox(height: 8),
                  Text('Pet: ${agendamento['pet']?['nome_pet'] ?? 'N/A'}'),
                  SizedBox(height: 8),
                  Text(
                      'Clínica: ${agendamento['clinica']?['nome_clinica'] ?? 'N/A'}'),
                  if (agendamento['tipo_servico'] != null) ...[
                    SizedBox(height: 8),
                    Text(
                        'Serviço: ${agendamento['tipo_servico']['nome_servico'] ?? 'N/A'}'),
                  ],
                  if (agendamento['trabalho'] != null) ...[
                    SizedBox(height: 8),
                    Text(
                        'Trabalho: ${agendamento['trabalho']['nome_trabalho'] ?? 'N/A'}'),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Fechar'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar detalhes do agendamento'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Consultas Agendadas',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : _agendamentos.isEmpty
                  ? Center(child: Text("Nenhuma consulta encontrada."))
                  : RefreshIndicator(
                      onRefresh: _loadAgendamentos,
                      child: ListView.builder(
                        padding: EdgeInsets.all(8.0),
                        itemCount: _agendamentos.length,
                        itemBuilder: (context, index) {
                          final agendamento = _agendamentos[index];

                          if (agendamento is Map<String, dynamic>) {
                            // Acessa os campos do agendamento
                            final dataAgendamento =
                                agendamento['data_agendamento'] != null
                                    ? DateTime.parse(
                                            agendamento['data_agendamento'])
                                        .toLocal()
                                        .toString()
                                        .substring(0, 10)
                                    : 'N/A';
                            final horarioAgendamento =
                                agendamento['horario_agendamento'] ?? 'N/A';
                            final statusAgendamento =
                                agendamento['status_agendamento'] ?? 'N/A';

                            // Informações adicionais
                            final nomePet = agendamento['pet']?['nome_pet'] ??
                                'Pet não informado';
                            final nomeClinica = agendamento['clinica']
                                    ?['nome_clinica'] ??
                                'Clínica não informada';

                            // Estiliza o status
                            Color statusColor;
                            if (statusAgendamento == "AGENDADO") {
                              statusColor = Colors.green;
                            } else if (statusAgendamento == "CANCELADO") {
                              statusColor = Colors.red;
                            } else {
                              statusColor = Colors.grey;
                            }

                            return Card(
                              elevation: 4.0,
                              margin: EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 4.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.teal.shade100,
                                  child: Icon(
                                    Icons.calendar_today,
                                    color: Colors.teal,
                                  ),
                                ),
                                title: Text(
                                  'Data: $dataAgendamento',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Horário: $horarioAgendamento',
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    Text(
                                      'Pet: $nomePet',
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    Text(
                                      'Clínica: $nomeClinica',
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    Text(
                                      'Status: $statusAgendamento',
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        color: statusColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.business,
                                        color: Colors.teal,
                                      ),
                                      onPressed: () {
                                        // Mostrar detalhes da clínica em um dialog
                                        _showAgendamentoDetails(agendamento);
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.more_vert,
                                        color: Colors.grey[600],
                                      ),
                                      onPressed: () {
                                        // Ação ao clicar no botão de opções
                                      },
                                    ),
                                  ],
                                ),
                                onTap: () =>
                                    _showAgendamentoDetails(agendamento),
                              ),
                            );
                          } else {
                            // Caso a estrutura não seja Map, exibe uma mensagem de erro
                            return ListTile(
                              title: Text('Agendamento inválido'),
                            );
                          }
                        },
                      ),
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCriarAgendamento,
        child: Icon(Icons.add),
        backgroundColor: Colors.teal,
      ),
    );
  }
}
