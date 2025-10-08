import 'package:flutter/material.dart';
import 'package:my_lu/chat_app/chat_page.dart' hide getChatId;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_lu/chat_app/user_list.dart';
import 'package:my_lu/result_app/result_page.dart';
import 'package:my_lu/notice_page.dart';
import 'package:my_lu/items/bus_schedule_page.dart';
import 'package:my_lu/campus_map/map_selection_page.dart';
import 'package:my_lu/lu_info/lu_info_page.dart';
import 'package:my_lu/chat_app/user_list.dart';

class RoutinePage extends StatelessWidget {
  const RoutinePage({super.key});
  @override
  Widget build(BuildContext context) {
    return _buildDummyPage(context, "Routine Page");
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
                            MaterialPageRoute(builder: (_) => UsersList()),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please log in first"),
                            ),
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
                            builder: (context) => BusSchedulePage(),
                          ),
                        );
                      },
                    ),
                    _buildMenuCard(
                      title: "Campus Map",
                      image: "assets/campus_map.png", // add your own image in assets folder
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const MapSelectionPage()),
                        );
                      },
                    ),
                    _buildMenuCard(
                      title: "LU Info",
                      image: "assets/info.png",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => LuInfoPage()),
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
                      image: "assets/notice.webp",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NoticePage(),
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


