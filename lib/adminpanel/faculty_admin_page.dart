import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_lu/adminpanel/admin_add_edit_page.dart';

class FacultyAdminPage extends StatelessWidget {
  const FacultyAdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    final faculties = FirebaseFirestore.instance
        .collection('faculty')
        .orderBy('timestamp', descending: true)
        .snapshots();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: const Text('Manage Faculty'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.indigo,
        icon: const Icon(Icons.add),
        label: const Text("Add Faculty"),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AdminAddEditPage(collection: 'faculty'),
            ),
          );
        },
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: faculties,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No faculty info available"));
          }

          final data = snapshot.data!.docs;

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.8,
            ),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final doc = data[index];
              final faculty = doc.data() as Map<String, dynamic>;
              final imageUrl = faculty['imageUrl'] ?? '';

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.indigo.withOpacity(0.15),
                      blurRadius: 6,
                      offset: const Offset(2, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(16)),
                      child: imageUrl.isNotEmpty
                          ? Image.network(imageUrl,
                              height: 120, fit: BoxFit.cover)
                          : Container(
                              height: 120,
                              color: Colors.indigo.shade50,
                              child: const Icon(Icons.person,
                                  size: 50, color: Colors.indigo),
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            faculty['name'] ?? 'No name',
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            faculty['department'] ?? 'Unknown Department',
                            style: TextStyle(
                                color: Colors.grey.shade800, fontSize: 13),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            faculty['email'] ?? '',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey.shade600),
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit,
                                    color: Colors.blueAccent),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => AdminAddEditPage(
                                        collection: 'faculty',
                                        existingData: faculty,
                                        docId: doc.id,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.redAccent),
                                onPressed: () async {
                                  await FirebaseFirestore.instance
                                      .collection('faculty')
                                      .doc(doc.id)
                                      .delete();
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
