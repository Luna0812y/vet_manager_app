import 'package:flutter/material.dart';
import 'tela_inicial/launcher.dart';
import 'tela_inicial/avaliar.dart';

import 'cadastro/cadastro.dart';
import 'cadastro/inicio.dart';
import 'cadastro/login.dart';

import 'localizar/maps.dart';

import 'clinica/clinica.dart';

import 'usuario/user.dart';

import 'pet/cadastro_pet.dart';


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
        '/user': (context) => UserProfileScreen(),
        '/cadastro_pet': (context) => CadastroPetScreen(),
        '/clinica': (context) => ClinicScreen(),
      },
    );
  }
}
