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
  final _formKey = GlobalKey<FormState>();
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  final nameController = TextEditingController();
  final deptController = TextEditingController();
  final designationController = TextEditingController();
  final bioController = TextEditingController();

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
        designationController.text = data['designation'] ?? '';
        bioController.text = data['bio'] ?? '';
        imageUrl = data['avatar'];
      });
    }
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    setState(() => isLoading = true);

    final uploadUrl = Uri.parse("https://api.cloudinary.com/v1_1/daaz6phgh/image/upload");
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
  Future<String> uploadToCloudinary(File imageFile) async {
  const cloudName = 'daaz6phgh';
  const uploadPreset = 'unsigned_upload';
  final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

  var request = http.MultipartRequest('POST', url)
    ..fields['upload_preset'] = uploadPreset
    ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

  var response = await request.send();
  var responseData = await response.stream.bytesToString();
  var jsonData = json.decode(responseData);
  return jsonData['secure_url'];
}

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    final user = _auth.currentUser;
    if (user == null) return;

    setState(() => isLoading = true);

    await _firestore.collection('users').doc(user.uid).update({
      'name': nameController.text.trim(),
      'department': deptController.text.trim(),
      'designation': designationController.text.trim(),
      'bio': bioController.text.trim(),
      'avatar': imageUrl ?? '',
      'updatedAt': FieldValue.serverTimestamp(),
    });

    setState(() => isLoading = false);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Profile updated successfully!")));
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
        final avatar = (data['avatar'] ?? '') as String;
        final name = (data['name'] ?? '') as String;
        final dept = (data['dept'] ?? '') as String;
        final worksAt = (data['worksAt'] ?? '') as String;

        return Scaffold(
          body: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color.fromARGB(255, 26, 16, 37), Color.fromARGB(255, 24, 82, 182)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 50),
                    Center(
                      child: CircleAvatar(
                        radius: 70,
                        backgroundColor: Colors.white,
                        backgroundImage: avatar.isNotEmpty ? NetworkImage(avatar) : null,
                        child: avatar.isEmpty
                            ? const Icon(Icons.person, size: 60, color: Colors.grey)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      dept,
                      style: const TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      worksAt,
                      style: const TextStyle(fontSize: 15, color: Colors.white70),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      ),
                      icon: const Icon(Icons.arrow_back, color: Colors.deepPurpleAccent),
                      label: const Text(
                        "Back",
                        style: TextStyle(color: Colors.deepPurpleAccent),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}