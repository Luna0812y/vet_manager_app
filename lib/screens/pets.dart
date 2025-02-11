import 'package:flutter/material.dart';
import 'package:vet_manager/pet/cadastro_pet.dart';
import 'package:vet_manager/services/pet_service.dart';

class PetListScreen extends StatefulWidget {
  @override
  _PetListScreenState createState() => _PetListScreenState();
}

class _PetListScreenState extends State<PetListScreen> {
  List pets = [];

  @override
  void initState() {
    super.initState();
    loadPets();
  }

  Future<void> loadPets() async {
    final _pets = await PetService().fetchPets();

    setState(() {
      pets = _pets;
    });
  }

  void navigateToAddPetScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CadastroPetScreen()),
    ).then((_) => loadPets());
  }

  Future<void> deletePet(int petId) async {
    bool success = await PetService().deletePet(petId);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pet deletado com sucesso!'),
          backgroundColor: Colors.teal,
        ),
      );
      loadPets();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Falha ao deletar pet. Tente novamente.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void confirmDeletePet(int petId, String petName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Deletar Pet'),
        content: Text('Tem certeza que deseja deletar "$petName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              deletePet(petId);
            },
            child: Text(
              'Deletar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Lista de Pets',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: pets.isEmpty
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadPets,
              child: ListView.builder(
                padding: EdgeInsets.all(8.0),
                itemCount: pets.length,
                itemBuilder: (context, index) {
                  final pet = pets[index];

                  // Calcula o porte do pet com base no peso
                  String porte;
                  if (pet['peso_pet'] != null) {
                    double peso = pet['peso_pet'] is double
                        ? pet['peso_pet']
                        : double.tryParse(pet['peso_pet'].toString()) ?? 0.0;
                    if (peso < 14) {
                      porte = 'Pequeno';
                    } else if (peso <= 25) {
                      porte = 'Médio';
                    } else {
                      porte = 'Grande';
                    }
                  } else {
                    porte = 'Desconhecido';
                  }

                  // Mapeia o sexo do pet
                  String sexoPet;
                  if (pet['sexo_pet'] == 'M') {
                    sexoPet = 'Macho';
                  } else if (pet['sexo_pet'] == 'F') {
                    sexoPet = 'Fêmea';
                  } else {
                    sexoPet = 'Desconhecido';
                  }

                  return Card(
                    elevation: 4.0,
                    margin:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.green.shade100,
                        child: Icon(
                          Icons.pets,
                          color: Colors.teal,
                        ),
                      ),
                      title: Text(
                        pet['nome_pet'] ?? 'Nome Desconhecido',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pet['raca_pet'] != null
                                ? 'Raça: ${pet['raca_pet']}'
                                : 'Raça: Desconhecida',
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            'Porte: $porte',
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            'Sexo: $sexoPet',
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          confirmDeletePet(
                            pet['id_pet'],
                            pet['nome_pet'] ?? 'este pet',
                          );
                        },
                      ),
                      onTap: () {
                        // Ação ao clicar no pet (por exemplo, ver detalhes)
                      },
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: navigateToAddPetScreen,
        child: Icon(Icons.add),
        backgroundColor: Colors.teal,
      ),
    );
  }
}
