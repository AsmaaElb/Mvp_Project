import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:tflite/tflite.dart';

class AddVetementDialog extends StatefulWidget {
  @override
  _AddVetementDialogState createState() => _AddVetementDialogState();
}

class _AddVetementDialogState extends State<AddVetementDialog> {
  final _titreController = TextEditingController();
  final _tailleController = TextEditingController();
  final _marqueController = TextEditingController();
  final _prixController = TextEditingController();
  String? _imageBase64;
  String? _categorie;
  String _imageStatus = "Aucune image sélectionnée";

  final List<String> defaultCategories = ["Manteau", "Pantalon"];

  @override
  void initState() {
    super.initState();
    // _loadModel(); //
  }

  Future<void> _loadModel() async {
    try {
      String? result = await Tflite.loadModel(
        model: "assets/model_unquant.tflite",
        labels: "assets/labels.txt",
      );
      print("Modèle chargé : $result");
    } catch (e) {
      print("Erreur lors du chargement du modèle : $e");
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBase64 = base64Encode(bytes);
        _imageStatus = "Image sélectionnée";
        _categorie = defaultCategories[0];
      });
    } else {
      print("Aucune image sélectionnée");
    }
  }

  Future<void> _saveVetement() async {
    if (_titreController.text.isNotEmpty &&
        _tailleController.text.isNotEmpty &&
        _marqueController.text.isNotEmpty &&
        _prixController.text.isNotEmpty &&
        _imageBase64 != null &&
        _categorie != null) {
      await FirebaseFirestore.instance.collection('vetements').add({
        'titre': _titreController.text,
        'categorie': _categorie,
        'taille': _tailleController.text,
        'marque': _marqueController.text,
        'prix': double.tryParse(_prixController.text) ?? 0.0,
        'imageBase64': _imageBase64,
      });

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vêtement ajouté avec succès')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
    }
  }

  @override
  void dispose() {
    _titreController.dispose();
    _tailleController.dispose();
    _marqueController.dispose();
    _prixController.dispose();
    // Tflite.close(); //
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Ajouter un Vêtement"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titreController,
              decoration: const InputDecoration(labelText: "Titre"),
            ),
            TextFormField(
              controller: _tailleController,
              decoration: const InputDecoration(labelText: "Taille"),
            ),
            TextFormField(
              controller: _marqueController,
              decoration: const InputDecoration(labelText: "Marque"),
            ),
            TextFormField(
              controller: _prixController,
              decoration: const InputDecoration(labelText: "Prix"),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))
              ],
            ),
            const SizedBox(height: 10),
            Text("Catégorie : ${_categorie ?? 'En attente...'}"),
            Text(_imageStatus),
            const SizedBox(height: 10),
            _imageBase64 == null
                ? Container()
                : Image.memory(base64Decode(_imageBase64!)),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text("Choisir une Image"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveVetement,
              child: const Text("Valider"),
            ),
          ],
        ),
      ),
    );
  }
}
