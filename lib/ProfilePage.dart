import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mvp_app/AddVetementDialog.dart';
import 'login_screen.dart';
import 'dart:convert';

class ProfilePage extends StatefulWidget {
  final String uid;

  const ProfilePage({Key? key, required this.uid}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? userData;
  bool isLoading = true;

  late TextEditingController loginController;
  late TextEditingController birthdayController;
  late TextEditingController adressController;
  late TextEditingController postalCodeController;
  late TextEditingController cityController;
  late TextEditingController newPasswordController;

  @override
  void initState() {
    super.initState();
    loginController = TextEditingController();
    birthdayController = TextEditingController();
    adressController = TextEditingController();
    postalCodeController = TextEditingController();
    cityController = TextEditingController();
    newPasswordController = TextEditingController();

    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      String email = currentUser?.email ?? 'Non disponible';

      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();

      if (userSnapshot.exists && userSnapshot.data() != null) {
        setState(() {
          userData = userSnapshot.data() as Map<String, dynamic>?;

          loginController.text = email;
          birthdayController.text = userData?['birthday'] ?? 'Non disponible';
          adressController.text = userData?['address'] ?? 'Non disponible';
          postalCodeController.text =
              userData?['postalCode'] ?? 'Non disponible';
          cityController.text = userData?['city'] ?? 'Non disponible';

          // Décodage du mot de passe haché s'il est présent
          if (userData?['passwordHash'] != null) {
            newPasswordController.text =
                utf8.decode(base64.decode(userData!['passwordHash']));
          }

          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _updateUserData() async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .update({
        'address': adressController.text,
        'birthday': birthdayController.text,
        'postalCode': postalCodeController.text,
        'city': cityController.text,
      });

      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null && newPasswordController.text.isNotEmpty) {
        await currentUser.updatePassword(newPasswordController.text);
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.uid)
            .update({
          'passwordHash':
              base64.encode(utf8.encode(newPasswordController.text)),
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mise à jour réussie !')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la mise à jour : $e')),
      );
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  Future<void> _showAddVetementDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddVetementDialog();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil Utilisateur"),
        centerTitle: true,
        backgroundColor: Colors.green[300],
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.check, color: Colors.white),
            label: const Text(
              'Valider',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: _updateUserData,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _buildTextField(
                    controller: loginController,
                    labelText: 'Login',
                    icon: Icons.person,
                    readOnly: true,
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(
                    controller: birthdayController,
                    labelText: 'Anniversaire',
                    icon: Icons.calendar_today,
                  ),
                  _buildTextField(
                    controller: adressController,
                    labelText: 'Adresse',
                    icon: Icons.home,
                  ),
                  _buildTextField(
                    controller: postalCodeController,
                    labelText: 'Code Postal',
                    icon: Icons.location_on,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                  _buildTextField(
                    controller: cityController,
                    labelText: 'Ville',
                    icon: Icons.location_city,
                  ),
                  _buildTextField(
                    controller: newPasswordController,
                    labelText: 'Password',
                    icon: Icons.lock,
                    obscureText: true,
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: _showAddVetementDialog,
                        child: const Text('Ajouter un Vêtement'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[300],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 20),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _logout,
                        child: const Text('Se déconnecter'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 20),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: const TextStyle(color: Colors.green),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.green[200]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.green[300]!),
          ),
          prefixIcon: Icon(icon, color: Colors.green),
        ),
      ),
    );
  }
}
