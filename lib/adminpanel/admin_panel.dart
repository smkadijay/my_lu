import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_add_edit_page.dart';
import 'notice_admin_page.dart';
import 'faculty_admin_page.dart';
import 'bus_admin_page.dart';

class AdminPanelPage extends StatefulWidget {
  const AdminPanelPage({super.key});

  @override
  State<AdminPanelPage> createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage> {
  int totalUsers = 0;
  int totalNotices = 0;
  int totalBusSchedules = 0;
  int totalFaculties = 0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadCounts();
  }

  Future<void> _loadCounts() async {
    try {
      final usersSnap =
          await FirebaseFirestore.instance.collection('users').get();
      final noticesSnap =
          await FirebaseFirestore.instance.collection('notices').get();
      final busSnap =
          await FirebaseFirestore.instance.collection('bus_schedule').get();
      final facultySnap =
          await FirebaseFirestore.instance.collection('faculty').get();

      setState(() {
        totalUsers = usersSnap.size;
        totalNotices = noticesSnap.size;
        totalBusSchedules = busSnap.size;
        totalFaculties = facultySnap.size;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      debugPrint("Error loading admin stats: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4FB),
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: Colors.deepPurple,
        elevation: 2,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // 🧠 Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Welcome, Admin 👑",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          "Manage all sections of your university app easily.",
                          style: TextStyle(color: Colors.white70, fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 📊 Summary Cards
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildStatCard("Total Users", totalUsers, Icons.people,
                          Colors.blueAccent),
                      _buildStatCard("Notices", totalNotices,
                          Icons.notifications_active, Colors.orangeAccent),
                      _buildStatCard("Bus Schedules", totalBusSchedules,
                          Icons.directions_bus, Colors.green),
                      _buildStatCard("Faculties", totalFaculties,
                          Icons.school_rounded, Colors.purple),
                    ],
                  ),
                  const SizedBox(height: 25),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Manage Data",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // 🎨 Colorful Grid Cards (Menu)
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildMenuCard(
                        title: "Manage Notices",
                        color: Colors.deepPurple,
                        icon: Icons.article,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const NoticeAdminPage()),
                          );
                        },
                      ),
                      _buildMenuCard(
                        title: "Manage Faculty",
                        color: Colors.indigo,
                        icon: Icons.people_alt_rounded,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const FacultyAdminPage()),
                          );
                        },
                      ),
                      _buildMenuCard(
                        title: "Bus Schedule",
                        color: Colors.teal,
                        icon: Icons.directions_bus_filled,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const BusAdminPage()),
                          );
                        },
                      ),
                      _buildMenuCard(
                        title: "View Users",
                        color: Colors.pinkAccent,
                        icon: Icons.person,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ManageCollectionPage(
                                collection: 'users',
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  // 📊 Stats Card
  Widget _buildStatCard(
      String title, int count, IconData icon, Color color) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 10),
            Text(
              "$count",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  // 🎨 Menu Card (Colorful Grid)
  Widget _buildMenuCard({
    required String title,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.9), color.withOpacity(0.6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(2, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 42),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ⚙️ Generic Manage Collection Page
class ManageCollectionPage extends StatelessWidget {
  final String collection;
  const ManageCollectionPage({super.key, required this.collection});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage $collection"),
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection(collection).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text("No data found"));
          }
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              return Card(
                child: ListTile(
                  title: Text(data['title']?.toString() ?? 'Untitled'),
                  subtitle: data.containsKey('date')
                      ? Text("Date: ${data['date']}")
                      : null,
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await FirebaseFirestore.instance
                          .collection(collection)
                          .doc(docs[index].id)
                          .delete();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Deleted successfully")),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: collection == "users"
          ? null
          : FloatingActionButton(
              backgroundColor: Colors.deepPurple,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        AdminAddEditPage(collection: collection),
                  ),
                );
              },
              child: const Icon(Icons.add),
            ),
    );
  }
}
