import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FacultyInfoPage extends StatefulWidget {
  const FacultyInfoPage({super.key});

  @override
  State<FacultyInfoPage> createState() => _FacultyInfoPageState();
}

class _FacultyInfoPageState extends State<FacultyInfoPage> {
  String? selectedDepartment; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Faculty Information',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 4,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade50, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: selectedDepartment == null
            ? _buildDepartmentList()
            : _buildFacultyList(selectedDepartment!),
      ),
    );
  }

  Widget _buildDepartmentList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('faculty').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final departments = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: departments.length,
          itemBuilder: (context, index) {
            final deptName = departments[index].id;

            return Card(
              color: Colors.deepPurple.shade100,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              elevation: 3,
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(
                  deptName,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600),
                ),
                trailing: const Icon(Icons.arrow_forward_ios_rounded,
                    color: Colors.deepPurple),
                onTap: () {
                  setState(() {
                    selectedDepartment = deptName;
                  });
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFacultyList(String department) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('faculty')
          .doc(department)
          .collection('faculty_list')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final facultyDocs = snapshot.data!.docs;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: Colors.deepPurple),
                    onPressed: () {
                      setState(() {
                        selectedDepartment = null;
                      });
                    },
                  ),
                  Text(
                    department,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: facultyDocs.length,
                itemBuilder: (context, index) {
                  final data =
                      facultyDocs[index].data() as Map<String, dynamic>;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    elevation: 3,
                    child: ListTile(
                      leading: const Icon(Icons.person,
                          color: Colors.deepPurple, size: 32),
                      title: Text(
                        data['name'] ?? '',
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        '${data['designation'] ?? ''}\n${data['email'] ?? ''}',
                        style:
                            const TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
