import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BasketPage extends StatelessWidget {
  final String userId;

  const BasketPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mon Panier')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('basket')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(
                child: Text('Erreur de chargement des données.'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Votre panier est vide.'));
          }

          final items = snapshot.data!.docs;

          // Calculate total price
          double total = items.fold(
            0.0,
            (sum, item) {
              final price = item['price'] is num
                  ? item['price']
                      .toDouble() // Use directly if it's already a number
                  : double.tryParse(item['price']?.toString() ?? '') ??
                      0.0; // Parse if it's a string
              return sum + price;
            },
          );

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];

                    // Safely extract data
                    final imageUrl = item['imageUrl'] ??
                        'https://via.placeholder.com/150'; // Default placeholder
                    final title = item['title'] ?? 'Nom non disponible';
                    final size = item['size'] ?? 'Inconnue';
                    final price = item['price'] is num
                        ? item['price'].toDouble()
                        : double.tryParse(item['price']?.toString() ?? '') ??
                            0.0;

                    return ListTile(
                      leading: Image.network(
                        imageUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.error,
                              size: 50, color: Colors.grey);
                        },
                      ),
                      title: Text(title),
                      subtitle: Text(
                          'Taille : $size - ${price.toStringAsFixed(2)} €'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          FirebaseFirestore.instance
                              .collection('users')
                              .doc(userId)
                              .collection('basket')
                              .doc(item.id)
                              .delete();
                        },
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Total : ${total.toStringAsFixed(2)} €',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
