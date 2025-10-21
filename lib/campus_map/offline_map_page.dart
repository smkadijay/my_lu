import 'package:flutter/material.dart';

class OfflineMapPage extends StatefulWidget {
  const OfflineMapPage({super.key});

  @override
  State<OfflineMapPage> createState() => _OfflineMapPageState();
}

class _OfflineMapPageState extends State<OfflineMapPage> {
  final List<Map<String, dynamic>> _locations = [
    {
      'name': 'Leading University',
      'dx': 180.0,
      'dy': 250.0,
      'icon': Icons.school,
      'color': Colors.green
      
    },
    {
      'name': 'LU Cafe',
      'dx': 280.0,
      'dy': 320.0,
      'icon': Icons.coffee,
      'color': Colors.orange
    },
    {
      'name': 'Stationery',
      'dx': 230.0,
      'dy': 360.0,
      'icon': Icons.book,
      'color': Colors.blue
    },
    {
      'name': 'LU Restaurant',
      'dx': 310.0,
      'dy': 280.0,
      'icon': Icons.restaurant,
      'color': Colors.red
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Offline Campus Map"),
        backgroundColor: Colors.deepPurple,
        elevation: 4,
      ),
      body: Stack(
        children: [
          InteractiveViewer(
            minScale: 1,
            maxScale: 3,
            child: Image.asset(
              'assets/images/lu_map.png',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),

          // Location pins overlay
          ..._locations.map((loc) {
            return Positioned(
              left: loc['dx'],
              top: loc['dy'],
              child: GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      title: Text(loc['name'],
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple)),
                      content: const Text("You’re viewing this place offline."),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text("Close"),
                        ),
                      ],
                    ),
                  );
                },
                child: Icon(
                  loc['icon'],
                  color: loc['color'],
                  size: 32,
                  shadows: const [
                    Shadow(color: Colors.black54, blurRadius: 4)
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
