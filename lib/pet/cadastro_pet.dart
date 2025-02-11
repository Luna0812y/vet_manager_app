import 'package:flutter/services.dart' show rootBundle;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:vet_manager/screens/pets.dart';
import 'dart:async';
import 'dart:io';

import 'package:vet_manager/services/pet_service.dart';

class CadastroPetScreen extends StatefulWidget {
  @override
  _CadastroPetScreenState createState() => _CadastroPetScreenState();
}

class _CadastroPetScreenState extends State<CadastroPetScreen> {
  final PetService _petService = PetService();

  int _currentStep = 0;

  String? _selectedType; // especie_pet
  String? _selectedBreed; // raca_pet (agora será preenchido pelo usuário)
  String?
      _selectedSize; // altura_pet (vou mapear os tamanhos para valores numéricos)
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
    // Não precisamos mais carregar as raças, já que o usuário irá digitar
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
  // Método para enviar os dados do pet para a API
  Future<void> _submitPet() async {
    // Valida os campos obrigatórios
    if (_nameController.text.isEmpty ||
        _selectedType == null ||
        _breedController.text.isEmpty ||
        _selectedSize == null ||
        _petGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
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

    // Converter o tamanho selecionado para uma altura numérica (int)
    int altura;
    if (_selectedSize == 'Pequeno') {
      altura = 30; // Altura em cm para pequeno (exemplo)
    } else if (_selectedSize == 'Médio') {
      altura = 50; // Altura em cm para médio (exemplo)
    } else {
      altura = 70; // Altura em cm para grande (exemplo)
    }

    // O peso já é um double, não precisa converter para string
    double peso = _selectedWeight; // peso_pet

    // Mapear o sexo para 'M' ou 'F'
    String sexo;
    if (_petGender == 'Macho') {
      sexo = 'M';
    } else {
      sexo = 'F';
    }

    // Chama o método addPet do PetService
    bool success = await _petService.addPet(
      name: name,
      breed: breed,
      raca: raca,
      altura: altura,
      peso: peso,
      sexo: sexo,
    );

    // Tratar a resposta
    if (success) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PetListScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Falha ao cadastrar pet. Tente novamente.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    // Dispose dos controladores para evitar vazamentos de memória
    _nameController.dispose();
    _breedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cadastro de Pet"),
        backgroundColor: Colors.teal,
      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep == 0 && _selectedType == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
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
            // Chama o método para enviar os dados
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
            title: Text("Escolha o tipo"),
            subtitle: Text("Passo 1 de 5"),
            content: _buildTypeSelection(),
            isActive: _currentStep >= 0,
          ),
          Step(
            title: Text("Adicione a raça"),
            subtitle: Text("Passo 2 de 5"),
            content: _buildBreedInput(),
            isActive: _currentStep >= 1,
          ),
          Step(
            title: Text("Escolha o tamanho"),
            subtitle: Text("Passo 3 de 5"),
            content: _buildSizeSelection(),
            isActive: _currentStep >= 2,
          ),
          Step(
            title: Text("Escolha o peso"),
            subtitle: Text("Passo 4 de 5"),
            content: _buildWeightSelection(),
            isActive: _currentStep >= 3,
          ),
          Step(
            title: Text("Adicione os dados do pet"),
            subtitle: Text("Passo 5 de 5"),
            content: _buildPetBaseData(),
            isActive: _currentStep >= 4,
          ),
        ],
      ),
    );
  }

  // Widgets atualizados:

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
              SizedBox(height: 8),
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
      return Text("Por favor, selecione o tipo do animal primeiro.");
    }

    return TextField(
      controller: _breedController,
      decoration: InputDecoration(
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
                SizedBox(height: 8),
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
            child: _petPhoto == null ? Icon(Icons.add_a_photo, size: 40) : null,
          ),
        ),
        SizedBox(height: 10),
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: "Nome do Pet",
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildGenderOption("Fêmea", Icons.female),
            SizedBox(width: 20),
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
          SizedBox(height: 5),
          Text(gender),
        ],
      ),
    );
  }
}
