import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
import 'registration_page.dart' hide LoginPage;
import 'home_page.dart';

void main() {
  runApp(const MyLUApp());
}

class MyLUApp extends StatelessWidget {
  const MyLUApp({super.key});

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "MyLU",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text("MyLU"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),

        
          Center(
            child: Column(
              children: [
                Image.asset(
                  "assets/logo.jpeg",
                  height: 120,
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),

          const SizedBox(height: 20),

    
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(12),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildMenuCard(
                  icon: Icons.chat,
                  title: "Chat App",
                  color: Colors.blue,
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const ChatPage()));
                  },
                ),
                _buildMenuCard(
                  icon: Icons.grade,
                  title: "Result",
                  color: Colors.green,
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const ResultPage()));
                  },
                ),
                _buildMenuCard(
                  icon: Icons.directions_bus,
                  title: "Bus Schedule",
                  color: Colors.orange,
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const BusSchedulePage()));
                  },
                ),
                _buildMenuCard(
                  icon: Icons.info,
                  title: "LU Info",
                  color: Colors.purple,
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const LUInfoPage()));
                  },
                ),
                _buildMenuCard(
                  icon: Icons.calendar_month,
                  title: "Routine",
                  color: Colors.red,
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const RoutinePage()));
                  },
                ),
                _buildMenuCard(
                  icon: Icons.settings,
                  title: "Settings",
                  color: Colors.teal,
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const SettingsPage()));
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: color),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}


class ChatPage extends StatelessWidget {
  const ChatPage({super.key});
  @override
  Widget build(BuildContext context) {
    return _buildDummyPage(context, "Chat App");
  }
}

class ResultPage extends StatelessWidget {
  const ResultPage({super.key});
  @override
  Widget build(BuildContext context) {
    return _buildDummyPage(context, "Result Page");
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
    appBar: AppBar(
      title: Text(title),
      backgroundColor: Colors.deepPurple,
    ),
    body: Center(
      child: Text(
        title,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    ),
  );
}