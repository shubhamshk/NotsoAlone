import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';

class LocationDetailScreen extends StatefulWidget {
  final String placeId;

  const LocationDetailScreen({super.key, required this.placeId});

  @override
  State<LocationDetailScreen> createState() => _LocationDetailScreenState();
}

class _LocationDetailScreenState extends State<LocationDetailScreen> {
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _placeData;

  @override
  void initState() {
    super.initState();
    _fetchPlaceDetails();
  }

  Future<void> _fetchPlaceDetails() async {
    try {
      final response = await Supabase.instance.client
          .from('places')
          .select()
          .eq('id', widget.placeId)
          .single();
      
      if (mounted) {
        setState(() {
          _placeData = response;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching place details: $e');
      if (mounted) {
        setState(() {
          _error = 'Could not load location details.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textMain),
        title: const Text(
          'Location Details',
          style: TextStyle(
            color: AppTheme.textMain,
            fontFamily: 'Lexend',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primary),
      );
    }

    if (_error != null || _placeData == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: AppTheme.textVariant, size: 48),
              const SizedBox(height: 16),
              Text(
                _error ?? 'Location not found.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.textVariant, fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _error = null;
                  });
                  _fetchPlaceDetails();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final data = _placeData!;
    final name = data['facility_name'] ?? 'Unknown Venue';
    final category = data['category'] ?? '';
    final location = data['area_location'] ?? 'Unknown Location';
    final surfaceType = data['surface_type'] ?? 'N/A';
    final amenities = data['amenities'] ?? 'No amenities listed';
    final phone = data['contact_phone'] ?? '';
    final emailWeb = data['contact_email_website'] ?? '';
    final ownerName = data['owner_name'] ?? '';
    final mapLink = data['google_maps_link'] ?? '';
    final rating = data['rating']?.toString();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppTheme.softShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Lexend',
                          color: AppTheme.textMain,
                        ),
                      ),
                    ),
                    if (category.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          category,
                          style: const TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: AppTheme.primary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        location,
                        style: const TextStyle(
                          color: AppTheme.textVariant,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                if (rating != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 6),
                      Text(
                        rating,
                        style: const TextStyle(
                          color: AppTheme.textMain,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Details Section
          _buildSectionHeader('Details'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppTheme.softShadow,
            ),
            child: Column(
              children: [
                _buildInfoRow(Icons.layers, 'Surface Type', surfaceType),
                const Divider(height: 24),
                _buildInfoRow(Icons.list_alt, 'Amenities', amenities),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Contact Section
          if (phone.isNotEmpty || emailWeb.isNotEmpty || ownerName.isNotEmpty) ...[
            _buildSectionHeader('Contact & Owner'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppTheme.softShadow,
              ),
              child: Column(
                children: [
                  if (ownerName.isNotEmpty) ...[
                    _buildInfoRow(Icons.person, 'Owner/Manager', ownerName),
                    const SizedBox(height: 16),
                  ],
                  Row(
                    children: [
                      if (phone.isNotEmpty)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _launchURL('tel:$phone'),
                            icon: const Icon(Icons.phone, size: 18),
                            label: const Text('Call'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryLight,
                              foregroundColor: AppTheme.primary,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      if (phone.isNotEmpty && emailWeb.isNotEmpty)
                        const SizedBox(width: 12),
                      if (emailWeb.isNotEmpty)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              if (emailWeb.contains('@')) {
                                _launchURL('mailto:$emailWeb');
                              } else if (!emailWeb.startsWith('http')) {
                                _launchURL('https://$emailWeb');
                              } else {
                                _launchURL(emailWeb);
                              }
                            },
                            icon: Icon(emailWeb.contains('@') ? Icons.email : Icons.language, size: 18),
                            label: Text(emailWeb.contains('@') ? 'Email' : 'Website'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryLight,
                              foregroundColor: AppTheme.primary,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Map Section
          if (mapLink.isNotEmpty) ...[
            _buildSectionHeader('Location Map'),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _launchURL(mapLink),
                icon: const Icon(Icons.map),
                label: const Text('Open in Google Maps'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          fontFamily: 'Lexend',
          color: AppTheme.textMain,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppTheme.textVariant),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.textVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: AppTheme.textMain,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
