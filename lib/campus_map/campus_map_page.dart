import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:my_lu/campus_map/offline_map_page.dart';

class CampusMapPage extends StatefulWidget {
  const CampusMapPage({super.key});

  @override
  State<CampusMapPage> createState() => _CampusMapPageState();
}

class _CampusMapPageState extends State<CampusMapPage> {
  late GoogleMapController _controller;

  final LatLng _leadingUniversity = const LatLng(24.8917, 91.8836); // LU coordinates

  final Map<String, LatLng> _places = {
    'Leading University': LatLng(24.8917, 91.8836),
    'LU Cafe': LatLng(24.8919, 91.8839),
    'Stationery Shop': LatLng(24.8920, 91.8841),
    'LU Restaurant': LatLng(24.8915, 91.8834),
  };

  Set<Marker> _createMarkers() {
    return _places.entries.map((entry) {
      BitmapDescriptor icon;

      if (entry.key.contains('Cafe')) {
        icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
      } else if (entry.key.contains('Stationery')) {
        icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
      } else if (entry.key.contains('Restaurant')) {
        icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      } else {
        icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      }

      return Marker(
        markerId: MarkerId(entry.key),
        position: entry.value,
        infoWindow: InfoWindow(title: entry.key),
        icon: icon,
      );
    }).toSet();
  }

  Future<void> _openGoogleMaps() async {
    final url = Uri.parse("https://www.google.com/maps/search/?api=1&query=Leading+University+Sylhet");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open Google Maps")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Campus Map"),
        backgroundColor: Colors.deepPurple,
        elevation: 5,
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) => _controller = controller,
            initialCameraPosition: CameraPosition(
              target: _leadingUniversity,
              zoom: 17,
            ),
            markers: _createMarkers(),
            zoomControlsEnabled: false,
          ),

          // Floating Buttons
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 12),
                  ),
                  onPressed: _openGoogleMaps,
                  icon: const Icon(Icons.map_outlined, color: Colors.white),
                  label: const Text("Open in Google Maps",
                      style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 12),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const OfflineMapPage()),
                    );
                  },
                  icon: const Icon(Icons.offline_pin, color: Colors.white),
                  label: const Text("Offline Map",
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
