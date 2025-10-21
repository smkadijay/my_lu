import 'package:flutter/material.dart';
import 'package:my_lu/chat_app/chat_list_page.dart';
import 'package:my_lu/chat_app/chat_page.dart' hide getChatId;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_lu/chat_app/chat_list_page.dart';
import 'package:my_lu/items/notice_list_page.dart';
import 'package:my_lu/result_app/result_page.dart';
import 'package:my_lu/items/bus_schedule_page.dart';
import 'package:my_lu/campus_map/map_selection_page.dart';
import 'package:my_lu/lu_info/lu_info_page.dart';
import 'package:my_lu/profile_page.dart';
import 'package:my_lu/chat_app/message_request_page.dart';
import 'package:my_lu/chat_app/privacy_settings_page.dart';

Widget _buildDummyPage(BuildContext context, String title) {
  return Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.deepPurple,
      title: Text(title),
      actions: [
  StreamBuilder<DocumentSnapshot>(
    stream: FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).snapshots(),
    builder: (context, snap) {
      if (!snap.hasData) {
        return Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: CircleAvatar(backgroundColor: Colors.grey.shade300, child: Icon(Icons.person, color: Colors.white)),
        );
      }
      final data = snap.data!.data() as Map<String, dynamic>? ?? {};
      final avatar = (data['avatar'] ?? '') as String;
      final name = (data['name'] ?? '') as String;
      if (avatar.isNotEmpty) {
        return Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage(userId: ''))),
            child: CircleAvatar(radius: 18, backgroundImage: NetworkImage(avatar)),
          ),
        );
      } else {
        final initials = (name.isNotEmpty ? name[0].toUpperCase() : '?');
        final color = Colors.primaries[name.isNotEmpty ? name.codeUnitAt(0) % Colors.primaries.length : 0];
        return Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage(userId: '',))),
            child: CircleAvatar(radius: 18, backgroundColor: color.shade300, child: Text(initials, style: const TextStyle(color: Colors.white))),
          ),
        );
      }
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
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      drawer: SafeArea(
        child: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(color: Colors.deepPurple),
                child: Text('Menu',
                    style: TextStyle(color: Colors.white, fontSize: 20)),
              ),
              ListTile(
                leading: const Icon(Icons.security),
                title: const Text('Privacy Settings'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const PrivacySettingsPage()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.mail_outline),
                title: const Text('Message Requests'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const MessageRequestPage(currentUserId: '',)));
                },
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset("assets/campus.jpeg", fit: BoxFit.cover),
          Container(color: Colors.black.withOpacity(0.25)),

          CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.transparent,
                expandedHeight: 260,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset("assets/campus.jpeg", fit: BoxFit.cover),
                      Container(color: Colors.black.withOpacity(0.5)),
                      Column(
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
                          const SizedBox(height: 15),
                          
                          StreamBuilder<DocumentSnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('users')
                                .doc(uid)
                                .snapshots(),
                            builder: (context, snap) {
                              if (!snap.hasData) {
                                return const CircularProgressIndicator(
                                    color: Colors.white);
                              }
                              final data =
                                  snap.data!.data() as Map<String, dynamic>? ?? {};
                              final avatar = (data['avatar'] ?? '') as String;
                              final name = (data['name'] ?? '') as String;

                              return Column(
                                children: [
                                  CircleAvatar(
                                    radius: 35,
                                    backgroundColor: Colors.white,
                                    backgroundImage:
                                        avatar.isNotEmpty ? NetworkImage(avatar) : null,
                                    child: avatar.isEmpty
                                        ? const Icon(Icons.person,
                                            size: 40, color: Colors.grey)
                                        : null,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    name.isNotEmpty ? name : 'Student',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.deepPurpleAccent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 24, vertical: 8),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => ProfilePage(userId: uid)),
                                      );
                                    },
                                    child: const Text(
                                      "View Profile",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              
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
                          Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const ChatListPage()));
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
                        Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const ResultPage()));
                      },
                    ),
                    _buildMenuCard(
                      title: "Bus Schedule",
                      image: "assets/bus.png",
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (_) => BusSchedulePage()));
                      },
                    ),
                    _buildMenuCard(
                      title: "Campus Map",
                      image: "assets/campus_map.png",
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const MapSelectionPage()));
                      },
                    ),
                    _buildMenuCard(
                      title: "LU Info",
                      image: "assets/info.png",
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (_) => LuInfoPage()));
                      },
                    ),
                    _buildMenuCard(
                      title: "Notice",
                      image: "assets/notice.webp",
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const NoticeListPage()));
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 5,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(image, fit: BoxFit.cover),
            // ignore: deprecated_member_use
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
  Widget _buildMenuCard({
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
