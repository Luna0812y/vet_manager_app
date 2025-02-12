import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vet_manager/screens/pets/cadastro_pets.dart';
import 'package:vet_manager/screens/agendamento.dart';
import 'package:vet_manager/screens/pets/lista_pets.dart';
import 'package:vet_manager/screens/tela_inicial/launcher.dart';
import 'package:vet_manager/screens/user/profile_screen.dart';
import 'screens/cadastro.dart';
import 'screens/inicio.dart';
import 'screens/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferences.getInstance();

  runApp(const VetManagerApp());
}

class VetManagerApp extends StatelessWidget {
  const VetManagerApp({super.key});

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
        "/pet": (context) => PetListScreen(),
        '/user': (context) => ProfileScreen(),
        '/cadastro_pet': (context) => CadastroPetScreen(),
        '/agendamentos': (context) => AgendamentosScreen(),
      },
    );
  }
}
