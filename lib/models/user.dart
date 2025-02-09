class User {
  final int id;
  final String cpf;
  final String name;
  final String email;
  final String password;

  User({
    required this.id,
    required this.cpf,
    required this.name,
    required this.email,
    required this.password,
  });

  // Converter User para Map
  Map<String, dynamic> toMap() {
    return {
      'id_usuario': id,
      'cpf_usuario': cpf,
      'nome_usuario': name,
      'email_usuario': email,
      'senha_usuario': password,
    };
  }

  // Criar User a partir de um Map
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id_usuario'] ?? 0,
      cpf: map['cpf_usuario'] ?? '',
      name: map['nome_usuario'] ?? '',
      email: map['email_usuario'] ?? '',
      password: map['senha_usuario'] ?? '',
    );
  }
}
