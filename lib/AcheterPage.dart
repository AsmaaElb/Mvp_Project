import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'VetementDetailPage.dart';

class AcheterPage extends StatelessWidget {
  const AcheterPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Acheter"),
        backgroundColor: Colors.green[300],
      ),
      body: const VetementsListe(),
      backgroundColor: Colors.green[100],
    );
  }
}

class VetementsListe extends StatelessWidget {
  const VetementsListe({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('vetements').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("Aucun vêtement disponible"));
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var vetement =
                snapshot.data!.docs[index].data() as Map<String, dynamic>;

            Widget imageWidget;
            try {
              String base64String = vetement['imageBase64'] ?? '';
              if (base64String.contains(',')) {
                base64String = base64String.split(',').last;
              }

              imageWidget = Image.memory(
                base64Decode(base64String),
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.image_not_supported, size: 100);
                },
              );
            } catch (e) {
              imageWidget = const Icon(Icons.image_not_supported, size: 100);
            }

            return Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: imageWidget,
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vetement['titre'] ?? 'Titre indisponible',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.greenAccent,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Taille: ${vetement['taille'] ?? 'N/A'}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '${vetement['prix']?.toString() ?? '0'}€',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VetementDetailPage(
                              imageBase64: vetement['imageBase64'] ?? '',
                              titre: vetement['titre'] ?? 'Titre indisponible',
                              categorie: vetement['categorie'] ??
                                  'Catégorie indisponible',
                              taille: vetement['taille'] ?? 'N/A',
                              marque: vetement.containsKey('marque') &&
                                      vetement['marque'] != null
                                  ? vetement['marque']
                                  : 'Marque indisponible',
                              prix: double.tryParse(
                                      vetement['prix']?.toString() ?? '0') ??
                                  0.0,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.info),
                      label: const Text("Détails"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[400],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
