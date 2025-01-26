import 'package:flutter/services.dart' show rootBundle;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:io';

class CadastroPetScreen extends StatefulWidget {
  @override
  _CadastroPetScreenState createState() => _CadastroPetScreenState();
}

class _CadastroPetScreenState extends State<CadastroPetScreen> {
  int _currentStep = 0;
  String? _selectedType;
  String? _selectedBreed;
  String? _selectedSize;
  double _selectedWeight = 10.0;
  DateTime? _birthDate;
  File? _petPhoto;
  String? _petGender;
  final _nameController = TextEditingController();
  DateTime? _selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900), // Data mínima
      lastDate: DateTime.now(),  // Data máxima
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Map<String, List<String>> _breedsByType = {
    "Cachorro": [],
    "Gato": [],
    "Coelho": [],
  };

  @override
  void initState() {
    super.initState();
    _loadBreeds();
  }

  Future<void> _loadBreeds() async {
    try {
      // Carrega o conteúdo do arquivo
      final data = await rootBundle.loadString('assets//breeds.txt');
      final lines = data.split('\n');

      // Inicializa o mapa para armazenar as raças
      Map<String, List<String>> breedsByType = {
        "Cachorro": [],
        "Gato": [],
        "Coelho": []
      };

      // Processa cada linha do arquivo
      for (var line in lines) {
        // Remove espaços extras
        line = line.trim();

        if (line.startsWith("Cachorro:")) {
          breedsByType["Cachorro"]?.add(line.replaceFirst("Cachorro: ", "").trim());
        } else if (line.startsWith("Gato:")) {
          breedsByType["Gato"]?.add(line.replaceFirst("Gato: ", "").trim());
        } else if (line.startsWith("Coelho:")) {
          breedsByType["Coelho"]?.add(line.replaceFirst("Coelho: ", "").trim());
        }
      }

      // Atualiza o estado com as raças carregadas
      setState(() {
        _breedsByType = breedsByType;
      });

      // Depuração: verifica se as raças foram carregadas
      print("Raças carregadas: $_breedsByType");
    } catch (e) {
      // Depuração: mostra o erro caso algo dê errado
      print("Erro ao carregar raças: $e");
    }
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
              SnackBar(content: Text("Por favor, escolha o tipo do animal primeiro.")),
            );
            return;
          }

          if (_currentStep < 5) {
            setState(() {
              _currentStep++;
            });
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ConfirmacaoCadastroScreen(),
              ),
            );
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
            subtitle: Text("Step 1 / 6"),
            content: _buildTypeSelection(),
            isActive: _currentStep >= 0,
          ),
          Step(
            title: Text("Escolha a raça"),
            subtitle: Text("Step 2 / 6"),
            content: _buildBreedSelection(),
            isActive: _currentStep >= 1,
          ),
          Step(
            title: Text("Escolha o tamanho"),
            subtitle: Text("Step 3 / 6"),
            content: _buildSizeSelection(),
            isActive: _currentStep >= 2,
          ),
          Step(
            title: Text("Escolha o peso"),
            subtitle: Text("Step 4 / 6"),
            content: _buildWeightSelection(),
            isActive: _currentStep >= 3,
          ),
          Step(
            title: Text("Selecione a data de nascimento"),
            subtitle: Text("Step 5 / 6"),
            content: _buildBirthdaySelection(),
            isActive: _currentStep >= 4,
          ),
          Step(
            title: Text("Adicione os dados do pet"),
            subtitle: Text("Step 6 / 6"),
            content: _buildPetBaseData(),
            isActive: _currentStep >= 5,
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
                  color: _selectedType == pet["name"]
                      ? Colors.teal
                      : Colors.black,
                ),
              ),
              SizedBox(height: 8),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _selectedType == pet["name"] ? Colors.teal : Colors.grey,
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

  Widget _buildBreedSelection() {
    List<String> allBreeds = [];
    _breedsByType.forEach((key, value) {
      allBreeds.addAll(value);
    });

    allBreeds.sort(); // Ordena todas as raças para facilitar a busca.

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          decoration: InputDecoration(
            labelText: "Pesquisar raça",
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
          onChanged: (query) {
            setState(() {
              // Filtra as raças de acordo com o texto inserido.
              allBreeds = _breedsByType.values
                  .expand((breeds) => breeds)
                  .where((breed) => breed.toLowerCase().contains(query.toLowerCase()))
                  .toList();
            });
          },
        ),
        SizedBox(height: 16),
        if (allBreeds.isEmpty)
          Center(
            child: Text(
              "Nenhuma raça encontrada.",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              itemCount: allBreeds.length,
              itemBuilder: (context, index) {
                final breed = allBreeds[index];
                return ListTile(
                  title: Text(breed),
                  onTap: () {
                    setState(() {
                      _selectedBreed = breed;
                    });
                  },
                  selected: _selectedBreed == breed,
                  selectedTileColor: Colors.teal.withOpacity(0.1),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildSizeSelection() {
    final sizes = [
      {"name": "Pequeno", "subtitle": "under 14kg", "icon": Icons.pets, "size": 24.0},
      {"name": "Grande", "subtitle": "over 25kg", "icon": Icons.pets, "size": 40.0},
      {"name": "Médio", "subtitle": "14-25kg", "icon": Icons.pets, "size": 32.0},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: sizes.map(
        (size) {
          final isSelected = _selectedSize == size["name"] as String; // Cast explícito para String
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedSize = size["name"] as String; // Cast explícito para String
              });
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  size["icon"] as IconData, // Cast explícito para IconData
                  size: size["size"] as double, // Cast explícito para double
                  color: isSelected ? Colors.blue : Colors.grey,
                ),
                SizedBox(height: 8),
                Text(
                  size["name"] as String, // Cast explícito para String
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.blue : Colors.black,
                  ),
                ),
                Text(
                  size["subtitle"] as String, // Cast explícito para String
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

  Widget _buildBirthdaySelection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "Selecione a data de aniversário",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16),
        CalendarDatePicker(
          initialDate: _birthDate ?? DateTime.now(),
          firstDate: DateTime(1900), // Permite datas desde 1900
          lastDate: DateTime.now(),  // Restringe a data máxima para hoje
          onDateChanged: (DateTime date) {
            setState(() {
              _birthDate = date;
            });
          },
        ),
        SizedBox(height: 16),
        if (_birthDate != null)
          Text(
            "Você selecionou: ${DateFormat('dd/MM/yyyy').format(_birthDate!)}",
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
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
            backgroundImage:
                _petPhoto != null ? FileImage(_petPhoto!) : null,
            child: _petPhoto == null
                ? Icon(Icons.add_a_photo, size: 40)
                : null,
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

class ConfirmacaoCadastroScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cadastro Concluído"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Seu pet foi cadastrado com sucesso!"),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/user');
              },
              child: Text("Voltar para a tela inicial"),
            ),
          ],
        ),
      ),
    );
  }
}