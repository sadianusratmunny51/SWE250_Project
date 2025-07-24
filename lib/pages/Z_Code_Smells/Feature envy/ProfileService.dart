
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class ProfileService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> getCurrentUser() async {
    return _auth.currentUser;
  }

  Future<Map<String, dynamic>> fetchUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) {
      final defaultData = {
        'email': user.email,
        'name': '',
        'phone': '',
        'imageUrl': '',
      };
      await _firestore.collection('users').doc(user.uid).set(defaultData);
      return defaultData;
    }
    return doc.data()!;
  }

  Future<void> updateUserProfile(String name, String phone) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    await _firestore.collection('users').doc(user.uid).update({
      'name': name,
      'name_lowercase': name.toLowerCase(),
      'phone': phone,
    });
  }

  Future<String?> uploadImage(List<int> imageBytes) async {
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
      final imageUrl = data['data']['link'];
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'imageUrl': imageUrl,
        });
      }
      return imageUrl;
    }
    return null;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
