import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_theme.dart';

class LocationSearchWidget extends StatefulWidget {
  final Function(double lat, double lng) onLocationSelected;

  const LocationSearchWidget({super.key, required this.onLocationSelected});

  @override
  State<LocationSearchWidget> createState() => _LocationSearchWidgetState();
}

class _LocationSearchWidgetState extends State<LocationSearchWidget> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  
  Timer? _debounce;
  bool _isLoading = false;
  List<Map<String, dynamic>> _results = [];
  
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        if (_controller.text.isNotEmpty) {
          _showOverlay();
        }
      } else {
        // Delay hiding overlay to allow tap events on the dropdown to register
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) {
            _hideOverlay();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    _hideOverlay();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      if (mounted) {
        setState(() {
          _results = [];
          _isLoading = false;
        });
        _hideOverlay();
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });
    
    _showOverlay();

    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    debugPrint('--- LocationSearch: Starting search for query: "$query" ---');
    try {
      final data = await Supabase.instance.client
          .from('places')
          .select('id, facility_name, category, area_location, latitude, longitude')
          .ilike('facility_name', '%$query%')
          .limit(10);
      
      debugPrint('LocationSearch: Raw Supabase data received: $data');
          
      if (mounted) {
        setState(() {
          _results = List<Map<String, dynamic>>.from(data as List);
          _isLoading = false;
        });
        debugPrint('LocationSearch: Processed ${_results.length} results');
        _overlayEntry?.markNeedsBuild();
      }
    } catch (e) {
      debugPrint('LocationSearch: ERROR fetching data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _overlayEntry?.markNeedsBuild();
      }
    }
  }

  void _showOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.markNeedsBuild();
      return;
    }
    
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Invisible dismiss layer
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                _focusNode.unfocus();
                _hideOverlay();
              },
              child: Container(color: Colors.transparent),
            ),
          ),
          Positioned(
            width: size.width,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(0.0, size.height + 8.0),
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(16),
                color: AppTheme.surface,
                shadowColor: Colors.black.withOpacity(0.15),
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 320),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.outline.withOpacity(0.2)),
                  ),
                  child: _buildDropdownContent(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownContent() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(24.0),
        child: Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
      );
    }

    if (_results.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24.0),
        child: Center(
          child: Text(
            'No places found',
            style: TextStyle(color: AppTheme.textVariant, fontFamily: 'Manrope'),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      itemCount: _results.length,
      separatorBuilder: (context, index) => Divider(height: 1, color: AppTheme.outline.withOpacity(0.1)),
      itemBuilder: (context, index) {
        final place = _results[index];
        final name = place['facility_name'] ?? 'Unknown Venue';
        final location = place['area_location'] ?? 'Unknown Location';
        final category = place['category'] ?? '';
        final lat = place['latitude']?.toDouble();
        final lng = place['longitude']?.toDouble();

        return InkWell(
          onTap: () {
            _controller.text = name;
            _focusNode.unfocus();
            _hideOverlay();
            if (lat != null && lng != null) {
              widget.onLocationSelected(lat, lng);
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.location_on, color: AppTheme.primary, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, fontFamily: 'Lexend', color: AppTheme.textMain),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        location,
                        style: const TextStyle(color: AppTheme.textVariant, fontSize: 13, fontFamily: 'Manrope'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (category.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(fontSize: 10, color: Colors.grey[700], fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
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
          controller: _controller,
          focusNode: _focusNode,
          onChanged: _onSearchChanged,
          decoration: InputDecoration(
            hintText: 'Search sports, venues, playpals etc',
            hintStyle: TextStyle(color: AppTheme.outline.withOpacity(0.6)),
            prefixIcon: const Icon(Icons.search, color: AppTheme.outline),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: AppTheme.outline, size: 20),
                    onPressed: () {
                      _controller.clear();
                      _onSearchChanged('');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    );
  }
}
