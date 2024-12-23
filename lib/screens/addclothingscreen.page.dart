import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class AddClothingScreen extends StatefulWidget {
  const AddClothingScreen({super.key});

  @override
  _AddClothingScreenState createState() => _AddClothingScreenState();
}

class _AddClothingScreenState extends State<AddClothingScreen> {
  final _titleController = TextEditingController();
  final _sizeController = TextEditingController();
  final _brandController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();

  String? _category; // Catégorie prédite
  String? _localImagePath; // Chemin local de l'image téléchargée

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  // Charger le modèle TFLite
  Future<void> _loadModel() async {
    await Tflite.loadModel(
      model: 'lib/assets/clothing_model.tflite',
      labels: 'lib/assets/labels.txt', // Si tu as un fichier labels.txt avec les catégories
    );
  }

  // Télécharger l'image depuis l'URL
  Future<void> _downloadImage(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final documentDir = await getTemporaryDirectory();
        final filePath = '${documentDir.path}/downloaded_image.jpg';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        setState(() {
          _localImagePath = filePath;
        });
        _predictCategory(filePath);
      } else {
        throw Exception('Échec du téléchargement de l\'image.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors du téléchargement de l\'image.')),
      );
    }
  }

  // Prédire la catégorie de l'image téléchargée
  Future<void> _predictCategory(String imagePath) async {
    var prediction = await Tflite.runModelOnImage(
      path: imagePath,
      numResults: 1,
      threshold: 0.5, // Seuil de confiance
    );

    setState(() {
      _category = prediction?[0]['label'] ?? "Non déterminé";
    });
  }

  // Sauvegarder les informations dans la base de données
  void _saveClothing() {
    final clothingData = {
      'title': _titleController.text,
      'category': _category ?? "Non spécifié",
      'size': _sizeController.text,
      'brand': _brandController.text,
      'price': double.tryParse(_priceController.text),
      'imageUrl': _imageUrlController.text,
    };

    // Enregistrement dans la base de données (ex. Firestore)
    // Firestore.instance.collection('clothes').add(clothingData);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Vêtement ajouté avec succès !')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ajouter un vêtement")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _imageUrlController,
              decoration: const InputDecoration(
                labelText: "URL de l'image",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _localImagePath = null; // Réinitialise l'image locale
                  _category = null; // Réinitialise la catégorie
                });
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_imageUrlController.text.isNotEmpty) {
                  _downloadImage(_imageUrlController.text);
                }
              },
              child: const Text("Télécharger et prédire"),
            ),
            const SizedBox(height: 16),
            if (_localImagePath != null)
              Image.file(
                File(_localImagePath!),
                height: 150,
              ),
            if (_category != null) ...[
              const SizedBox(height: 16),
              Text("Catégorie prédite : $_category"),
            ],
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: "Titre",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _sizeController,
              decoration: const InputDecoration(
                labelText: "Taille",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _brandController,
              decoration: const InputDecoration(
                labelText: "Marque",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: "Prix",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveClothing,
              child: const Text("Valider"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _sizeController.dispose();
    _brandController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }
}
