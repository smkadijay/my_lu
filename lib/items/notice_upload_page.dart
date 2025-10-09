import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class NoticeUploadPage extends StatefulWidget {
  const NoticeUploadPage({super.key});

  @override
  State<NoticeUploadPage> createState() => _NoticeUploadPageState();
}

class _NoticeUploadPageState extends State<NoticeUploadPage> {
  final titleController = TextEditingController();
  final dateController = TextEditingController();
  XFile? _pickedImage; // changed to XFile for better handling
  bool _isUploading = false;

  // pick image
  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);

      if (picked != null) {
        setState(() {
          _pickedImage = picked;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No image selected.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  // upload to Cloudinary + Firestore
  Future<void> _uploadNotice() async {
    if (_pickedImage == null ||
        titleController.text.isEmpty ||
        dateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and select an image!')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      const cloudName = 'daaz6phgh';
      const uploadPreset = 'unsigned_upload';

      final uri =
          Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

      var request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', _pickedImage!.path));

      final response = await request.send();

      if (response.statusCode == 200) {
        final resData = await response.stream.bytesToString();
        final data = json.decode(resData);
        final imageUrl = data['secure_url'];

        await FirebaseFirestore.instance.collection('notices').add({
          'title': titleController.text,
          'imageUrl': imageUrl,
          'date': dateController.text,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notice uploaded successfully!')),
        );

        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload error: $e')),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        title: const Text('Upload Notice', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Notice Title'),
              ),
              TextField(
                controller: dateController,
                decoration: const InputDecoration(labelText: 'Date (e.g. 8 Oct 2025)'),
              ),
              const SizedBox(height: 20),
              _pickedImage == null
                  ? const Text('No image selected.')
                  : Image.file(File(_pickedImage!.path), height: 180),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.photo),
                label: const Text('Pick Image'),
              ),
              const SizedBox(height: 20),
              _isUploading
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      onPressed: _uploadNotice,
                      icon: const Icon(Icons.cloud_upload),
                      label: const Text('Upload Notice'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
