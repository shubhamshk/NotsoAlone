import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DiscoveryMapScreen extends StatefulWidget {
  const DiscoveryMapScreen({super.key});

  @override
  State<DiscoveryMapScreen> createState() => _DiscoveryMapScreenState();
}

class _DiscoveryMapScreenState extends State<DiscoveryMapScreen> {
  List<Marker> _markers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchGrounds();
  }

  Future<void> _fetchGrounds() async {
    try {
      // Pulling your 260 Patna grounds from Supabase
      final data = await Supabase.instance.client
          .from('places')
          .select('facility_name, latitude, longitude, category');

      setState(() {
        _markers = (data as List).map((ground) {
          return Marker(
            point: LatLng(ground['latitude'], ground['longitude']),
            width: 40,
            height: 40,
            child: GestureDetector(
              onTap: () => _showGroundDetails(
                ground['facility_name'],
                ground['category'],
              ),
              child: const Icon(
                Icons.location_on,
                color: Color(0xFF0066FF),
                size: 35,
              ),
            ),
          );
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching grounds: $e');
    }
  }

  void _showGroundDetails(String name, String category) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(category, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {},
              child: const Text("View Match Schedule"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Find Nearby Grounds')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(25.5941, 85.1376), // Patna Center
                initialZoom: 13.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                ),
                MarkerLayer(markers: _markers),
              ],
            ),
    );
  }
}
