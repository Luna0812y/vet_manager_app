import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vet_manager/pet/cadastro_pet.dart';
import 'package:vet_manager/screens/agendamento.dart';
import 'package:vet_manager/services/env_service.dart';
import 'package:vet_manager/usuario/user.dart';
import 'tela_inicial/launcher.dart';
import 'tela_inicial/avaliar.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/cadastro.dart';
import 'screens/inicio.dart';
import 'screens/login.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // 🔹 Garante que os bindings do Flutter são inicializados
  SharedPreferences prefs = await SharedPreferences
      .getInstance(); // 🔹 Inicializa antes de rodar a aplicação

  final keysEnv = EnvVariables();

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
        '/user': (context) => UserProfileScreen(),
        '/cadastro_pet': (context) => CadastroPetScreen(),
        '/agendamentos': (context) => AgendamentosScreen(),
      },
    );
  }
}
