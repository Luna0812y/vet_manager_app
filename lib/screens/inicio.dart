import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width; // Largura da tela
    double screenHeight = MediaQuery.of(context).size.height; // Altura da tela

    double buttonWidth = screenWidth * 0.8; // Botão ocupa 80% da largura da tela
    double buttonHeight = screenHeight * 0.1; // Botão ocupa 10% da altura da tela

    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 30), 
          // Parte superior: LOGO e TÍTULO centralizados
          Align(
            alignment: Alignment.topCenter,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Alinha no topo
              children: [
                Image.asset('assets/images/logo.png', height: 120),
                const SizedBox(height: 20),
                const Text(
                  'Vet Manager',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          
          // Spacer para empurrar os botões para a parte inferior
          Spacer(), // Empurra o conteúdo para baixo

          // Parte inferior: Botões centralizados
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Centraliza os botões
              children: [
                // Botão Login
                SizedBox(
                  width: buttonWidth, // Largura proporcional ao tamanho da tela
                  height: buttonHeight, // Altura proporcional ao tamanho da tela
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: const Color.fromARGB(255, 19, 12, 12), // Cor da letra
                      backgroundColor: const Color.fromARGB(255, 255, 255, 255), // Cor de fundo quando o botão está ativo
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero, // Bordas retas (sem arredondamento)
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
                        fontFamily: 'Roboto', // Fonte (pode ser qualquer fonte disponível)
                        fontWeight: FontWeight.bold, // Peso da fonte
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                  ),
                ),
                const SizedBox(height: 10), // Espaço entre os botões
                // Botão Registrar
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
                      ' Registrar ',
                      style: TextStyle(
                        fontSize: 17,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    },
                  ),
                ),
                    const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
