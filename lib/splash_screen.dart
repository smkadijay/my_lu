import 'package:flutter/material.dart';
import 'dart:async';
import 'registration_page.dart'; 

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // ৩ সেকেন্ড পরে Registration Page এ যাবে
    Timer(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const RegistrationPage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset(
            "assets/lu.jpeg", // এখানে তোমার varsity photo দিন
            fit: BoxFit.cover,
          ),

          // Transparent overlay
          Container(
            color: Colors.black.withOpacity(0.5), // Dark overlay for clarity
          ),

          // Center content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo optional (remove if not needed)
                Image.asset(
                  "assets/logo.jpeg",
                  height: 120,
                ),
                const SizedBox(height: 20),

                // Welcome Text
                Text(
                  "Welcome to My LU",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 8,
                        color: Colors.black.withOpacity(0.8),
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Small subtitle
                const Text(
                  "Connecting LU students in one place",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),

                const SizedBox(height: 40),

                // Loading indicator
                const CircularProgressIndicator(
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
