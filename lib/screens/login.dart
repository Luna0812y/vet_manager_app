import 'package:flutter/material.dart';
import 'package:vet_manager/services/user_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final UserService _userService = UserService();

  bool _obscureText = true; // Visibilidade da senha
  bool _isLoading = false; // Estado de carregamento

  Future<void> _login() async {
    // Validate inputs
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showErrorDialog('Por favor, preencha todos os campos.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // realizando o login
      bool success = await _userService.loginUser(
        email: _emailController.text.trim(),
        senha: _passwordController.text,
      );

      if (success) {
        Navigator.pushReplacementNamed(context, '/launcher');
      } else {
        _showErrorDialog('Credenciais inválidas');
      }
    } catch (e) {
      _showErrorDialog('Credenciais inválidas');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

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
    // Calcula dimensões do botão
    double buttonWidth = MediaQuery.of(context).size.width * 0.8;
    double buttonHeight = MediaQuery.of(context).size.height * 0.08;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Image.asset('assets/images/logo.png', height: 120),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Center(
                    child: Text(
                      ' Login ',
                      style: TextStyle(
                        fontSize: 26,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Digite seu email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                      labelText: 'Digite sua senha',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.blue,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text('Esqueceu sua senha?'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: buttonWidth,
                    height: buttonHeight,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 2, 255, 103)),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Login',
                              style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Não possui uma conta?",
                        style: TextStyle(fontSize: 20, color: Colors.black),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, "/register");
                        },
                        child: const Text(
                          " Cadastre-se.",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Limpa os controllers quando o widget é destruído
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
