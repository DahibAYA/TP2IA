import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'addclothingscreen.page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();

  String _login = '';
  final String _password = '****'; // Masqué pour des raisons de sécurité
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = _auth.currentUser;

    if (user != null) {
      setState(() {
        _login = user.email ?? ''; // Récupère l'email de l'utilisateur
      });

      try {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        final data = doc.data();
        if (data != null) {
          setState(() {
            _birthdayController.text = data['birthday'] ?? '';
            _addressController.text = data['address'] ?? '';
            _postalCodeController.text = data['postalCode'] ?? '';
            _cityController.text = data['city'] ?? '';
          });
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Erreur lors de la récupération des données.')),
        );
      }
    }

    setState(() {
      _isLoading = false; // Fin du chargement
    });
  }

  Future<void> _saveUserProfile() async {
    final user = _auth.currentUser;

    if (user != null) {
      if (_formKey.currentState!.validate()) {
        try {
          await _firestore.collection('users').doc(user.uid).set({
            'birthday': _birthdayController.text,
            'address': _addressController.text,
            'postalCode': _postalCodeController.text,
            'city': _cityController.text,
          }, SetOptions(merge: true));

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profil mis à jour avec succès !')),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erreur lors de la mise à jour.')),
          );
        }
      }
    }
  }

  void _logout() async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextField(
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Login',
                        hintText: _login,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const TextField(
                      obscureText: true,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: '****',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _birthdayController,
                      decoration: const InputDecoration(
                        labelText: 'Anniversaire',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value!.isEmpty
                          ? 'L\'anniversaire est obligatoire.'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Adresse',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'L\'adresse est obligatoire.' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _postalCodeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Code postal',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value!.isEmpty
                          ? 'Le code postal est obligatoire.'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _cityController,
                      decoration: const InputDecoration(
                        labelText: 'Ville',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'La ville est obligatoire.' : null,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _saveUserProfile,
                      child: const Text('Valider'),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _logout,
                      child: const Text(
                        'Se déconnecter',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Naviguer vers l'écran d'ajout de vêtement
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AddClothingScreen()),
                        );
                      },
                      child: const Text("Ajouter un vêtement"),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _birthdayController.dispose();
    _addressController.dispose();
    _postalCodeController.dispose();
    _cityController.dispose();
    super.dispose();
  }
}
