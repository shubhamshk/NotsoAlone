import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LocationService {
  /// Fetches the current GPS position without syncing
  static Future<Position?> getCurrentLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return null;
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }
      if (permission == LocationPermission.deniedForever) return null;
      return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
    } catch (e) {
      debugPrint('Location error: $e');
      return null;
    }
  }

  /// Fetches the current GPS position and syncs it to the user's Supabase profile.
  static Future<void> syncCurrentLocation() async {
    try {
      // Step 1: Check if location services are enabled on device
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('LocationService: Location services are disabled.');
        return;
      }

      // Step 2: Check and request permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('LocationService: Location permission denied by user.');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('LocationService: Location permission permanently denied.');
        return;
      }

      // Step 3: Fetch the current GPS position
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      debugPrint(
          'LocationService: Got position — lat: ${position.latitude}, lng: ${position.longitude}');

      // Step 4: Sync coordinates to Supabase via PostGIS RPC function
      await Supabase.instance.client.rpc('update_profile_location', params: {
        'lat': position.latitude,
        'lng': position.longitude,
      });

      debugPrint('LocationService: Location synced to Supabase successfully!');
    } catch (e) {
      debugPrint('LocationService: Failed to sync location — $e');
    }
  }
}
