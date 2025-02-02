import 'package:flutter/material.dart';
import 'package:vet_manager/services/user_service.dart'; // Importe o serviço
import 'package:http/http.dart' as http;
import 'dart:convert'; 


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();

  bool _isLoading = false;

  // Função para registrar o usuário
   Future<void> _register() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      _showErrorDialog('As senhas não coincidem.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Envia a requisição POST para o backend
      final response = await http.post(
        Uri.parse('http://localhost:3000/cadastro'), // Substitua pela URL do seu backend
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'password': _passwordController.text.trim(),
          'cpf': _phoneController.text.trim(), // CPF ou telefone, conforme necessário
        }),
      );

      if (response.statusCode == 200) {
        // Cadastro bem-sucedido, redireciona para o login
        Navigator.pushReplacementNamed(context, '/login');
      } else if (response.statusCode == 409) {
        // Caso o usuário já exista
        _showErrorDialog('Usuário já existe');
      } else {
        // Caso ocorra outro erro
        _showErrorDialog('Ocorreu um erro ao cadastrar o usuário');
      }
    } catch (e) {
      _showErrorDialog('Erro ao conectar com o servidor.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  // Exibe um diálogo de erro
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Erro'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Ok'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome completo',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Telefone',
                  border: OutlineInputBorder(),
                  hintText: '(XX) XXXXX-XXXX',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _birthDateController,
                decoration: const InputDecoration(
                  labelText: 'Data de nascimento',
                  border: OutlineInputBorder(),
                  hintText: 'DD/MM/AAAA',
                ),
                readOnly: true,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _birthDateController.text =
                          "${pickedDate.day.toString().padLeft(2, '0')}/"
                          "${pickedDate.month.toString().padLeft(2, '0')}/"
                          "${pickedDate.year}";
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Senha',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirmar senha',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Cadastrar',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: const Text(
                  'Já possui uma conta? Faça login aqui.',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
