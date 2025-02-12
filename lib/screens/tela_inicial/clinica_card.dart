import 'package:flutter/material.dart';

class ClinicaCard extends StatelessWidget {
  // Propriedades do card da clínica
  final String name;
  final String address;
  final double rating;
  final String image;
  final VoidCallback onTap;

  const ClinicaCard({
    super.key,
    required this.name,
    required this.address,
    required this.rating,
    required this.image,
    required this.onTap,
  });

  // Gera as estrelas baseadas na avaliação
  List<Widget> _buildRatingStars(double rating) {
    List<Widget> stars = [];
    int fullStars = rating.floor(); // Número de estrelas cheias
    bool hasHalfStar =
        (rating - fullStars) >= 0.5; // Verifica se precisa de meia estrela

    // Gera as 5 estrelas
    for (int i = 0; i < 5; i++) {
      if (i < fullStars) {
        // Adiciona estrela cheia
        stars.add(const Icon(Icons.star, size: 16, color: Colors.amber));
      } else if (i == fullStars && hasHalfStar) {
        // Adiciona meia estrela
        stars.add(const Icon(Icons.star_half, size: 16, color: Colors.amber));
      } else {
        // Adiciona estrela vazia
        stars.add(const Icon(Icons.star_border, size: 16, color: Colors.amber));
      }
    }
    return stars;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 5.0),
        // Configuração da decoração do card
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3), // Deslocamento da sombra
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Seção da imagem da clínica
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(15)),
                child: Image.asset(
                  image,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Seção de informações da clínica
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(15)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Endereço da clínica
                  Text(
                    address,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Avaliação em estrelas
                  Row(
                    children: _buildRatingStars(rating),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
