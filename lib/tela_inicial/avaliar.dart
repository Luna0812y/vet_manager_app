import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import './launcher.dart';

class ReviewScreen extends StatelessWidget {
  final String name;
  final String address;
  final String image;

  ReviewScreen({
    required this.name,
    required this.address,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    double userRating = 0;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LauncherScreen()),
            );
          },
        ),
      ),
      backgroundColor: Colors.orange[50],
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 40),
            CircleAvatar(
              radius: 70,
              backgroundImage: AssetImage(image),
            ),
            SizedBox(height: 20),
            Text(
              name,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.teal[800],
              ),
            ),
            SizedBox(height: 8),
            Text(
              address,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 20),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.teal[100],
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
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
                      userRating = rating;
                      print('Avaliação do Usuário: $rating');
                    },
                  ),
                  SizedBox(height: 16),
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
                      contentPadding: EdgeInsets.all(16),
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Ação ao enviar a avaliação
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.teal[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: EdgeInsets.symmetric(
                          vertical: 14, horizontal: 32),
                    ),
                    child: Text(
                      'Enviar Avaliação',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Ação ao avaliar
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 32),
              ),
              child: Text(
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
