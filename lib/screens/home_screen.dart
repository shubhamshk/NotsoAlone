import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'all_sports_screen.dart';
import 'group_chats_screen.dart';
import 'venue_details_screen.dart';
import 'edit_profile_screen.dart';
import 'create_event_screen.dart';

import '../services/supabase_service.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_theme.dart';
import '../widgets/radar_map.dart';
import '../services/upi_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final Color _bgColor = AppTheme.background;
  final Color _primaryColor = AppTheme.primary;
  final Color _textColor = AppTheme.textMain;
  final Color _textVariantColor = AppTheme.textVariant;
  final Color _surfaceContainer = AppTheme.surfaceContainer;
  final Color _surfaceContainerLowest = AppTheme.surface;
  final Color _surfaceContainerHigh = AppTheme.primaryLight;
  final Color _outlineColor = AppTheme.outline;

  late TabController _tabController;
  bool _showFab = true;

  // User profile state
  String _userName = '';
  String? _userAvatarUrl;
  String _userLocation = 'Loading...';

  // Radar state
  List<dynamic> _nearbyUsers = [];
  bool _radarLoading = true;
  String? _radarError;

  // Joined matches state
  Set<int> _joinedMatchIds = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _showFab = _tabController.index == 0;
      });
    });
    LocationService.syncCurrentLocation();
    NotificationService.init();
    NotificationService.startListening();
    _fetchNearbyAthletes();
    _fetchJoinedMatches();
    _loadUserProfile();
    _loadCurrentLocation();
  }

  Future<void> _fetchJoinedMatches() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final response = await Supabase.instance.client
          .from('match_participants')
          .select('match_id')
          .eq('user_id', user.id);

      if (mounted) {
        setState(() {
          _joinedMatchIds = (response as List)
              .map((item) => int.tryParse(item['match_id'].toString()) ?? 0)
              .toSet();
        });
      }
    } catch (e) {
      debugPrint('Error fetching joined matches: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchNearbyAthletes() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _radarError = 'Location services are disabled.';
          _radarLoading = false;
        });
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _radarError = 'Location permission denied.';
            _radarLoading = false;
          });
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _radarError = 'Location permission permanently denied.';
          _radarLoading = false;
        });
        return;
      }
      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final response = await Supabase.instance.client.rpc(
        'get_nearby_users',
        params: {
          'user_lat': pos.latitude,
          'user_lng': pos.longitude,
          'radius_meters': 15000,
        },
      );
      setState(() {
        _nearbyUsers = response as List<dynamic>;
        _radarLoading = false;
      });
    } catch (e) {
      debugPrint('Radar fetch error: $e');
      setState(() {
        _radarError = 'Could not load nearby athletes.';
        _radarLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: _bgColor,
        appBar: AppBar(
          backgroundColor: _bgColor,
          elevation: 0,
          title: _buildHeader(),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: _primaryColor,
            labelColor: _primaryColor,
            unselectedLabelColor: _textVariantColor,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'Manrope',
            ),
            tabs: const [
              Tab(text: 'Live Matches'),
              Tab(text: 'Local Radar'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            // ── Tab 1: Live Matches ──
            _buildMatchFeedTab(),
            // ── Tab 2: Local Radar ──
            _buildRadarTab(),
          ],
        ),
        floatingActionButton: _showFab
            ? Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateEventScreen(),
                      ),
                    );
                  },
                  backgroundColor: AppTheme.primary,
                  elevation: 6,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: const Icon(Icons.add, color: Colors.white, size: 32),
                ),
              )
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        bottomNavigationBar: _buildBottomNavigationBar(context),
      ),
    );
  }

  Widget _buildMatchFeedTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          _buildGreeting(),
          const SizedBox(height: 16),
          _buildSearchBar(),
          const SizedBox(height: 16),
          const RadarMapWidget(),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: Supabase.instance.client
                  .from('matches')
                  .stream(primaryKey: ['id'])
                  .order('created_at', ascending: false),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF0052D0)),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: \${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'No matches happening right now. Hit the + button to host one!',
                    ),
                  );
                }
                final matches = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 120),
                  itemCount: matches.length,
                  itemBuilder: (context, index) {
                    final match = matches[index];
                    final title = match['title'] ?? 'Untitled';
                    final sport = match['sport'] ?? 'Unknown Sport';
                    final location = match['location'] ?? 'Unknown Location';
                    final maxPlayers = match['max_players'] ?? 100;
                    final joinedPlayers = match['joined_players'] ?? 0;
                    final bool isFull = joinedPlayers >= maxPlayers;
                    final String? imageUrl = match['image_url'] as String?;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: _surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: AppTheme.dropShadow,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Image header ──
                          if (imageUrl != null && imageUrl.isNotEmpty)
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                              child: Image.network(
                                imageUrl,
                                height: 160,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, progress) {
                                  if (progress == null) return child;
                                  return Container(
                                    height: 160,
                                    color: Colors.grey[200],
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        color: Color(0xFF0052D0),
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (_, _, _) =>
                                    const SizedBox.shrink(),
                              ),
                            )
                          else
                            const SizedBox.shrink(),
                          // ── Text content ──
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        title,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: _textColor,
                                          fontFamily: 'Lexend',
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE1F5FE),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        sport,
                                        style: const TextStyle(
                                          color: Color(0xFF01579B),
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: 16,
                                      color: _textVariantColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        location,
                                        style: TextStyle(
                                          color: _textVariantColor,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.people,
                                      size: 16,
                                      color: _textVariantColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Players: $joinedPlayers / ${maxPlayers == 100 ? "?" : maxPlayers}',
                                      style: TextStyle(
                                        color: _textVariantColor,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Builder(
                                  builder: (context) {
                                    final matchIdStr = match['id'].toString();
                                    final matchIdInt =
                                        int.tryParse(matchIdStr) ?? 0;
                                    final isJoined =
                                        _joinedMatchIds.contains(matchIdInt);

                                    return SizedBox(
                                      width: double.infinity,
                                      height: 50,
                                      child: ElevatedButton(
                                        onPressed: isJoined || isFull
                                            ? null
                                            : () async {
                                                await UpiService.launchUPI(context, '50.00');
                                                // Ideally, join match logic would be handled after successful payment
                                                _fetchJoinedMatches();
                                              },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: isJoined
                                              ? Colors.green.shade100
                                              : AppTheme.primary,
                                          foregroundColor: isJoined
                                              ? Colors.green
                                              : Colors.white,
                                          elevation: isJoined ? 0 : 2,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: Text(
                                          isFull
                                              ? 'Match Full'
                                              : (isJoined
                                                  ? 'Already Joined'
                                                  : 'Join Match'),
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadarTab() {
    if (_radarLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF0052D0)),
      );
    }
    if (_radarError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.location_off, color: _textVariantColor, size: 48),
              const SizedBox(height: 16),
              Text(
                _radarError!,
                textAlign: TextAlign.center,
                style: TextStyle(color: _textVariantColor, fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _radarLoading = true;
                    _radarError = null;
                  });
                  _fetchNearbyAthletes();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
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
    if (_nearbyUsers.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.people_outline, color: _textVariantColor, size: 64),
              const SizedBox(height: 16),
              Text(
                'No athletes found within 15km of your location.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _textVariantColor,
                  fontSize: 16,
                  fontFamily: 'Manrope',
                ),
              ),
            ],
          ),
        ),
      );
    }
    return RefreshIndicator(
      color: _primaryColor,
      onRefresh: () async {
        setState(() {
          _radarLoading = true;
          _nearbyUsers = [];
        });
        await _fetchNearbyAthletes();
      },
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        itemCount: _nearbyUsers.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  leading: const Icon(Icons.notifications_active, color: AppTheme.primary),
                title: const Text(
                  'Test Notification ⚡',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('Tap to fire a local alert'),
                onTap: () {
                  NotificationService.showNotification(
                    'Victory Alert! 🏆',
                    'The notification engine is now online and active.',
                  );
                },
              ),
            ),
          );
          }
          final user = _nearbyUsers[index - 1];
          final String username = user['username'] ?? 'Unknown Athlete';
          final String sport = user['preferred_sport'] ?? 'Any Sport';
          final double distanceKm = (user['distance_meters'] as num) / 1000;
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppTheme.softShadow,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: _primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.person, color: _primaryColor, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          username,
                          style: TextStyle(
                            fontFamily: 'Lexend',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: _textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE1F5FE),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            sport,
                            style: const TextStyle(
                              color: Color(0xFF01579B),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: _textVariantColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${distanceKm.toStringAsFixed(1)} km away',
                        style: TextStyle(
                          color: _textVariantColor,
                          fontSize: 13,
                          fontFamily: 'Manrope',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.menu, color: _textColor),
            const SizedBox(width: 12),
            Text(
              'Sports Community',
              style: TextStyle(
                color: _textColor,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        Icon(Icons.notifications_outlined, color: _textColor),
      ],
    );
  }

  // ── Load user profile from Supabase ──
  Future<void> _loadUserProfile() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;
      final data = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();
      if (data != null && mounted) {
        setState(() {
          _userName = (data['full_name'] ?? data['username'] ?? '').toString();
          _userAvatarUrl = data.containsKey('avatar_url') ? data['avatar_url'] : null;
        });
      }
    } catch (e) {
      debugPrint('Error loading user profile: $e');
    }
  }

  // ── Load real-time GPS location ──
  Future<void> _loadCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) setState(() => _userLocation = 'Location off');
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        if (mounted) setState(() => _userLocation = 'Permission denied');
        return;
      }
      Position pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
        if (placemarks.isNotEmpty && mounted) {
          final p = placemarks.first;
          final locality = p.subLocality?.isNotEmpty == true ? p.subLocality : p.locality;
          setState(() => _userLocation = locality ?? '${pos.latitude.toStringAsFixed(2)}, ${pos.longitude.toStringAsFixed(2)}');
        }
      } catch (e) {
        if (mounted) setState(() => _userLocation = '${pos.latitude.toStringAsFixed(2)}, ${pos.longitude.toStringAsFixed(2)}');
      }
    } catch (e) {
      if (mounted) setState(() => _userLocation = 'Unavailable');
    }
  }

  // ── Show upcoming scheduled events ──
  void _showScheduledEvents() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: _bgColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Text('Upcoming Events', style: TextStyle(fontFamily: 'Lexend', fontSize: 20, fontWeight: FontWeight.bold, color: _textColor)),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder(
                future: _fetchUserEvents(),
                builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.event_busy, size: 64, color: _textVariantColor),
                          const SizedBox(height: 16),
                          Text('No upcoming events', style: TextStyle(color: _textVariantColor, fontSize: 16)),
                        ],
                      ),
                    );
                  }
                  final events = snapshot.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: AppTheme.softShadow,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48, height: 48,
                              decoration: BoxDecoration(color: _primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                              child: Icon(Icons.sports, color: _primaryColor),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(event['title'] ?? 'Event', style: TextStyle(fontWeight: FontWeight.bold, color: _textColor)),
                                  const SizedBox(height: 4),
                                  Text(event['location'] ?? '', style: TextStyle(color: _textVariantColor, fontSize: 12)),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(8)),
                              child: Text(event['sport'] ?? '', style: TextStyle(color: _primaryColor, fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchUserEvents() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return [];
      final response = await Supabase.instance.client
          .from('match_participants')
          .select('match_id, matches(title, sport, location, created_at)')
          .eq('user_id', user.id);
      return List<Map<String, dynamic>>.from(
        (response as List).map((item) => item['matches'] ?? item),
      );
    } catch (e) {
      debugPrint('Error fetching user events: $e');
      return [];
    }
  }

  Widget _buildGreeting() {
    final displayName = _userName.isNotEmpty ? _userName : 'Champ';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: _primaryColor, width: 2),
                      image: DecorationImage(
                        image: _userAvatarUrl != null && _userAvatarUrl!.isNotEmpty
                            ? NetworkImage(_userAvatarUrl!)
                            : const NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuAU_g7AZTKk4C0YUpsYbU0e2jhfQN7SWIWh1L2Ofa2YMvnNsTQiMlq0uPUNdFYc59UZhmWXFHtcIkB_5fE5Hfw8MUUZsUkWKhjFFlZs6HQHJCrf1aCxeG8o0IFIcN7UlVmnp99LETsACPSxumAhh9pC_h6w7krNFuYrB_-URamZkglH-ucsDQdsrnPkfJ82MDXa2YoMAfe13kK9mA2vYcqbUsFVFavBr2j3ALPZqCiwo3qJwp3_zLA2oMVywW0YOC1JTuCBwU9CmrU') as ImageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: _bgColor, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hey $displayName!',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _textColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on, color: _textVariantColor, size: 16),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            _userLocation,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: _textVariantColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            GestureDetector(
              onTap: () {
                // Navigate to Chats tab
                Navigator.push(context, MaterialPageRoute(builder: (_) => const GroupChatsScreen()));
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _surfaceContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.chat_bubble_outline,
                  color: _primaryColor,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _showScheduledEvents,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _surfaceContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.calendar_today_outlined,
                  color: _primaryColor,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: _surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search sports, venues, playpals etc',
          hintStyle: TextStyle(color: _outlineColor.withOpacity(0.6)),
          prefixIcon: Icon(Icons.search, color: _outlineColor),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildMapWidget() {
    return Container(
      height: 256,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(16),
        image: const DecorationImage(
          image: NetworkImage(
            'https://lh3.googleusercontent.com/aida-public/AB6AXuCcrEd5q3EMJMrF287pE6m8BmWnxlpPQ4cw9iSyxXXgADItnfo6BG6iXziwTz-gm-v9KesdZuOfJAm9XHwx_vPMdEJ_AmiCCA7xTV9Ol92Ed4XBdoxqF4FfRWYYdd5DKsckqepQzSaEPBmv6ZhGbg5TJJJbc2G5FZYjNAbqCKKm5iWJpCLUiRfK2yN6wtfBwb58xo8LBDQU17HMLR0LeQ92YL1yR9-GZmktneO-CzwJOD9CVqQIlkbnloXluVVf3QLSZJUa1iKXLJw',
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [_textColor.withOpacity(0.4), Colors.transparent],
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.my_location, size: 18),
              label: const Text('Current location'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: Icon(Icons.filter_list, size: 18, color: _textColor),
              label: Text('Filter', style: TextStyle(color: _textColor)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _surfaceContainerLowest,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            ),
          ),
          Positioned(
            top: 128,
            left: 100,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFA33800), // secondary
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
              ),
              child: const Icon(
                Icons.sports_soccer,
                color: Color(0xFFFFEFEB),
                size: 16,
              ),
            ),
          ),
          Positioned(
            top: 64,
            right: 64,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFF8D3A8B), // tertiary
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
              ),
              child: const Icon(
                Icons.sports_tennis,
                color: Color(0xFFFFEEF8),
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSportsList() {
    final sports = [
      {'name': 'Cricket', 'icon': Icons.sports_cricket, 'active': false},
      {'name': 'Basketball', 'icon': Icons.sports_basketball, 'active': true},
      {'name': 'Football', 'icon': Icons.sports_soccer, 'active': false},
      {'name': 'Tennis', 'icon': Icons.sports_tennis, 'active': false},
      {'name': 'Gym', 'icon': Icons.fitness_center, 'active': false},
      {'name': 'Swimming', 'icon': Icons.pool, 'active': false},
      {'name': 'Kabaddi', 'icon': Icons.sports_kabaddi, 'active': false},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Games by Sports',
              style: TextStyle(
                color: _textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'See All',
              style: TextStyle(
                color: _primaryColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: sports.map((sport) {
              final active = sport['active'] as bool;
              return Padding(
                padding: const EdgeInsets.only(right: 24.0),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: active
                            ? const Color(0xFFFFC4AF)
                            : _surfaceContainerHigh,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        sport['icon'] as IconData,
                        color: active
                            ? const Color(0xFF812B00)
                            : const Color(0xFF0047B7),
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      sport['name'] as String,
                      style: TextStyle(
                        color: _textColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildVenuesList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Go-To Venues',
          style: TextStyle(
            color: _textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildVenueCard(
                context,
                name: 'Greenfield Arena',
                location: 'Boring Road, Patna',
                rating: '4.8',
                imageUrl:
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuBAn6SqsJ3Mcc2d5zuwIW7SFEGCb4iN4ly3A4wHETsPNezkNCRxXBT6I9kAUbUOfheLmcayTmmOS7wW-_pPoWU0ZPGnXbKem1pJAss0SbM792Dk0mCNEd7t9Ccoojj2nmrOab638Ivw-ru4rXrK8v0uN0ClSFZzpUByhcNHDG4uLUbyRvCGRVmZ669mNkzYS6cDrsscpvpCfj6Fo8il6wbZmo1MnAqE63yJWxi43xTFqAPMqBUlkgWrzLJ7ozlzMwzRezp6My2sLkQ',
              ),
              const SizedBox(width: 16),
              _buildVenueCard(
                context,
                name: 'The Smash Club',
                location: 'Kankarbagh, Patna',
                rating: '4.5',
                imageUrl:
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuAT_2LHat7EsHEgiC18Ze48IN6o07KBiN1JTRXTjn3z35FnB0GGOCnjby8MahRyVgMca5iieaF9Wa4mnnRDEfjGNHu7nbkIMMEawn8ODemJmeGVMF1ftlZKbR1Xt60UB1gPRI6yfB7m5fn6l-5c2_zI6Pfam_E3l1r9QrM8ijzflcTNv_aGNZ8KXmL2ON9jfMAUNGDrOH0tnKr3CcO2HTgi4MvGzobZhzMKaMDjsessw88mWNQB2LpqbgDV2n-gqJDW-5lAbHNncY',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVenueCard(
    BuildContext context, {
    required String name,
    required String location,
    required String rating,
    required String imageUrl,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const VenueDetailsScreen()),
        );
      },
      child: Container(
        width: 240,
        decoration: BoxDecoration(
          color: _surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _surfaceContainerLowest.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: Color(0xFFA33800),
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            rating,
                            style: TextStyle(
                              color: _textColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      color: _textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: _textVariantColor,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        location,
                        style: TextStyle(
                          color: _textVariantColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingEvents() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upcoming Events',
          style: TextStyle(
            color: _textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: SupabaseService().getMatches(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            final matches = snapshot.data ?? [];
            if (matches.isEmpty) {
              return const Text('No upcoming events found.');
            }

            // For now, let's just show the first match
            final match = matches.first;
            final sport = match['sport'] ?? 'Unknown Sport';
            final time = match['time'] ?? 'TBD';
            final title = match['title'] ?? '$sport Match';
            final location = match['location'] ?? 'TBD';

            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _primaryColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(
                        Icons.sports_basketball,
                        color: Colors.white70,
                        size: 40,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Text(
                          time
                              .toString()
                              .toUpperCase(), // Or use a Date formatting logic
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    location,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      SizedBox(
                        width: 72,
                        height: 32,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            _buildAvatar(
                              'https://lh3.googleusercontent.com/aida-public/AB6AXuAPY6nyz6g8RN2yvIPsNNcrWHZj-hJiHix_lJimXfR8hV2Tpq7s7sBJUdRCnE7KEXZ-PBx_zroyaTtCrTg_tqGln0FZ0no0RbzGe5OZ8nehw4pI_lWJ9YtAYyGKAvrJOX2BroeMuuxitg7NK--B93Mz0bkesLXiPaPwggLBQvh0iXj3sX85v52adWv0OQie3WSpyHMs5BmR3Nc18Yhls9UzxL6UEDkAC8KN_ZD95I1z0IPR1uCNuF8vxJKv6on1jagbsf1cR9A_Yy8',
                              0,
                            ),
                            _buildAvatar(
                              'https://lh3.googleusercontent.com/aida-public/AB6AXuCmT9dCvS6nvVMwu_pjWYd8gmfeNOYWTGi9ipMjwvoPvv6m2aJ5uClQ3mql-u1AtZZOKDEzErBnYLl8RfGihJCQsn7iu-ewEzUzsSugthHh_O06vFdoZi1408z0UJjmILuV9pP1v4G9BK2NrWHcYlBMch9Jt4NMwMT6BvX6YHXpgpbLjz5HKJIj3jOJ_sVQsiF0eEE8l-mWc4c8jTQUZeCep8S7oHY0_-TjQyhFA3fW-tgn3_QQQUDKryuaBSopiaOjUkoHaa3PmLA',
                              20,
                            ),
                            _buildAvatar(
                              'https://lh3.googleusercontent.com/aida-public/AB6AXuCi6RUEru2BVPI94aR18oQVWugcjIe435AQtQKE-dc2Sue3fksXf8hEAqT_R2DeGBRFd8K8oH5AsJPtkIQSfXk_kgGghyCFf_9dF1Vy_kggTAu4PxO-Wpu5hWylXriY4lrbLQLYTWzQu3AqlBohvOaNiaH-bsQKGEkF63-Xsco1EvMCJWW2iuCecOitcuopoe3xWNwVw4nF4DoU-XJ9snUfrVDmHOaS7-miqE4fs76b891D7pTRxpXI_mLMNvW4gjTUpnTMmQOI7ro',
                              40,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Join match',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAvatar(String url, double leftMargin) {
    return Positioned(
      left: leftMargin,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: _primaryColor, width: 2),
          image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _bgColor.withOpacity(0.9),
        border: Border(
          top: BorderSide(color: _outlineColor.withOpacity(0.1), width: 1),
        ),
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: _primaryColor,
        unselectedItemColor: _textVariantColor,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (_, _, _) => const AllSportsScreen(),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (_, _, _) => const GroupChatsScreen(),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
            );
          } else if (index == 3) {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (_, _, _) => const EditProfileScreen(),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_outlined),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
