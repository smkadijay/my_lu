import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  final nameController = TextEditingController();
  final deptController = TextEditingController();

  String? imageUrl;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        nameController.text = data['name'] ?? '';
        deptController.text = data['department'] ?? '';
        imageUrl = data['avatar'];
      });
    }
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    setState(() => isLoading = true);

    final uploadUrl =
        Uri.parse("https://api.cloudinary.com/v1_1/daaz6phgh/image/upload");
    final uploadPreset = "unsigned_upload";

    var request = http.MultipartRequest("POST", uploadUrl)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', picked.path));

    var response = await request.send();
    if (response.statusCode == 200) {
      var responseData = jsonDecode(await response.stream.bytesToString());
      setState(() => imageUrl = responseData['secure_url']);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Image upload failed!")),
      );
    }

    setState(() => isLoading = false);
  }

  Future<void> _saveProfile() async {
    final user = _auth.currentUser;
    if (user == null) return;

    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Enter your name")));
      return;
    }

    setState(() => isLoading = true);

    await _firestore.collection('users').doc(user.uid).update({
      'name': nameController.text.trim(),
      'department': deptController.text.trim(),
      'avatar': imageUrl ?? '',
      'updatedAt': FieldValue.serverTimestamp(),
    });

    setState(() => isLoading = false);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Profile updated successfully!")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff3f0ff),
      appBar: AppBar(
        title: const Text("My Profile"),
        centerTitle: true,
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickAndUploadImage,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.deepPurple[100],
                      backgroundImage:
                          imageUrl != null ? NetworkImage(imageUrl!) : null,
                      child: imageUrl == null
                          ? const Icon(Icons.camera_alt,
                              size: 40, color: Colors.white70)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Name
                  TextField(
                    controller: nameController,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple),
                    decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Full Name',
                        hintStyle: TextStyle(color: Colors.grey)),
                  ),
                  const SizedBox(height: 5),
                  // Department / Works at
                  TextField(
                    controller: deptController,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                    decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Department / Works at',
                        hintStyle: TextStyle(color: Colors.grey)),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Save Profile",
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ],
              ),
            ),
    );
  }
}
