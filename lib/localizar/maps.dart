import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class MapsScreen extends StatefulWidget {
  const MapsScreen({Key? key}) : super(key: key);

  @override
  _MapsScreenState createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  int _selectedIndex = 1; // Índice inicial para a tela de Mapas
  late stt.SpeechToText _speech; // Instância para reconhecimento de fala
  bool _isListening = false; // Estado de escuta
  String _searchText = ''; // Texto de pesquisa

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText(); // Inicializa o reconhecimento de fala
  }

  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      setState(() {
        _selectedIndex = index;
      });

      switch (index) {
        case 0:
          Navigator.pushNamed(context, '/launcher');
          break;
        case 1:
          // Já está na tela de Mapas, não faz nada
          break;
        case 2:
          Navigator.pushNamed(context, '/clinica');
          break;
        case 3:
          Navigator.pushNamed(context, '/user');
          break;
        default:
          break;
      }
    }
  }

  void _startListening() async {
    if (!_isListening && await _speech.initialize()) {
      setState(() {
        _isListening = true;
      });
      _speech.listen(onResult: (result) {
        setState(() {
          _searchText = result.recognizedWords; // Atualiza o texto da pesquisa
        });
      });
    }
  }

  void _stopListening() {
    if (_isListening) {
      setState(() {
        _isListening = false;
      });
      _speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120), // Altura da AppBar
        child: AppBar(
          automaticallyImplyLeading: false, // Remove o botão de voltar
          flexibleSpace: Container(
            color: Colors.teal,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TextField(
                        textAlign: TextAlign.left,
                        controller: TextEditingController(text: _searchText),
                        onChanged: (value) {
                          setState(() {
                            _searchText = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Pesquisar Clínicas...',
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 10, vertical: 10.0),
                          suffixIcon: GestureDetector(
                            onTap: _isListening ? _stopListening : _startListening,
                            child: Icon(
                              _isListening ? Icons.mic : Icons.mic_off,
                              color: Colors.teal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            // Conteúdo da tela de Mapas
            Center(
              child: Text('Aqui vai o conteúdo do Maps'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.shifting,
        currentIndex: _selectedIndex, // Indica o índice selecionado
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Discover',
            backgroundColor: Colors.white,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Maps',
            backgroundColor: Colors.white,
          ),
          BottomNavigationBarItem(
            icon: Icon(Symbols.clinical_notes),
            label: 'Clinica',
            backgroundColor: Colors.white,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
            backgroundColor: Colors.white,
          ),
        ],
      ),
    );
  }
}
