import 'package:flutter/material.dart';
import 'tela_inicial/launcher.dart';
import 'tela_inicial/avaliar.dart';

import 'screens/cadastro.dart';
import 'screens/inicio.dart';
import 'screens/login.dart';

import 'localizar/maps.dart';

void main() {
  runApp(const VetManagerApp());
}

class VetManagerApp extends StatelessWidget {
  const VetManagerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.teal),
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/launcher': (context) => LauncherScreen(),
        '/maps': (context) => MapsScreen(),
      },
    );
  }
}
