import 'package:flutter/material.dart';
import 'package:my_lu/chat_app/chat_page.dart' hide getChatId;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_lu/chat_app/user_list.dart';
import 'package:my_lu/items/notice_list_page.dart';
import 'package:my_lu/result_app/result_page.dart';
import 'package:my_lu/items/bus_schedule_page.dart';
import 'package:my_lu/campus_map/map_selection_page.dart';
import 'package:my_lu/lu_info/lu_info_page.dart';
import 'package:my_lu/profile_page.dart';
import 'package:my_lu/chat_app/message_request_page.dart';
import 'package:my_lu/chat_app/privacy_settings_page.dart';

class RoutinePage extends StatelessWidget {
  const RoutinePage({super.key});
  @override
  Widget build(BuildContext context) {
    return _buildDummyPage(context, "Routine Page");
  }
}

Widget _buildDummyPage(BuildContext context, String title) {
  return Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.deepPurple,
      title: Text(title),
      actions: [
        IconButton(
          icon: const Icon(Icons.person, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfilePage()),
            );
          },
        ),
      ],
    ),
    body: Center(
      child: Text(
        title,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ Drawer should be here, not inside CustomScrollView
      drawer: SafeArea(
        child: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.deepPurple,
                ),
                child: Text(
                  'Menu',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.security),
                title: const Text('Privacy Settings'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacySettingsPage()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.mail_outline),
                title: const Text('Message Requests'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const MessageRequestsPage()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),

      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image (fixed)
          Image.asset("assets/campus.jpeg", fit: BoxFit.cover),

          // Transparent overlay for readability
          Container(color: Colors.black.withOpacity(0.25)),

          // Content (scrollable)
          CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.transparent,
                expandedHeight: 140,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset("assets/campus.jpeg", fit: BoxFit.cover),
                      Container(color: Colors.black.withOpacity(0.3)),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset("assets/logo.jpeg", height: 60),
                            const SizedBox(height: 5),
                            const Text(
                              "Leading University",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Builder(
                  builder: (context) {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user == null) return const SizedBox();
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Card(
                        color: Colors.white.withOpacity(0.85),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: const CircleAvatar(child: Icon(Icons.person)),
                          title: Text(user.email ?? 'No Email'),
                          subtitle: const Text('My Profile'),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ProfilePage()),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // ✅ Only Slivers inside CustomScrollView
              SliverPadding(
                padding: const EdgeInsets.all(12),
                sliver: SliverGrid.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: [
                    _buildMenuCard(
                      title: "Chat App",
                      image: "assets/chat.jpeg",
                      onTap: () {
                        final user = FirebaseAuth.instance.currentUser;
                        if (user != null) {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const UsersList()));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Please log in first")),
                          );
                        }
                      },
                    ),
                    _buildMenuCard(
                      title: "Result",
                      image: "assets/result.jpeg",
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const ResultPage()));
                      },
                    ),
                    _buildMenuCard(
                      title: "Bus Schedule",
                      image: "assets/bus.png",
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => BusSchedulePage()));
                      },
                    ),
                    _buildMenuCard(
                      title: "Campus Map",
                      image: "assets/campus_map.png",
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const MapSelectionPage()));
                      },
                    ),
                    _buildMenuCard(
                      title: "LU Info",
                      image: "assets/info.png",
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => LuInfoPage()));
                      },
                    ),
                    _buildMenuCard(
                      title: "Routine",
                      image: "assets/routine.webp",
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const RoutinePage()));
                      },
                    ),
                    _buildMenuCard(
                      title: "Notice",
                      image: "assets/notice.webp",
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const NoticeListPage()));
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  

  static Widget _buildMenuCard({
    required String title,
    required String image,
    required VoidCallback onTap,
  }) {
    return Card(
      color: Colors.white.withOpacity(0.85),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 5,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(image, fit: BoxFit.cover),
            Container(color: Colors.black.withOpacity(0.4)),
            Center(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
