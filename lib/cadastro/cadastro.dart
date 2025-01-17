import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
  double screenWidth = MediaQuery.of(context).size.width; // Largura da tela
  double screenHeight = MediaQuery.of(context).size.height; // Altura da tela

  double buttonWidth = screenWidth * 0.8; // Botão ocupa 80% da largura da tela
  double buttonHeight = screenHeight * 0.1; // Botão ocupa 10% da altura da tela
    
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.topRight, // Alinha no canto superior direito
              child: Padding(
                padding: const EdgeInsets.all(16.0), // Padding para afastar da borda
                child: Image.asset('assets/images/logo.png', height: 120),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                ' Cadastro ',
                style: TextStyle(
                  fontSize: 24, // Tamanho da fonte
                  fontFamily: 'Roboto', // Fonte
                  fontWeight: FontWeight.bold, // Peso da fonte
                ),
              ),
            ),
            const SizedBox(height: 20),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                border: OutlineInputBorder(),
              ),
            ),
            
            const SizedBox(height: 20),
            SizedBox(
                  width: buttonWidth,
                  height: buttonHeight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                      backgroundColor: const Color.fromARGB(255, 8, 7, 7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                        side: BorderSide(
                          color: Colors.black,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Text(
                      ' Cadastra-se ',
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                     
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    ' Ou registrar com ',
                    style: TextStyle(
                      fontSize: 15, // Tamanho da fonte
                      fontFamily: 'Roboto', // Fonte
                      fontWeight: FontWeight.bold, // Peso da fonte
                    ),
                  ),
                ),
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
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              child: const Text("Já possui conta ? Faça Login"),
            ),
          ],
        ),
      ),
    );
  }
}
