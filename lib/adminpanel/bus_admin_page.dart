import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_lu/adminpanel/admin_add_edit_page.dart';

class BusAdminPage extends StatelessWidget {
  const BusAdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    final buses = FirebaseFirestore.instance
        .collection('bus_schedule')
        .orderBy('timestamp', descending: true)
        .snapshots();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text('Manage Bus Schedule'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.teal,
        icon: const Icon(Icons.add),
        label: const Text("Add Bus Schedule"),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AdminAddEditPage(collection: 'bus_schedule'),
            ),
          );
        },
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: buses,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No bus schedules available"));
          }

          final data = snapshot.data!.docs;

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final doc = data[index];
              final bus = doc.data() as Map<String, dynamic>;

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.teal.withOpacity(0.15),
                      blurRadius: 6,
                      offset: const Offset(2, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bus['route'] ?? 'Unknown Route',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.teal,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        bus['time'] ?? 'No Time',
                        style: TextStyle(
                            color: Colors.grey.shade700, fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        bus['days'] ?? '',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600),
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon:
                                const Icon(Icons.edit, color: Colors.blueAccent),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AdminAddEditPage(
                                    collection: 'bus_schedule',
                                    existingData: bus,
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
                                  .collection('bus_schedule')
                                  .doc(doc.id)
                                  .delete();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
