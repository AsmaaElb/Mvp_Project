import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class AjouterVetementPage extends StatefulWidget {
  const AjouterVetementPage({Key? key}) : super(key: key);

  @override
  _AjouterVetementPageState createState() => _AjouterVetementPageState();
}

class _AjouterVetementPageState extends State<AjouterVetementPage> {
  final TextEditingController _titreController = TextEditingController();
  final TextEditingController _tailleController = TextEditingController();
  final TextEditingController _marqueController = TextEditingController();
  final TextEditingController _prixController = TextEditingController();
  String _categorie = 'Catégorie indéfinie';
  File? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _categorie = _detectCategoryFromImage(
            _image!); // Catégorie détectée automatiquement
      });
    }
  }

  // Cette fonction peut être remplacée par une détection d'image plus complexe
  String _detectCategoryFromImage(File image) {
    // Exemple simple de logique de détection, à adapter selon les besoins
    return 'Haut'; // Par exemple, détection basée sur l'image
  }

  Future<void> _saveVetement() async {
    if (_image == null ||
        _titreController.text.isEmpty ||
        _prixController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tous les champs sont obligatoires')),
      );
      return;
    }

    // Conversion de l'image en base64
    String imageBase64 = base64Encode(await _image!.readAsBytes());

    // Ajout du vêtement dans Firestore
    await FirebaseFirestore.instance.collection('vetements').add({
      'titre': _titreController.text,
      'categorie': _categorie,
      'taille': _tailleController.text,
      'marque': _marqueController.text,
      'prix': double.tryParse(_prixController.text) ??
          0.0, // Assurez-vous de gérer les erreurs
      'imageBase64': imageBase64,
    });

    // Message de succès et retour à la page précédente
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Vêtement ajouté avec succès !')),
    );

    Navigator.pop(context); // Retour à la page précédente après l'ajout
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ajouter un vêtement"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: _image == null
                  ? Container(
                      width: 100,
                      height: 100,
                      color: Colors.grey[300],
                      child: const Icon(Icons.add_a_photo),
                    )
                  : Image.file(
                      _image!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _titreController,
              decoration: const InputDecoration(labelText: 'Titre'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _tailleController,
              decoration: const InputDecoration(labelText: 'Taille'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _marqueController,
              decoration: const InputDecoration(labelText: 'Marque'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _prixController,
              decoration: const InputDecoration(labelText: 'Prix'),
              keyboardType: TextInputType.number, // Clavier numérique
            ),
            const SizedBox(height: 20),
            Text('Catégorie: $_categorie'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveVetement,
              child: const Text('Valider'),
            ),
          ],
        ),
      ),
    );
  }
}
