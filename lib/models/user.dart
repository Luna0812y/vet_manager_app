class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String birthDate;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.birthDate,
  });

  // Converter User para Map (para armazenar no Firestore, por exemplo)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'birthDate': birthDate,
    };
  }

  // Criar User a partir de um Map (ao recuperar dados do Firestore, por exemplo)
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      birthDate: map['birthDate'] ?? '',
    );
  }
}
