import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DetailsPage extends StatelessWidget {
  final Map<String, dynamic> item;

  const DetailsPage({super.key, required this.item});

  Future<void> _addToCart(BuildContext context) async {
    try {
      // Vérification si l'utilisateur est connecté
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Veuillez vous connecter pour ajouter un article au panier.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      final userId = user.uid;

      // Sécurisation des données de l'article
      if (item['title'] == null ||
          item['size'] == null ||
          item['price'] == null ||
          item['imageUrl'] == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Données du produit manquantes.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      // Conversion sécurisée du prix
      double price = double.tryParse(item['price']) ?? 0.0;

      // Ajout de l'article dans la collection 'basket' de l'utilisateur
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('basket')
          .add({
        'title': item['title'],
        'size': item['size'],
        'price': item['price'],
        'imageUrl': item['imageUrl'],
        'brand': item['brand'],
      });

      // Affichage du message de succès
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${item['title']} ajouté au panier !')),
      );
    } catch (e) {
      // En cas d'erreur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'ajout au panier: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(item['title'] ?? 'Détails du produit')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image du vêtement
            Image.network(
              item['image'] ?? 'URL image par défaut',
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: const Icon(Icons.error, size: 50),
                );
              },
            ),
            const SizedBox(height: 10),

            // Titre du vêtement
            Text(
              item['title'] ?? 'Titre non disponible',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Catégorie du vêtement
            Text(
              'Catégorie : ${item['category'] ?? 'Inconnue'}',
              style: const TextStyle(fontSize: 18),
            ),

            // Taille
            Text(
              'Taille : ${item['size'] ?? 'Inconnue'}',
              style: const TextStyle(fontSize: 18),
            ),

            // Marque
            Text(
              'brand : ${item['brand'] ?? 'Inconnue'}',
              style: const TextStyle(fontSize: 18),
            ),

            // Prix
            Text(
              'price : ${item['price'] ?? '0.00'} €',
              style: const TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 20),

            // Boutons d'action
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Retour'),
                ),
                ElevatedButton(
                  onPressed: () => _addToCart(context),
                  child: const Text('Ajouter au panier'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
