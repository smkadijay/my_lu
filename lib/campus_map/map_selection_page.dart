import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';


class MapSelectionPage extends StatelessWidget {
  const MapSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Campus Map"),
        backgroundColor: const Color.fromARGB(255, 53, 212, 226),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal, Color.fromARGB(255, 138, 236, 249)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.map, size: 100, color: Colors.white),
              const SizedBox(height: 20),
              const Text(
                "Explore the Campus",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Choose how you'd like to view the map:",
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                icon: Icon(Icons.map_outlined, color: const Color.fromARGB(255, 13, 238, 246)),
                label: Text("Open in Google Maps"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                onPressed: () async {
                  final url = Uri.parse("https://www.google.com/maps/search/?api=1&query=Leading+University+Sylhet");
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Could not open Google Maps")),
                    );
                  }
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  // TODO: open offline custom map
                },
                icon: const Icon(Icons.map_outlined),
                label: const Text("Open Offline Map"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
