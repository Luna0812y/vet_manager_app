class Pet {
  final String nomePet;
  final String especiePet;
  final String racaPet;
  final String alturaPet;
  final double pesoPet;
  final String sexoPet;

  Pet({
    required this.nomePet,
    required this.especiePet,
    required this.racaPet,
    required this.alturaPet,
    required this.pesoPet,
    required this.sexoPet,
  });

  Map<String, dynamic> toJson() {
    return {
      'nome_pet': nomePet,
      'especie_pet': especiePet,
      'raca_pet': racaPet,
      'altura_pet': alturaPet,
      'peso_pet': pesoPet,
      'sexo_pet': sexoPet,
    };
  }
}
