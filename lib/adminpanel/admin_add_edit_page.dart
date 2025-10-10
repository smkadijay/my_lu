import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminAddEditPage extends StatefulWidget {
  final String collection;
  final Map<String, dynamic>? existingData;
  final String? docId;

  const AdminAddEditPage({
    super.key,
    required this.collection,
    this.existingData,
    this.docId,
  });

  @override
  State<AdminAddEditPage> createState() => _AdminAddEditPageState();
}

class _AdminAddEditPageState extends State<AdminAddEditPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  File? _selectedImage;
  bool _loading = false;

  final cloudName = "daaz6phgh"; // তোমার Cloudinary cloud name
  final uploadPreset = "unsigned_upload"; // তোমার upload preset name

  @override
  void initState() {
    super.initState();
    if (widget.existingData != null) {
      _titleController.text = widget.existingData!['title'] ?? '';
      _descController.text = widget.existingData!['description'] ?? '';
      _dateController.text = widget.existingData!['date'] ?? '';
    }
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  Future<String?> _uploadToCloudinary(File image) async {
    final url = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");
    final request = http.MultipartRequest("POST", url)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath("file", image.path));

    final response = await request.send();
    if (response.statusCode == 200) {
      final data = json.decode(await response.stream.bytesToString());
      return data['secure_url'];
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Image upload failed")),
      );
      return null;
    }
  }

  Future<void> _saveData() async {
    if (_titleController.text.trim().isEmpty) return;

    setState(() => _loading = true);
    String? imageUrl = widget.existingData?['imageUrl'];

    if (_selectedImage != null) {
      imageUrl = await _uploadToCloudinary(_selectedImage!);
    }

    final data = {
      'title': _titleController.text.trim(),
      'description': _descController.text.trim(),
      'date': _dateController.text.trim(),
      'imageUrl': imageUrl ?? '',
      'timestamp': FieldValue.serverTimestamp(),
    };

    try {
      if (widget.docId != null) {
        await FirebaseFirestore.instance
            .collection(widget.collection)
            .doc(widget.docId)
            .update(data);
      } else {
        await FirebaseFirestore.instance.collection(widget.collection).add(data);
      }

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Saved successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.docId == null ? "Add New" : "Edit Data"),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: "Description"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _dateController,
              decoration: const InputDecoration(labelText: "Date (optional)"),
              onTap: () async {
                FocusScope.of(context).requestFocus(FocusNode());
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (pickedDate != null) {
                  _dateController.text =
                      "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                }
              },
            ),
            const SizedBox(height: 15),
            Center(
              child: Column(
                children: [
                  _selectedImage != null
                      ? Image.file(_selectedImage!, height: 150)
                      : widget.existingData?['imageUrl'] != null &&
                              widget.existingData!['imageUrl'] != ''
                          ? Image.network(widget.existingData!['imageUrl'],
                              height: 150)
                          : const Icon(Icons.image, size: 80, color: Colors.grey),
                  TextButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.image_outlined),
                    label: const Text("Select Image"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _loading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton.icon(
                    onPressed: _saveData,
                    icon: const Icon(Icons.save),
                    label: const Text("Save"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
