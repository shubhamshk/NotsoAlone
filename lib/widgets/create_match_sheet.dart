import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_theme.dart';

class CreateMatchSheet extends StatefulWidget {
  const CreateMatchSheet({super.key});

  @override
  State<CreateMatchSheet> createState() => _CreateMatchSheetState();
}

class _CreateMatchSheetState extends State<CreateMatchSheet> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  String selectedSport = 'Soccer';
  double maxPlayers = 10;
  bool isLoading = false;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  final Color _primaryColor = AppTheme.primary;
  final Color _textColor = AppTheme.textMain;
  final Color _textVariantColor = AppTheme.textVariant;

  final List<String> _sports = [
    'Soccer',
    'Cricket',
    'Basketball',
    'Tennis',
    'Badminton',
  ];

  @override
  void dispose() {
    titleController.dispose();
    locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (image != null) {
      setState(() => _selectedImage = File(image.path));
    }
  }

  Future<void> _submitMatch() async {
    final title = titleController.text.trim();
    final location = locationController.text.trim();

    if (title.isEmpty || location.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in both the title and location.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      String? imageUrl;

      if (_selectedImage != null) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        await Supabase.instance.client.storage
            .from('match_images')
            .upload(fileName, _selectedImage!);
        imageUrl = Supabase.instance.client.storage
            .from('match_images')
            .getPublicUrl(fileName);
      }

      await Supabase.instance.client.from('matches').insert({
        'title': title,
        'sport': selectedSport,
        'location': location,
        'max_players': maxPlayers.toInt(),
        'organizer_id': Supabase.instance.client.auth.currentUser!.id,
        'image_url': imageUrl,
        'latitude': 25.611 + (Random().nextDouble() * 0.02 - 0.01),
        'longitude': 85.114 + (Random().nextDouble() * 0.02 - 0.01),
      });

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating match: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Text(
            'Host a New Match',
            style: TextStyle(
              fontFamily: 'Lexend',
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: _textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Fill in the details and publish your game.',
            style: TextStyle(color: _textVariantColor, fontSize: 13),
          ),
          const SizedBox(height: 24),

          // Image picker
          GestureDetector(
            onTap: _pickImage,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _selectedImage == null
                  ? Container(
                      height: 150,
                      color: Colors.grey[200],
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add_a_photo, size: 36, color: Colors.grey[500]),
                            const SizedBox(height: 8),
                            Text(
                              'Add Turf Photo',
                              style: TextStyle(color: Colors.grey[600], fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SizedBox(
                      height: 150,
                      width: double.infinity,
                      child: Image.file(_selectedImage!, fit: BoxFit.cover),
                    ),
            ),
          ),
          const SizedBox(height: 16),

          // Title field
          TextField(
            controller: titleController,
            decoration: InputDecoration(
              labelText: 'Match Title',
              hintText: 'e.g. Evening Cricket at the Park',
              prefixIcon: const Icon(Icons.emoji_events_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),

          // Sport dropdown
          DropdownButtonFormField<String>(
            value: selectedSport,
            decoration: InputDecoration(
              labelText: 'Sport',
              prefixIcon: const Icon(Icons.sports),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            items: _sports
                .map((sport) => DropdownMenuItem(value: sport, child: Text(sport)))
                .toList(),
            onChanged: (value) {
              if (value != null) setState(() => selectedSport = value);
            },
          ),
          const SizedBox(height: 16),

          // Location field
          TextField(
            controller: locationController,
            decoration: InputDecoration(
              labelText: 'Location',
              hintText: 'e.g. Gandhi Maidan, Patna',
              prefixIcon: const Icon(Icons.location_on_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 20),

          // Max players slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Max Players', style: TextStyle(color: _textColor, fontWeight: FontWeight.w600)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${maxPlayers.toInt()}',
                  style: TextStyle(color: _primaryColor, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
          Slider(
            value: maxPlayers,
            min: 2,
            max: 22,
            divisions: 20,
            activeColor: _primaryColor,
            inactiveColor: _primaryColor.withOpacity(0.2),
            label: maxPlayers.toInt().toString(),
            onChanged: (value) => setState(() => maxPlayers = value),
          ),
          const SizedBox(height: 24),

          // Submit button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: isLoading ? null : _submitMatch,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: AppTheme.softShadow,
                ),
                child: Center(
                  child: isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Text(
                          'Publish Match 🚀',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                        ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
