import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Variável para controlar a visibilidade da senha
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width; // Largura da tela
    double screenHeight = MediaQuery.of(context).size.height; // Altura da tela

    double buttonWidth =
        screenWidth * 0.8; // Botão ocupa 80% da largura da tela
    double buttonHeight =
        screenHeight * 0.1; // Botão ocupa 10% da altura da tela

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.start, // Alinha ao topo da tela
            children: [
              // Logo centralizada
              Align(
                alignment:
                    Alignment.topRight, // Alinha no canto superior direito
                child: Padding(
                  padding: const EdgeInsets.all(
                      16.0), // Padding para afastar da borda
                  child: Image.asset('assets/images/logo.png', height: 120),
                ),
              ),

              const SizedBox(height: 20),
              Center(
                child: Text(
                  ' Login ',
                  style: TextStyle(
                    fontSize: 26, // Tamanho da fonte
                    fontFamily: 'Roboto', // Fonte
                    fontWeight: FontWeight.bold, // Peso da fonte
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Campos de entrada com largura ajustada
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Digite seu email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              // Campo de senha com "olho" para alternar a visibilidade
              TextField(
                obscureText:
                    _obscureText, // Controla se a senha está oculta ou não
                decoration: InputDecoration(
                  labelText: 'Digite sua senha',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      // Muda o ícone conforme o estado da senha (visível ou não)
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: Colors.blue, // Cor do ícone
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText =
                            !_obscureText; // Alterna a visibilidade da senha
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // "Esqueceu a senha?" à direita
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text('Esqueceu sua senha?'),
                ),
              ),

              const SizedBox(height: 20),

              // Botão de Login
              SizedBox(
                width: buttonWidth, // Largura proporcional ao tamanho da tela
                height: buttonHeight, // Altura proporcional ao tamanho da tela
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: const Color.fromARGB(
                        255, 255, 255, 255), // Cor da letra
                    backgroundColor: const Color.fromARGB(
                        255, 0, 0, 0), // Cor de fundo quando o botão está ativo
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius
                          .zero, // Bordas retas (sem arredondamento)
                      side: BorderSide(
                        color: Colors.black, // Cor da borda
                        width: 2, // Largura da borda
                      ),
                    ),
                  ),
                  child: Text(
                    ' Login ',
                    style: TextStyle(
                      fontSize: 17, // Tamanho da fonte
                      fontFamily:
                          'Roboto', // Fonte (pode ser qualquer fonte disponível)
                      fontWeight: FontWeight.bold, // Peso da fonte
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/launcher');
                  },
                ),
              ),

              const SizedBox(height: 20),
              Center(
                child: Text(
                  ' Ou logar com ',
                  style: TextStyle(
                    fontSize: 15, // Tamanho da fonte
                    fontFamily: 'Roboto', // Fonte
                    fontWeight: FontWeight.bold, // Peso da fonte
                  ),
                ),
              ),
              // Ícones sociais centralizados
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.facebook, color: Colors.blue),
                  SizedBox(width: 10),
                  Icon(Icons.g_mobiledata, color: Colors.red),
                  SizedBox(width: 10),
                  Icon(Icons.apple, color: Colors.black),
                ],
              ),

              const SizedBox(height: 20),

              // Link para registro
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: const Text("Não possui conta ? Registre-se"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
