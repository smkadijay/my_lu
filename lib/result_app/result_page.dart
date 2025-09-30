import 'package:flutter/material.dart';
import 'cgpa_calculator_page.dart';
import 'check_result_page.dart'; 

class ResultPage extends StatelessWidget {
  const ResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Results"),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildSoftCard(
              context: context,
              title: "CGPA Calculator",
              icon: Icons.calculate,
              color1: Colors.purple.shade100,
              color2: Colors.purple.shade50,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CgpaCalculatorPage()),
                );
              },
            ),
            _buildSoftCard(
              context: context,
              title: "Check Result",
              icon: Icons.check_circle_outline,
              color1: Colors.teal.shade100,
              color2: Colors.teal.shade50,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CheckResultPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSoftCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color1,
    required Color color2,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color1, color2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.deepPurple),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
