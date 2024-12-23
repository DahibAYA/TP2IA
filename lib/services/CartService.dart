import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fonction pour ajouter un article au panier
  static Future<void> addItemToCart({
    required String title,
    required String size,
    required double price,
    required String imageUrl,
  }) async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;

      // Ajout du produit dans la collection 'basket' de l'utilisateur
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('basket')
          .add({
        'title': title,
        'size': size,
        'price': price,
        'imageUrl': imageUrl,
      });
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout au panier: $e');
    }
  }
}
