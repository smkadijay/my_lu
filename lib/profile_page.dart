import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfilePage extends StatefulWidget {
  final String userId;
  const ProfilePage({super.key, required this.userId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isEditing = false;
  bool isLoading = false; // spinner control
  File? imageFile;

  TextEditingController nameController = TextEditingController();
  TextEditingController departmentController = TextEditingController();
  TextEditingController roleController = TextEditingController();

  String avatar = "";
  String name = "";
  String department = "";
  String role = "";

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      var doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      if (doc.exists) {
        setState(() {
          name = doc['name'] ?? '';
          department = doc['department'] ?? '';
          role = doc['role'] ?? '';
          avatar = doc['avatar'] ?? '';
          nameController.text = name;
          departmentController.text = department;
          roleController.text = role;
        });
      }
    } catch (e) {
      print("Firestore fetch error: $e");
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String?> uploadToCloudinary(File image) async {
    try {
      String publicId =
          "chat_files/${widget.userId}_${DateTime.now().millisecondsSinceEpoch}";

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.cloudinary.com/v1_1/daaz6phgh/image/upload'),
      );
      request.fields['upload_preset'] = 'unsigned_upload';
      request.fields['public_id'] = publicId;
      request.files.add(await http.MultipartFile.fromPath('file', image.path));

      final response = await request.send();
      final resStr = await response.stream.bytesToString();
      final resJson = json.decode(resStr);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return resJson['secure_url'];
      } else {
        print("Cloudinary error: $resStr");
        return null;
      }
    } catch (e) {
      print("Upload exception: $e");
      return null;
    }
  }

  Future<void> saveProfile() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    String imageUrl = avatar;

    // Upload new image if selected
    if (imageFile != null) {
      String? uploadedUrl = await uploadToCloudinary(imageFile!);
      if (uploadedUrl != null) {
        imageUrl = uploadedUrl;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Image upload failed!")),
        );
        setState(() {
          isLoading = false;
        });
        return;
      }
    }

    try {
      // Update Firestore (merge in case doc doesn't exist)
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .set({
        'name': nameController.text,
        'department': departmentController.text,
        'role': roleController.text,
        'avatar': imageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      setState(() {
        name = nameController.text;
        department = departmentController.text;
        role = roleController.text;
        avatar = imageUrl;
        isEditing = false;
        isLoading = false;
        imageFile = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully!")),
      );
    } catch (e) {
      print("Firestore update error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile update failed!")),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Wavy top background
          ClipPath(
            clipper: WaveClipper(),
            child: Container(
              height: 300,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.purple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          // Profile content
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Profile picture
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 70,
                        backgroundImage: imageFile != null
                            ? FileImage(imageFile!)
                            : (avatar.isNotEmpty
                                ? NetworkImage(avatar)
                                : const AssetImage('assets/avatar.png')
                                    as ImageProvider),
                      ),
                      if (isEditing)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            backgroundColor: Colors.purple,
                            child: IconButton(
                              icon: const Icon(Icons.camera_alt,
                                  color: Colors.white),
                              onPressed: pickImage,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Profile info
                  isEditing ? buildEditFields() : buildProfileView(),
                  const SizedBox(height: 20),
                  // Edit/Save button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.purple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 15),
                    ),
                    onPressed: () {
                      if (isEditing) {
                        saveProfile();
                      } else {
                        setState(() {
                          isEditing = true;
                        });
                      }
                    },
                    child: isLoading
                        ? const SizedBox(
                            width: 25,
                            height: 25,
                            child: CircularProgressIndicator(
                                color: Colors.purple, strokeWidth: 2.5),
                          )
                        : Text(isEditing ? "Save" : "Edit Profile"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildEditFields() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          buildTextField("Name", nameController),
          const SizedBox(height: 10),
          buildTextField("Department", departmentController),
          const SizedBox(height: 10),
          buildTextField("Role (Student/Teacher)", roleController),
        ],
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white70,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }

  Widget buildProfileView() {
    return Column(
      children: [
        Text(
          name,
          style: const TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 2, 2, 2)),
        ),
        const SizedBox(height: 5),
        Text(
          department,
          style: const TextStyle(fontSize: 18, color: Color.fromARGB(179, 3, 3, 3)),
        ),
        const SizedBox(height: 5),
        Text(
          role,
          style: const TextStyle(fontSize: 18, color: Color.fromARGB(179, 2, 2, 2)),
        ),
      ],
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 50);
    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2, size.height - 50);
    var secondControlPoint = Offset(3 * size.width / 4, size.height - 150);
    var secondEndPoint = Offset(size.width, size.height - 50);

    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
