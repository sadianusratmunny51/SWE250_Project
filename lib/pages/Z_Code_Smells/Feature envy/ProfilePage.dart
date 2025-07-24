import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project/pages/Profile/AboutAppPage.dart';
import 'package:project/pages/Z_Code_Smells/Feature%20envy/ProfileService.dart';
import 'package:project/pages/login.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileService _profileService = ProfileService();
  final ImagePicker _picker = ImagePicker();

  String userEmail = '';
  String userName = '';
  String userPhone = '';
  String imageUrl = '';
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final data = await _profileService.fetchUserProfile();
      setState(() {
        userEmail = data['email'] ?? '';
        userName = data['name'] ?? '';
        userPhone = data['phone'] ?? '';
        imageUrl = data['imageUrl'] ?? '';
      });
    } catch (e) {
      print("Failed to load profile: $e");
    }
  }

  Future<void> _pickAndUploadImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    final imageBytes = await pickedFile.readAsBytes();
    final link = await _profileService.uploadImage(imageBytes);

    if (link != null) {
      setState(() => imageUrl = link);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image upload failed')),
      );
    }
  }

  Future<void> _saveProfile(String name, String phone) async {
    await _profileService.updateUserProfile(name, phone);
    setState(() {
      userName = name;
      userPhone = phone;
    });
    Navigator.pop(context);
  }

  Future<void> _logout() async {
    setState(() => _isLoggingOut = true);
    try {
      await _profileService.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed: $e')),
      );
    } finally {
      setState(() => _isLoggingOut = false);
    }
  }

  void _showEditProfileSheet() {
    final nameController = TextEditingController(text: userName);
    final phoneController = TextEditingController(text: userPhone);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      backgroundColor: const Color(0xFF1A2A3A),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Edit Profile",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: "Name", labelStyle: TextStyle(color: Colors.white70)),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: "Phone", labelStyle: TextStyle(color: Colors.white70)),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async => await _saveProfile(nameController.text, phoneController.text),
                child: const Text("Save"),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text("Profile")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: imageUrl.isNotEmpty
                  ? NetworkImage(imageUrl)
                  : const AssetImage("assets/images/user_placeholder.png") as ImageProvider,
            ),
            const SizedBox(height: 10),
            Text(userName.isEmpty ? "No Name" : userName,
                style: const TextStyle(color: Colors.white, fontSize: 22)),
            Text(userEmail,
                style: const TextStyle(color: Colors.white70, fontSize: 16)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(onPressed: _showEditProfileSheet, child: const Text("Edit Profile")),
                ElevatedButton(onPressed: _pickAndUploadImage, child: const Text("Upload Image")),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutAppPage()));
                  },
                  child: const Text("About App"),
                ),
              ],
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _isLoggingOut ? null : _logout,
              icon: _isLoggingOut
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.logout),
              label: Text(_isLoggingOut ? "Logging out..." : "Logout"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            ),
          ],
        ),
      ),
    );
  }
}
