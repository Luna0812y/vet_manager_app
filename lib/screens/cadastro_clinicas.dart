import 'package:flutter/material.dart';
import 'package:vet_manager/services/clinica_service.dart';

class CadastroClinicaScreen extends StatefulWidget {
  @override
  _CadastroClinicaScreenState createState() => _CadastroClinicaScreenState();
}

class _CadastroClinicaScreenState extends State<CadastroClinicaScreen> {
  final _formKey = GlobalKey<FormState>();
  final ClinicaService _clinicaService = ClinicaService();

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _enderecoController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();

  void _cadastrarClinica() async {
    if (_formKey.currentState!.validate()) {
      Map<String, dynamic> clinica = {
        "nome_clinica": _nomeController.text,
        "endereco_clinica": _enderecoController.text,
        "telefone_clinica": _telefoneController.text,
        "latitude": double.tryParse(_latitudeController.text) ?? 0.0,
        "longitude": double.tryParse(_longitudeController.text) ?? 0.0,
      };

      try {
        await _clinicaService.cadastrarClinica(clinica);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Clínica cadastrada com sucesso!"))
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao cadastrar clínica!"))
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Cadastrar Clínica")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: InputDecoration(labelText: "Nome da Clínica"),
                validator: (value) => value!.isEmpty ? "Campo obrigatório" : null,
              ),
              TextFormField(
                controller: _enderecoController,
                decoration: InputDecoration(labelText: "Endereço"),
                validator: (value) => value!.isEmpty ? "Campo obrigatório" : null,
              ),
              TextFormField(
                controller: _telefoneController,
                decoration: InputDecoration(labelText: "Telefone"),
                validator: (value) => value!.isEmpty ? "Campo obrigatório" : null,
              ),
              TextFormField(
                controller: _latitudeController,
                decoration: InputDecoration(labelText: "Latitude"),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? "Campo obrigatório" : null,
              ),
              TextFormField(
                controller: _longitudeController,
                decoration: InputDecoration(labelText: "Longitude"),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? "Campo obrigatório" : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _cadastrarClinica,
                child: Text("Cadastrar"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
