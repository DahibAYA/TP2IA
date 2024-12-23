import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Acheter des vêtements')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('clothes').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Aucun vêtement disponible.'));
          }

          final clothes = snapshot.data!.docs;

          return ListView.builder(
            itemCount: clothes.length,
            itemBuilder: (context, index) {
              final item = clothes[index];
              final data = item.data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: Image.network(
                    data['imageUrl'],
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text(data['title']),
                  subtitle: Text(
                      'Taille : ${data['size']} - Prix : ${data['price']} €'),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/details',
                      arguments: data,
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, // L'index par défaut de la page
        onTap: (index) {
          if (index == 1) {
            // Naviguer vers la page panier
            Navigator.pushNamed(context, '/basket');
          } else if (index == 2) {
            // Naviguer vers la page profil
            Navigator.pushNamed(context, '/profile');
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.shop), label: 'Acheter'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart), label: 'Panier'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
