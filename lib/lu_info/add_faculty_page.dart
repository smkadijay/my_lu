import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddFacultyPage extends StatefulWidget {
  const AddFacultyPage({super.key});

  @override
  State<AddFacultyPage> createState() => _AddFacultyPageState();
}

class _AddFacultyPageState extends State<AddFacultyPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _designationController = TextEditingController();
  final _emailController = TextEditingController();
  String? _selectedDepartment;

  final List<String> _departments = [
    'CSE',
    'EEE',
    'Civil Engineering',
    'Business Administration',
    'English',
    'Architecture',
    'Law',
    'Islamic Studies',
    'Public Health',
    'Tourism and Hospitality Management',
    'Bangla'
  ];

  Future<void> _addFaculty() async {
    if (_formKey.currentState!.validate() && _selectedDepartment != null) {
      await FirebaseFirestore.instance
          .collection('faculty')
          .doc(_selectedDepartment)
          .collection('members')
          .add({
        'name': _nameController.text.trim(),
        'designation': _designationController.text.trim(),
        'email': _emailController.text.trim(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Faculty Added Successfully!")),
      );

      _nameController.clear();
      _designationController.clear();
      _emailController.clear();
      setState(() => _selectedDepartment = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Faculty'), backgroundColor: Colors.deepPurple),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Select Department', border: OutlineInputBorder()),
                value: _selectedDepartment,
                items: _departments.map((dept) => DropdownMenuItem(value: dept, child: Text(dept))).toList(),
                onChanged: (value) => setState(() => _selectedDepartment = value),
                validator: (value) => value == null ? 'Select a department' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Faculty Name', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Enter name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _designationController,
                decoration: const InputDecoration(labelText: 'Designation', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Enter designation' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Enter email' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addFaculty,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, padding: const EdgeInsets.all(12)),
                child: const Text('Add Faculty', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
