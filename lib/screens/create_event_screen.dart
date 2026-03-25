import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_theme.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _orgNameController = TextEditingController();
  final TextEditingController _orgPhoneController = TextEditingController();
  final TextEditingController _orgEmailController = TextEditingController();
  final TextEditingController _playgroundOwnerController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  bool _isPaid = false;

  String _selectedSport = 'Soccer';
  int _maxPlayers = 10;
  bool _isLoading = false;

  // Images — web-compatible bytes
  final List<Uint8List> _eventImageBytes = [];

  // Date & Time
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 18, minute: 0);
  TimeOfDay _selectedEndTime = const TimeOfDay(hour: 19, minute: 0);

  // Map / location
  LatLng _mapCenter = const LatLng(20.5937, 78.9629); // India center
  LatLng? _selectedLatLng;
  bool _mapReady = false;
  final MapController _mapController = MapController();

  // Autocomplete
  List<Map<String, dynamic>> _suggestions = [];
  bool _loadingSuggestions = false;
  bool _showSuggestions = false;

  // Colors
  final Color _bgColor = AppTheme.background;
  final Color _primaryColor = AppTheme.primary;
  final Color _onPrimary = Colors.white;
  final Color _surfaceContainer = AppTheme.surfaceContainer;
  final Color _surfaceContainerHighest = AppTheme.surfaceContainer;
  final Color _surfaceContainerLowest = AppTheme.surface;
  final Color _surfaceContainerLow = AppTheme.surface;
  final Color _onSurface = AppTheme.textMain;
  final Color _onSurfaceVariant = AppTheme.textVariant;
  final Color _outlineVariant = AppTheme.outline;
  final Color _secondaryContainer = const Color(0xFFFFC4AF);
  final Color _onSecondaryContainer = const Color(0xFF812B00);

  static const List<Map<String, dynamic>> _sports = [
    {'icon': Icons.sports_soccer, 'label': 'Soccer'},
    {'icon': Icons.sports_basketball, 'label': 'Basketball'},
    {'icon': Icons.sports_tennis, 'label': 'Tennis'},
    {'icon': Icons.sports_volleyball, 'label': 'Volleyball'},
    {'icon': Icons.sports_cricket, 'label': 'Cricket'},
    {'icon': Icons.fitness_center, 'label': 'Training'},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _orgNameController.dispose();
    _orgPhoneController.dispose();
    _orgEmailController.dispose();
    _playgroundOwnerController.dispose();
    _amountController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  // ── Nominatim Geocoding ─────────────────────────────────
  Future<void> _searchLocation(String query) async {
    if (query.length < 2) {
      setState(() { _suggestions = []; _showSuggestions = false; });
      return;
    }
    setState(() => _loadingSuggestions = true);
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&addressdetails=1&limit=5',
      );
      final response = await http.get(url, headers: {'User-Agent': 'SportsApp/1.0'});
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _suggestions = data.map<Map<String, dynamic>>((item) => {
              'display_name': item['display_name'],
              'lat': double.parse(item['lat'].toString()),
              'lon': double.parse(item['lon'].toString()),
            }).toList();
            _showSuggestions = _suggestions.isNotEmpty;
            _loadingSuggestions = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Nominatim error: $e');
      if (mounted) setState(() => _loadingSuggestions = false);
    }
  }

  void _selectSuggestion(Map<String, dynamic> suggestion) {
    final lat = suggestion['lat'] as double;
    final lon = suggestion['lon'] as double;
    final name = suggestion['display_name'] as String;

    final shortName = name.split(',').take(2).join(', ');

    setState(() {
      _locationController.text = shortName;
      _selectedLatLng = LatLng(lat, lon);
      _mapCenter = LatLng(lat, lon);
      _suggestions = [];
      _showSuggestions = false;
    });

    // Animate map to selected location
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        try { _mapController.move(LatLng(lat, lon), 13.0); } catch (_) {}
      }
    });
  }

  // ── Image picker ────────────────────────────────────────
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (img != null && mounted) {
      final bytes = await img.readAsBytes();
      setState(() => _eventImageBytes.add(bytes));
    }
  }

  // ── Date / Time pickers ─────────────────────────────────
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(colorScheme: ColorScheme.light(primary: _primaryColor)),
        child: child!,
      ),
    );
    if (picked != null && mounted) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(colorScheme: ColorScheme.light(primary: _primaryColor)),
        child: child!,
      ),
    );
    if (picked != null && mounted) setState(() => _selectedTime = picked);
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedEndTime,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(colorScheme: ColorScheme.light(primary: _primaryColor)),
        child: child!,
      ),
    );
    if (picked != null && mounted) setState(() => _selectedEndTime = picked);
  }

  String _formatDate(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  // ── Publish ─────────────────────────────────────────────
  Future<void> _publishEvent() async {
    final title = _titleController.text.trim();
    final location = _locationController.text.trim();
    if (title.isEmpty || location.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out the title and location.')),
      );
      return;
    }
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in.'), backgroundColor: Colors.red),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final eventDateTime = DateTime(
        _selectedDate.year, _selectedDate.month, _selectedDate.day,
        _selectedTime.hour, _selectedTime.minute,
      );

      final eventEndDateTime = DateTime(
        _selectedDate.year, _selectedDate.month, _selectedDate.day,
        _selectedEndTime.hour, _selectedEndTime.minute,
      );

      final completeDescription = jsonEncode({
        'text': _descriptionController.text.trim(),
        'org_name': _orgNameController.text.trim(),
        'org_phone': _orgPhoneController.text.trim(),
        'org_email': _orgEmailController.text.trim(),
        'owner': _playgroundOwnerController.text.trim(),
        'end_time': eventEndDateTime.toIso8601String(),
        'is_paid': _isPaid,
        'amount': _isPaid ? _amountController.text.trim() : null,
      });

      await Supabase.instance.client.from('matches').insert({
        'title': title,
        'sport': _selectedSport,
        'location': location,
        'max_players': _maxPlayers,
        'organizer_id': user.id,
        'description': completeDescription,
        'event_date': eventDateTime.toIso8601String(),
        if (_selectedLatLng != null) 'latitude': _selectedLatLng!.latitude,
        if (_selectedLatLng != null) 'longitude': _selectedLatLng!.longitude,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event Published! ✓'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Build ────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _showSuggestions = false),
      child: Scaffold(
        backgroundColor: _bgColor,
        appBar: AppBar(
          backgroundColor: _bgColor.withOpacity(0.7),
          elevation: 0,
          leading: IconButton(icon: Icon(Icons.arrow_back, color: _onSurface), onPressed: () => Navigator.pop(context)),
          title: Text('Create Event', style: TextStyle(color: _onSurface, fontFamily: 'Lexend', fontWeight: FontWeight.w600, fontSize: 20)),
          actions: [IconButton(icon: Icon(Icons.more_vert, color: _onSurface), onPressed: () {})],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Media Upload ─────────────────────────────────
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: _eventImageBytes.isEmpty ? 200 : null,
                  decoration: BoxDecoration(
                    color: _surfaceContainer,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _outlineVariant.withOpacity(0.4)),
                  ),
                  child: _eventImageBytes.isEmpty
                      ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Container(width: 64, height: 64, decoration: BoxDecoration(color: _primaryColor.withOpacity(0.1), shape: BoxShape.circle), child: Icon(Icons.add_a_photo, color: _primaryColor, size: 32)),
                          const SizedBox(height: 16),
                          Text('Add Photos', style: TextStyle(fontFamily: 'Lexend', fontWeight: FontWeight.w500, color: _onSurface, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text('Showcase your venue and vibe', style: TextStyle(fontFamily: 'Manrope', color: _onSurfaceVariant, fontSize: 13)),
                        ]))
                      : SizedBox(
                          height: 200,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _eventImageBytes.length + 1,
                            itemBuilder: (_, i) {
                              if (i == _eventImageBytes.length) {
                                return GestureDetector(onTap: _pickImage, child: Container(width: 80, margin: const EdgeInsets.all(8), decoration: BoxDecoration(color: _primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(Icons.add, color: _primaryColor, size: 32)));
                              }
                              return Stack(children: [
                                Container(width: 180, margin: const EdgeInsets.all(8), decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), image: DecorationImage(image: MemoryImage(_eventImageBytes[i]), fit: BoxFit.cover))),
                                Positioned(top: 12, right: 12, child: GestureDetector(onTap: () => setState(() => _eventImageBytes.removeAt(i)), child: Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: Colors.black54, shape: BoxShape.circle), child: const Icon(Icons.close, color: Colors.white, size: 14)))),
                              ]);
                            },
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 32),

              // ── Event Identity ───────────────────────────────
              _sectionLabel('EVENT IDENTITY'),
              const SizedBox(height: 8),
              _textField(_titleController, 'Event Title (e.g., Saturday Night Football)', textStyle: TextStyle(fontFamily: 'Lexend', fontSize: 18, color: _onSurface)),
              const SizedBox(height: 24),

              // ── Sport ────────────────────────────────────────
              _sectionLabel('SELECT SPORT'),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: _sports.map((s) {
                  final label = s['label'] as String;
                  final isSel = _selectedSport == label;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedSport = label),
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(color: isSel ? _secondaryContainer : _surfaceContainerHighest, borderRadius: BorderRadius.circular(24)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(s['icon'] as IconData, size: 20, color: isSel ? _onSecondaryContainer : _onSurfaceVariant),
                        const SizedBox(width: 8),
                        Text(label, style: TextStyle(fontFamily: 'Lexend', fontWeight: FontWeight.w600, color: isSel ? _onSecondaryContainer : _onSurfaceVariant)),
                      ]),
                    ),
                  );
                }).toList()),
              ),
              const SizedBox(height: 24),

              // ── Description ──────────────────────────────────
              _textField(_descriptionController, 'Description', maxLines: 4),
              const SizedBox(height: 32),

              // ── Organizer Details ────────────────────────────
              _sectionLabel('ORGANIZER DETAILS'),
              const SizedBox(height: 8),
              _textField(_orgNameController, 'Organizer Name'),
              const SizedBox(height: 12),
              _textField(_orgPhoneController, 'Phone Number'),
              const SizedBox(height: 12),
              _textField(_orgEmailController, 'Email ID'),
              const SizedBox(height: 12),
              _textField(_playgroundOwnerController, 'Playground Owner / Manager'),
              const SizedBox(height: 32),

              // ── Players ──────────────────────────────────────
              _buildCard(
                icon: Icons.groups,
                title: 'Players Needed',
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: _surfaceContainerLowest, borderRadius: BorderRadius.circular(30), border: Border.all(color: _outlineVariant.withOpacity(0.2))),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    GestureDetector(onTap: () { if (_maxPlayers > 2) setState(() => _maxPlayers--); }, child: CircleAvatar(backgroundColor: _surfaceContainer, radius: 20, child: Icon(Icons.remove, color: _onSurface))),
                    Text('$_maxPlayers', style: TextStyle(fontFamily: 'Lexend', fontSize: 24, fontWeight: FontWeight.bold, color: _primaryColor)),
                    GestureDetector(onTap: () => setState(() => _maxPlayers++), child: CircleAvatar(backgroundColor: _primaryColor, radius: 20, child: Icon(Icons.add, color: _onPrimary))),
                  ]),
                ),
                footer: 'Set the minimum squad size required for the match.',
              ),
              const SizedBox(height: 24),

              // ── Date & Time ──────────────────────────────────
              _buildCard(
                icon: Icons.event_available,
                title: 'Date & Time',
                child: Column(children: [
                  _pickerRow('Date: ' + _formatDate(_selectedDate), Icons.calendar_today, _pickDate),
                  const SizedBox(height: 8),
                  _pickerRow('Starts at: ' + _formatTime(_selectedTime), Icons.schedule, _pickTime),
                  const SizedBox(height: 8),
                  _pickerRow('Ends at: ' + _formatTime(_selectedEndTime), Icons.schedule_send, _pickEndTime),
                ]),
              ),
              const SizedBox(height: 32),

              // ── Payment Details ─────────────────────────────
              _buildCard(
                icon: Icons.payments,
                title: 'Entry Fee',
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('Is this a paid event?', style: TextStyle(fontFamily: 'Manrope', fontSize: 16, color: _onSurface)),
                    Switch(
                      value: _isPaid,
                      onChanged: (val) => setState(() => _isPaid = val),
                      activeColor: _primaryColor,
                    ),
                  ]),
                  if (_isPaid) ...[
                    const SizedBox(height: 16),
                    _textField(_amountController, 'Amount (₹)', prefixIcon: Icon(Icons.currency_rupee, color: _primaryColor), keyboardType: TextInputType.number),
                  ]
                ]),
              ),
              const SizedBox(height: 32),

              // ── Location ─────────────────────────────────────
              _sectionLabel('LOCATION'),
              const SizedBox(height: 8),

              // Location Search with Autocomplete
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: _surfaceContainerLowest, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4)]),
                    child: TextField(
                      controller: _locationController,
                      onChanged: (val) {
                        _searchLocation(val);
                        setState(() { _showSuggestions = true; _selectedLatLng = null; });
                      },
                      onTap: () {
                        if (_locationController.text.length >= 2) setState(() => _showSuggestions = true);
                      },
                      decoration: InputDecoration(
                        hintText: 'Search city, venue, or address...',
                        hintStyle: TextStyle(fontFamily: 'Manrope', color: _outlineVariant),
                        prefixIcon: Icon(Icons.location_on, color: _primaryColor),
                        suffixIcon: _loadingSuggestions
                            ? Padding(padding: const EdgeInsets.all(12), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: _primaryColor)))
                            : _locationController.text.isNotEmpty
                                ? IconButton(icon: Icon(Icons.clear, color: _outlineVariant), onPressed: () => setState(() { _locationController.clear(); _suggestions = []; _showSuggestions = false; _selectedLatLng = null; }))
                                : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      style: TextStyle(fontFamily: 'Manrope', fontSize: 16, color: _onSurface),
                    ),
                  ),

                  // Suggestion dropdown
                  if (_showSuggestions && _suggestions.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      decoration: BoxDecoration(
                        color: _surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))],
                      ),
                      child: Column(
                        children: _suggestions.map((s) {
                          final name = s['display_name'] as String;
                          final shortName = name.split(',').take(2).join(', ');
                          final rest = name.split(',').skip(2).join(', ').trim();
                          return InkWell(
                            onTap: () => _selectSuggestion(s),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Row(children: [
                                Icon(Icons.place, color: _primaryColor, size: 18),
                                const SizedBox(width: 12),
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(shortName, style: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w600, fontSize: 14, color: _onSurface)),
                                  if (rest.isNotEmpty) Text(rest, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: 'Manrope', fontSize: 12, color: _onSurfaceVariant)),
                                ])),
                              ]),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // ── Interactive Map ──────────────────────────────
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  height: 260,
                  child: Stack(
                    children: [
                      FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: _mapCenter,
                          initialZoom: 10.0,
                          onMapReady: () => setState(() => _mapReady = true),
                          onTap: (tapPosition, latLng) {
                            setState(() {
                              _selectedLatLng = latLng;
                              _mapCenter = latLng;
                              _locationController.text = '${latLng.latitude.toStringAsFixed(4)}, ${latLng.longitude.toStringAsFixed(4)}';
                            });
                          },
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.notsoalone.app',
                            maxZoom: 18,
                          ),
                          if (_selectedLatLng != null)
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: _selectedLatLng!,
                                  width: 48,
                                  height: 48,
                                  child: Icon(Icons.location_on, color: _primaryColor, size: 48),
                                ),
                              ],
                            ),
                        ],
                      ),
                      // Top-right hint
                      Positioned(
                        top: 12, left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(20)),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(Icons.touch_app, size: 14, color: _primaryColor),
                            const SizedBox(width: 4),
                            Text('Tap map to pin', style: TextStyle(fontFamily: 'Manrope', fontSize: 11, fontWeight: FontWeight.w600, color: _onSurface)),
                          ]),
                        ),
                      ),
                      // Selected location badge
                      if (_selectedLatLng != null)
                        Positioned(
                          bottom: 12, left: 12, right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(color: _primaryColor, borderRadius: BorderRadius.circular(12)),
                            child: Row(children: [
                              const Icon(Icons.check_circle, color: Colors.white, size: 16),
                              const SizedBox(width: 8),
                              Expanded(child: Text(_locationController.text, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontFamily: 'Manrope', fontWeight: FontWeight.w600, fontSize: 13))),
                            ]),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomSheet: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _bgColor.withOpacity(0.9),
            border: Border(top: BorderSide(color: _outlineVariant.withOpacity(0.2))),
          ),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _publishEvent,
              style: ElevatedButton.styleFrom(backgroundColor: _primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 4),
              child: _isLoading
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Publish Event', style: TextStyle(fontFamily: 'Lexend', fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(text, style: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.bold, fontSize: 12, color: _onSurfaceVariant, letterSpacing: 1));

  Widget _textField(TextEditingController c, String hint, {int maxLines = 1, TextStyle? textStyle, Widget? prefixIcon, TextInputType? keyboardType}) =>
    Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: _surfaceContainerLowest, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4)]),
      child: TextField(
        controller: c,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(hintText: hint, hintStyle: TextStyle(fontFamily: 'Manrope', color: _outlineVariant), prefixIcon: prefixIcon, border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16)),
        style: textStyle ?? TextStyle(fontFamily: 'Manrope', fontSize: 16, color: _onSurface),
      ),
    );

  Widget _buildCard({required IconData icon, required String title, required Widget child, String? footer}) =>
    Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: _surfaceContainerLow, borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Icon(icon, color: _primaryColor), const SizedBox(width: 12), Text(title, style: TextStyle(fontFamily: 'Lexend', fontWeight: FontWeight.w600, color: _onSurface))]),
        const SizedBox(height: 16),
        child,
        if (footer != null) ...[const SizedBox(height: 12), Text(footer, textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Manrope', fontSize: 12, color: _onSurfaceVariant))],
      ]),
    );

  Widget _pickerRow(String value, IconData icon, VoidCallback onTap) =>
    InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(color: _surfaceContainerLowest, borderRadius: BorderRadius.circular(8)),
        child: Row(children: [
          Icon(icon, color: _primaryColor, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(value, style: TextStyle(fontFamily: 'Manrope', fontSize: 14, color: _onSurface, fontWeight: FontWeight.w600))),
          Icon(Icons.chevron_right, color: _outlineVariant, size: 20),
        ]),
      ),
    );
}
