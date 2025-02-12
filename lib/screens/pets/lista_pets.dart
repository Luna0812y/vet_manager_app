import 'package:flutter/material.dart';
import 'package:vet_manager/screens/pets/cadastro_pets.dart';
import 'package:vet_manager/services/pet_service.dart';

class PetListScreen extends StatefulWidget {
  const PetListScreen({super.key});

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
    // Carrega a lista de pets do banco de dados
    final loadedPets = await PetService().fetchPets();

    setState(() {
      pets = loadedPets;
    });
  }

  void navigateToAddPetScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CadastroPetScreen()),
    ).then((_) => loadPets());
  }

  // Deleta um pet
  Future<void> deletePet(int petId) async {
    bool success = await PetService().deletePet(petId);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pet deletado com sucesso!'),
          backgroundColor: Colors.teal,
        ),
      );
      loadPets();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Falha ao deletar pet. Tente novamente.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Confirma a deleção do pet
  void confirmDeletePet(int petId, String petName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deletar Pet'),
        content: Text('Tem certeza que deseja deletar "$petName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              deletePet(petId);
            },
            child: const Text(
              'Deletar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  // Constrói a tela de lista de pets
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Lista de Pets',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: pets.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadPets,
              child: ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: pets.length,
                itemBuilder: (context, index) {
                  final pet = pets[index];

                  // Classifica o porte do pet baseado no peso
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
                    margin: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 4.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.green.shade100,
                        child: const Icon(
                          Icons.pets,
                          color: Colors.teal,
                        ),
                      ),
                      title: Text(
                        pet['nome_pet'] ?? 'Nome Desconhecido',
                        style: const TextStyle(
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
                        icon: const Icon(
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
        backgroundColor: Colors.teal,
        child: Icon(Icons.add),
      ),
    );
  }
}
