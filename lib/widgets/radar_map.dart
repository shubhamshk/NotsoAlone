import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/location_service.dart';

class RadarMapWidget extends StatefulWidget {
  final ValueNotifier<LatLng?>? locationFocusNotifier;

  const RadarMapWidget({super.key, this.locationFocusNotifier});

  @override
  State<RadarMapWidget> createState() => _RadarMapWidgetState();
}

class _RadarMapWidgetState extends State<RadarMapWidget> {
  final MapController mapController = MapController();
  LatLng _center = const LatLng(25.611, 85.114);
  final double _zoom = 14.0;

  List<Map<String, dynamic>> _venues = [];

  @override
  void initState() {
    super.initState();
    _fetchVenues();
    _initUserLocation();
    widget.locationFocusNotifier?.addListener(_onLocationFocusChanged);
  }

  @override
  void dispose() {
    widget.locationFocusNotifier?.removeListener(_onLocationFocusChanged);
    super.dispose();
  }

  void _onLocationFocusChanged() {
    final latLng = widget.locationFocusNotifier?.value;
    if (latLng != null) {
      mapController.move(latLng, 16.0);
    }
  }

  Future<void> _initUserLocation() async {
    final loc = await LocationService.getCurrentLocation();
    if (loc != null && mounted) {
      setState(() {
        _center = LatLng(loc.latitude, loc.longitude);
        mapController.move(_center, _zoom);
      });
    }
  }

  Future<void> _fetchVenues() async {
    try {
      // Supabase imposes a default limit (often 1000). To ensure we get all ~260 places,
      // it's best to be explicit with .limit(), or even handle pagination if needed.
      // For 260, a limit of 1000 works perfectly.
      final data = await Supabase.instance.client
          .from('places')
          .select()
          .limit(1000);
      if (mounted) {
        setState(() {
          _venues = List<Map<String, dynamic>>.from(data as List);
        });
      }
    } catch (e) {
      debugPrint('Error fetching venues: $e');
    }
  }

  Future<void> _launchDirections(double lat, double lng) async {
    // Official Google Maps intent URL with dynamic coordinates
    final Uri url = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');

    if (await canLaunchUrl(url)) {
      // LaunchMode.externalApplication forces the native Maps app to open
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch Google Maps');
    }
  }

  Widget _buildPin(IconData icon, Color bgColor) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2.5),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 18),
    );
  }

  void _showPinDetails(BuildContext context, String title, String subtitle,
      double lat, double lng, bool hasEvent) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Text(title,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Lexend')),
            const SizedBox(height: 4),
            Text(subtitle,
                style: TextStyle(color: Colors.grey[600], fontFamily: 'Manrope')),
            const SizedBox(height: 12),
            // Status chip
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: hasEvent
                    ? Colors.blueAccent.withOpacity(0.12)
                    : Colors.grey.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    hasEvent ? Icons.sports : Icons.location_on,
                    size: 14,
                    color: hasEvent ? Colors.blueAccent : Colors.grey[600],
                  ),
                  const SizedBox(width: 6),
                  Text(
                    hasEvent ? 'Live Event' : 'Open Venue',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: hasEvent ? Colors.blueAccent : Colors.grey[700],
                      fontFamily: 'Manrope',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Directions button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  _launchDirections(lat, lng);
                },
                icon: const Icon(Icons.directions, color: Colors.white),
                label: const Text('Get Directions',
                    style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Lexend',
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: _center,
                initialZoom: _zoom,
              ),
              children: [
                // CartoDB light tile layer
                TileLayer(
                  urlTemplate:
                      'https://cartodb-basemaps-{s}.global.ssl.fastly.net/light_all/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c', 'd'],
                  userAgentPackageName: 'com.example.notsoalone2',
                ),

                // Dual-source marker layer
                StreamBuilder<List<Map<String, dynamic>>>(
                  stream: Supabase.instance.client
                      .from('matches')
                      .stream(primaryKey: ['id']),
                  builder: (context, snapshot) {
                    final List<Marker> markers = [];

                    // ── Grey pins: Empty Venues ──
                    for (var venue in _venues) {
                      final double? lat = venue['latitude']?.toDouble();
                      final double? lng = venue['longitude']?.toDouble();
                      if (lat == null || lng == null) continue;

                      markers.add(Marker(
                        point: LatLng(lat, lng),
                        width: 40,
                        height: 40,
                        child: GestureDetector(
                          onTap: () => _showPinDetails(
                            context,
                            venue['facility_name'] ?? 'Sports Venue',
                            venue['category'] ?? 'Patna',
                            lat,
                            lng,
                            false,
                          ),
                          child: _buildPin(
                              Icons.location_on, Colors.grey.shade600),
                        ),
                      ));
                    }

                    // ── Blue pins: Live Matches ──
                    if (snapshot.hasData) {
                      for (var match in snapshot.data!) {
                        final double? lat = match['latitude']?.toDouble();
                        final double? lng = match['longitude']?.toDouble();
                        if (lat == null || lng == null) continue;

                        markers.add(Marker(
                          point: LatLng(lat, lng),
                          width: 40,
                          height: 40,
                          child: GestureDetector(
                            onTap: () => _showPinDetails(
                              context,
                              match['title'] ?? 'Sports Match',
                              match['sport'] ?? match['location'] ?? 'Unknown',
                              lat,
                              lng,
                              true,
                            ),
                            child: _buildPin(
                                Icons.sports_volleyball, Colors.blueAccent),
                          ),
                        ));
                      }
                    }

                    // ── Blue dot: User's current location ──
                    markers.add(Marker(
                      point: _center,
                      width: 28,
                      height: 28,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF0052D0),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.black26,
                                blurRadius: 6,
                                offset: Offset(0, 2)),
                          ],
                        ),
                      ),
                    ));

                    return MarkerLayer(markers: markers);
                  },
                ),
              ],
            ),

            // Overlay: Current Location button
            Positioned(
              bottom: 16,
              left: 16,
              child: ElevatedButton.icon(
                onPressed: () => mapController.move(_center, _zoom),
                icon: const Icon(Icons.my_location, size: 16),
                label: const Text('My Location',
                    style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0052D0),
                  foregroundColor: Colors.white,
                  elevation: 3,
                  shape: const StadiumBorder(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
              ),
            ),

            // Overlay: Legend
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(12)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _legendItem(Colors.blueAccent, 'Live Match'),
                    const SizedBox(height: 4),
                    _legendItem(Colors.grey.shade600, 'Venue'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                fontFamily: 'Manrope')),
      ],
    );
  }
}
