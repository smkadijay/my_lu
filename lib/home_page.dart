import 'package:flutter/material.dart';
import 'package:my_lu/chat_app/chat_page.dart' hide getChatId;
import 'package:my_lu/chat_app/chat_input.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_lu/chat_app/chat_utils.dart';
import 'package:my_lu/chat_app/user_list.dart';
import 'package:my_lu/result_app/result_page.dart';




class DummyChatPage extends StatelessWidget {
  const DummyChatPage({super.key});
  @override
  Widget build(BuildContext context) {
    return _buildDummyPage(context, "Chat App (Dummy)");
  }
}


class BusSchedulePage extends StatelessWidget {
  const BusSchedulePage({super.key});
  @override
  Widget build(BuildContext context) {
    return _buildDummyPage(context, "Bus Schedule");
  }
}

class LUInfoPage extends StatelessWidget {
  const LUInfoPage({super.key});
  @override
  Widget build(BuildContext context) {
    return _buildDummyPage(context, "LU Info");
  }
}

class RoutinePage extends StatelessWidget {
  const RoutinePage({super.key});
  @override
  Widget build(BuildContext context) {
    return _buildDummyPage(context, "Routine Page");
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return _buildDummyPage(context, "Settings Page");
  }
}

Widget _buildDummyPage(BuildContext context, String title) {
  return Scaffold(
    appBar: AppBar(backgroundColor: Colors.deepPurple, title: Text(title)),
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
                backgroundColor: Colors.transparent, // transparent appbar
                expandedHeight: 140, // ছোট height
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        "assets/campus.jpeg", // logo'r পিছনেও campus background
                        fit: BoxFit.cover,
                      ),
                      Container(
                        color: Colors.black.withOpacity(0.3), // dim overlay
                      ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              "assets/logo.jpeg",
                              height: 60, // ছোট logo
                            ),
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

              // Grid Menu
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => UsersListPage(),
                              ),
                            );
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ResultPage()),
                        );
                      },
                    ),

                    _buildMenuCard(
                      title: "Bus Schedule",
                      image: "assets/bus.png",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const BusSchedulePage(),
                          ),
                        );
                      },
                    ),
                    _buildMenuCard(
                      title: "LU Info",
                      image: "assets/info.png",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const LUInfoPage()),
                        );
                      },
                    ),
                    _buildMenuCard(
                      title: "Routine",
                      image: "assets/routine.webp",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RoutinePage(),
                          ),
                        );
                      },
                    ),
                    _buildMenuCard(
                      title: "Settings",
                      image: "assets/setting.jpeg",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SettingsPage(),
                          ),
                        );
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

  // Menu Card Widget
  static Widget _buildMenuCard({
    required String title,
    required String image,
    required VoidCallback onTap,
  }) {
    return Card(
      color: Colors.white.withOpacity(0.85), // semi-transparent card
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

