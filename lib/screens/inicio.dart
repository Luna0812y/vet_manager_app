import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final buttonWidth = size.width * 0.8;
    final buttonHeight = size.height * 0.1;

    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: size.height * 0.15),
          _buildLogoSection(),
          const Spacer(),
          _buildButtonsSection(context, buttonWidth, buttonHeight),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildLogoSection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/images/logo.png', height: 120),
        const SizedBox(height: 20),
        const Text(
          'Vet Manager',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildButtonsSection(
      BuildContext context, double buttonWidth, double buttonHeight) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildButton(
            width: buttonWidth,
            height: buttonHeight,
            text: 'Login',
            isLogin: true,
            onPressed: () => Navigator.pushNamed(context, '/login'),
          ),
          const SizedBox(height: 10),
          _buildButton(
            width: buttonWidth,
            height: buttonHeight,
            text: 'Cadastro',
            isLogin: false,
            onPressed: () => Navigator.pushNamed(context, '/register'),
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required double width,
    required double height,
    required String text,
    required bool isLogin,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor:
              isLogin ? const Color.fromARGB(255, 19, 12, 12) : Colors.white,
          backgroundColor:
              isLogin ? Colors.white : const Color.fromARGB(255, 8, 7, 7),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
            side: BorderSide(
              color: Colors.black,
              width: 2,
            ),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 17,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
