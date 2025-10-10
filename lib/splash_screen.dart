import 'package:flutter/material.dart';
import 'package:my_lu/auth/login_selection_page.dart';
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
    Timer(const Duration(seconds: 3), _goHome);
  }

  void _goHome() {
    if (!mounted) return; 
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => RegistrationPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
        
          Image.asset(
            "assets/lu.jpeg",
            fit: BoxFit.cover,
          ),

        
          Container(color: Colors.black.withOpacity(0.5)),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset("assets/logo.jpeg", height: 120),
                const SizedBox(height: 20),
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
                const Text(
                  "Connecting LU students in one place",
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
                const SizedBox(height: 40),
                const CircularProgressIndicator(color: Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
