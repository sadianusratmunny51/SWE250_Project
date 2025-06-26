import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String userEmail = '';
  String userName = '';
  String userPhone = '';
  String imageUrl = '';

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          userEmail = doc.data()?['email'] ?? user.email ?? '';
          userName = doc.data()?['name'] ?? '';
          userPhone = doc.data()?['phone'] ?? '';
          imageUrl = doc.data()?['imageUrl'] ?? '';
        });
      } else {
        await _firestore.collection('users').doc(user.uid).set({
          'email': user.email,
          'name': '',
          'phone': '',
          'imageUrl': '',
        });
        setState(() {
          userEmail = user.email ?? '';
          userName = '';
          userPhone = '';
          imageUrl = '';
        });
      }
    }
  }

  Future<void> _pickAndUploadImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    final imageBytes = await pickedFile.readAsBytes();
    final base64Image = base64Encode(imageBytes);

    final response = await http.post(
      Uri.parse('https://api.imgur.com/3/image'),
      headers: {
        'Authorization': 'Client-ID 005bd33cc29e3ed',
      },
      body: {
        'image': base64Image,
        'type': 'base64',
      },
    );

    final data = json.decode(response.body);
    if (response.statusCode == 200 && data['success'] == true) {
      final link = data['data']['link'];
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'imageUrl': link,
        });
        setState(() {
          imageUrl = link;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image upload failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Column(
        children: [
          _buildTopProfileSection(),
          Expanded(child: _buildBottomContent()),
        ],
      ),
    );
  }

  Widget _buildBottomContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          SizedBox(height: 20),
          _buildActionChips(),
          SizedBox(height: 20),
          _buildInfoFields(),
          // if (imageUrl.isNotEmpty)
          //   Container(
          //     margin: EdgeInsets.symmetric(vertical: 20),
          //     height: 150,
          //     width: 150,
          //     decoration: BoxDecoration(
          //       borderRadius: BorderRadius.circular(16),
          //       image: DecorationImage(
          //         image: NetworkImage(imageUrl),
          //         fit: BoxFit.cover,
          //       ),
          //     ),
          //   ),
          SizedBox(height: 30),
          _buildLogoutButton(),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTopProfileSection() {
    return Container(
      width: double.infinity,
      height: 260,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blueAccent, Colors.indigoAccent],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 45,
            backgroundImage: imageUrl.isNotEmpty
                ? NetworkImage(imageUrl)
                : AssetImage("assets/images/image.jpeg") as ImageProvider,
          ),
          SizedBox(height: 12),
          Text(
            userName.isEmpty ? "No Name" : userName,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            userEmail,
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildActionChips() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _roundedOption("Edit profile", Icons.edit, () {
          _showEditProfileSheet(context);
        }),
        _roundedOption("Edit image", Icons.image, () {
          _pickAndUploadImage();
        }),
        _roundedOption("Help", Icons.help_outline, () {}),
      ],
    );
  }

  Widget _roundedOption(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurpleAccent, Colors.indigoAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 6,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              padding: EdgeInsets.all(8),
              child: Icon(icon, size: 22, color: Colors.white),
            ),
            SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoFields() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Personal Info",
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16),
          _infoCard("User name", userName),
          _infoCard("Email", userEmail),
          _infoCard("Phone", userPhone),
        ],
      ),
    );
  }

  Widget _infoCard(String title, String value) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 4)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(color: Colors.white, fontSize: 14),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: [Colors.teal, Colors.teal],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.5),
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: () async {
          await _auth.signOut();
          // Navigate to login page if needed
        },
        icon: Icon(Icons.logout, color: Colors.white),
        label: Text(
          "Logout",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }

  void _showEditProfileSheet(BuildContext context) {
    final nameController = TextEditingController(text: userName);
    final phoneController = TextEditingController(text: userPhone);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      backgroundColor: Colors.grey[900],
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: EdgeInsets.only(
                top: 20,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 5,
                    margin: EdgeInsets.only(bottom: 15),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  Text(
                    "Edit Profile",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 25),
                  TextField(
                    controller: nameController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Name',
                      labelStyle: TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.grey[850],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 20,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Phone',
                      labelStyle: TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.grey[850],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 20,
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final user = _auth.currentUser;
                        if (user != null) {
                          await _firestore
                              .collection('users')
                              .doc(user.uid)
                              .update({
                            'name': nameController.text,
                            'phone': phoneController.text,
                          });

                          setState(() {
                            userName = nameController.text;
                            userPhone = phoneController.text;
                          });

                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 6,
                        shadowColor: Colors.tealAccent,
                      ),
                      child: Text(
                        "Save",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
