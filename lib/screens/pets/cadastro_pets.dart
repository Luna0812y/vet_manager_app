import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:vet_manager/screens/pets/lista_pets.dart';
import 'dart:io';
import 'package:vet_manager/services/pet_service.dart';

class CadastroPetScreen extends StatefulWidget {
  const CadastroPetScreen({super.key});

  @override
  _CadastroPetScreenState createState() => _CadastroPetScreenState();
}

class _CadastroPetScreenState extends State<CadastroPetScreen> {
  final PetService _petService = PetService();

  int _currentStep = 0;

  String? _selectedType; // especie_pet
  String? _selectedSize;
  double _selectedWeight = 10.0; // peso_pet
  File? _petPhoto;
  String? _petGender; // sexo_pet

  final TextEditingController _nameController =
      TextEditingController(); // nome_pet
  final TextEditingController _breedController =
      TextEditingController(); // Novo controlador para raça

  @override
  void initState() {
    super.initState();
  }

  Future<void> _pickPetPhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _petPhoto = File(pickedFile.path);
      });
    }
  }

  // Método para enviar os dados do pet para a API
  Future<void> _submitPet() async {
    // Valida os campos obrigatórios
    if (_nameController.text.isEmpty ||
        _selectedType == null ||
        _breedController.text.isEmpty ||
        _selectedSize == null ||
        _petGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, preencha todos os campos obrigatórios.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Prepara os dados para enviar
    String name = _nameController.text.trim(); // nome_pet
    String breed = _selectedType!; // especie_pet
    String raca = _breedController.text.trim(); // raca_pet

    // Converter o tamanho selecionado para uma altura numérica
    int altura;
    if (_selectedSize == 'Pequeno') {
      altura = 30;
    } else if (_selectedSize == 'Médio') {
      altura = 50;
    } else {
      altura = 70;
    }

    double peso = _selectedWeight;

    // Mapear o sexo para 'M' ou 'F'
    String sexo;
    if (_petGender == 'Macho') {
      sexo = 'M';
    } else {
      sexo = 'F';
    }

    // Chama o método para adicionar o pet
    bool success = await _petService.addPet(
      name: name,
      breed: breed,
      raca: raca,
      altura: altura,
      peso: peso,
      sexo: sexo,
    );

    if (success) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PetListScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Falha ao cadastrar pet. Tente novamente.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cadastro de Pet"),
        backgroundColor: Colors.teal,
      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep == 0 && _selectedType == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Por favor, escolha o tipo do animal primeiro."),
              ),
            );
            return;
          }

          if (_currentStep < 4) {
            setState(() {
              _currentStep++;
            });
          } else {
            // Enviar os dados
            _submitPet();
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() {
              _currentStep--;
            });
          }
        },
        steps: [
          Step(
            title: const Text("Escolha o tipo"),
            subtitle: const Text("Passo 1 de 5"),
            content: _buildTypeSelection(),
            isActive: _currentStep >= 0,
          ),
          Step(
            title: const Text("Adicione a raça"),
            subtitle: const Text("Passo 2 de 5"),
            content: _buildBreedInput(),
            isActive: _currentStep >= 1,
          ),
          Step(
            title: const Text("Escolha o tamanho"),
            subtitle: const Text("Passo 3 de 5"),
            content: _buildSizeSelection(),
            isActive: _currentStep >= 2,
          ),
          Step(
            title: const Text("Escolha o peso"),
            subtitle: const Text("Passo 4 de 5"),
            content: _buildWeightSelection(),
            isActive: _currentStep >= 3,
          ),
          Step(
            title: const Text("Adicione os dados do pet"),
            subtitle: const Text("Passo 5 de 5"),
            content: _buildPetBaseData(),
            isActive: _currentStep >= 4,
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelection() {
    final petTypes = [
      {"name": "Cachorro", "image": "assets/images/dog.png"},
      {"name": "Gato", "image": "assets/images/cat.png"},
      {"name": "Réptil", "image": "assets/images/reptile.png"},
      {"name": "Pássaro", "image": "assets/images/bird.png"},
      {"name": "Peixe", "image": "assets/images/fish.png"},
      {"name": "Coelho", "image": "assets/images/rabbit.png"},
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      alignment: WrapAlignment.center,
      children: petTypes.map((pet) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedType = pet["name"];
              print("Tipo selecionado: $_selectedType");
            });
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                pet["name"]!,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color:
                      _selectedType == pet["name"] ? Colors.teal : Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _selectedType == pet["name"]
                        ? Colors.teal
                        : Colors.grey,
                    width: 2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Image.asset(
                      pet["image"]!,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // Substituímos a seleção de raça por um campo de entrada de texto

  Widget _buildBreedInput() {
    if (_selectedType == null) {
      return const Text("Por favor, selecione o tipo do animal primeiro.");
    }

    return TextField(
      controller: _breedController,
      decoration: const InputDecoration(
        labelText: "Raça do Pet",
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildSizeSelection() {
    final sizes = [
      {
        "name": "Pequeno",
        "subtitle": "menos de 14kg",
        "icon": Icons.pets,
        "size": 24.0
      },
      {
        "name": "Grande",
        "subtitle": "mais de 25kg",
        "icon": Icons.pets,
        "size": 40.0
      },
      {
        "name": "Médio",
        "subtitle": "14-25kg",
        "icon": Icons.pets,
        "size": 32.0
      },
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: sizes.map(
        (size) {
          final isSelected = _selectedSize == size["name"];
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedSize = size["name"] as String;
              });
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  size["icon"] as IconData,
                  size: size["size"] as double,
                  color: isSelected ? Colors.blue : Colors.grey,
                ),
                const SizedBox(height: 8),
                Text(
                  size["name"] as String,
                  style: TextStyle(
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.blue : Colors.black,
                  ),
                ),
                Text(
                  size["subtitle"] as String,
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? Colors.blue : Colors.grey,
                  ),
                ),
              ],
            ),
          );
        },
      ).toList(),
    );
  }

  Widget _buildWeightSelection() {
    return Column(
      children: [
        Slider(
          value: _selectedWeight,
          min: 0,
          max: 50,
          divisions: 50,
          label: "${_selectedWeight.toStringAsFixed(1)} kg",
          onChanged: (value) {
            setState(() {
              _selectedWeight = value;
            });
          },
        ),
        Text("Peso: ${_selectedWeight.toStringAsFixed(1)} kg"),
      ],
    );
  }

  Widget _buildPetBaseData() {
    return Column(
      children: [
        GestureDetector(
          onTap: _pickPetPhoto,
          child: CircleAvatar(
            radius: 60,
            backgroundImage: _petPhoto != null ? FileImage(_petPhoto!) : null,
            child: _petPhoto == null
                ? const Icon(Icons.add_a_photo, size: 40)
                : null,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: "Nome do Pet",
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildGenderOption("Fêmea", Icons.female),
            const SizedBox(width: 20),
            _buildGenderOption("Macho", Icons.male),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderOption(String gender, IconData icon) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _petGender = gender;
        });
      },
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor:
                _petGender == gender ? Colors.blue : Colors.grey[300],
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 5),
          Text(gender),
        ],
      ),
    );
  }
}
