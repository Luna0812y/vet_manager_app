import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'launcher.dart';

class ReviewScreen extends StatelessWidget {
  // Infos do estabelecimento
  final String name;
  final String address;
  final String image;

  const ReviewScreen({
    super.key,
    required this.name,
    required this.address,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    // Imagem do local
    Widget buildProfileImage() {
      return CircleAvatar(
        radius: 70,
        backgroundImage: AssetImage(image),
      );
    }

    // Widget de Infos do estabelecimento
    Widget buildEstablishmentInfo() {
      return Column(
        children: [
          Text(
            name,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.teal[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            address,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      );
    }

    // Widget para o formulário de avaliação
    Widget buildReviewForm() {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.teal[100],
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(77),
              spreadRadius: 2,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            // Barra de avaliação
            RatingBar.builder(
              initialRating: 0,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                print('Avaliação do Usuário: $rating');
              },
            ),
            const SizedBox(height: 16),
            // Campo de comentários
            TextField(
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Comentários adicionais...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 16),
            // Botão de enviar avaliação
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.teal[300],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
              ),
              child: const Text(
                'Enviar Avaliação',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LauncherScreen()),
            );
          },
        ),
      ),
      backgroundColor: Colors.orange[50],
      // Corpo principal da tela
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            buildProfileImage(),
            const SizedBox(height: 20),
            buildEstablishmentInfo(),
            const SizedBox(height: 20),
            buildReviewForm(),
            const SizedBox(height: 20),
            // Botão adicional de avaliar (considerar remover se redundante)
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
              ),
              child: const Text(
                'Avaliar',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
