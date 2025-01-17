import 'package:flutter/material.dart';

class MapsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(120), // Altura da AppBar
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
                        decoration: InputDecoration(
                          hintText: 'Clínicas Veterinárias',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 20),
                          suffixIcon: Icon(Icons.mic, color: Colors.teal),
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
          children: [
            // Conteúdo da tela de Mapas
            Center(
              child: Text('Aqui vai o conteúdo do Maps'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Discover',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Maps',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pets),
            label: 'Pet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        onTap: (int index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/launcher'); // Quando "Discover" é clicado
              break;
            case 1:
              Navigator.pushNamed(context, '/maps'); // Quando "Maps" é clicado
              break;
            case 2:
              Navigator.pushNamed(context, '/pet'); // Quando "Pet" é clicado
              break;
            case 3:
              Navigator.pushNamed(context, '/profile'); // Quando "Profile" é clicado
              break;
            default:
              break;
          }
        },
      ),
    );
  }
}
