import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_theme.dart';

/// Blood group options shown as quick-pick chips
const List<String> _bloodGroups = ['A+', 'A−', 'B+', 'B−', 'AB+', 'AB−', 'O+', 'O−'];

class MedicalIdScreen extends StatefulWidget {
  const MedicalIdScreen({super.key});

  @override
  State<MedicalIdScreen> createState() => _MedicalIdScreenState();
}

class _MedicalIdScreenState extends State<MedicalIdScreen> {
  // ── Colors ─────────────────────────────────────────────────
  final Color _bg = AppTheme.background;
  final Color _primary = AppTheme.primary;
  final Color _surface = AppTheme.surface;
  final Color _surfaceHigh = AppTheme.surfaceContainer;
  final Color _textMain = AppTheme.textMain;
  final Color _textVariant = AppTheme.textVariant;
  final Color _outline = AppTheme.outline;

  // ── Controllers ────────────────────────────────────────────
  final _bloodGroupController = TextEditingController();
  final _addressController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _conditionsController = TextEditingController();

  // ── State ──────────────────────────────────────────────────
  String _playerName = '';
  String? _selectedBloodGroup;
  bool _isSaving = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMedicalData();
  }

  @override
  void dispose() {
    _bloodGroupController.dispose();
    _addressController.dispose();
    _emergencyContactController.dispose();
    _conditionsController.dispose();
    super.dispose();
  }

  // ── Load ───────────────────────────────────────────────────
  Future<void> _loadMedicalData() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    try {
      final data = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (data != null && mounted) {
        setState(() {
          _playerName = (data['full_name'] ?? data['username'] ?? '').toString();
          if (data.containsKey('medical_data') && data['medical_data'] != null) {
            final med = data['medical_data'] as Map<String, dynamic>;
            _addressController.text = (med['address'] ?? '').toString();
            _emergencyContactController.text =
                (med['emergency_contact'] ?? '').toString();
            _conditionsController.text =
                (med['medical_conditions'] ?? '').toString();

            final bg = (med['blood_group'] ?? '').toString();
            _bloodGroupController.text = bg;
            if (_bloodGroups.contains(bg)) {
              _selectedBloodGroup = bg;
            }
          }
          _isLoading = false;
        });
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('MedicalIdScreen load error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Save ───────────────────────────────────────────────────
  Future<void> _save() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    setState(() => _isSaving = true);

    final bloodGroup = _selectedBloodGroup ?? _bloodGroupController.text.trim();

    final payload = <String, dynamic>{
      'medical_data': {
        'address': _addressController.text.trim(),
        'blood_group': bloodGroup,
        'emergency_contact': _emergencyContactController.text.trim(),
        'medical_conditions': _conditionsController.text.trim(),
      },
    };

    try {
      await Supabase.instance.client.from('profiles').update(payload).eq('id', user.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Medical ID saved ✓'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true); // signal refresh
    } catch (e) {
      debugPrint('MedicalIdScreen save error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ── Helpers ────────────────────────────────────────────────
  Widget _field(
    String label,
    TextEditingController ctrl, {
    IconData icon = Icons.edit_outlined,
    TextInputType keyboard = TextInputType.text,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _outline.withOpacity(0.15)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: TextField(
          controller: ctrl,
          keyboardType: keyboard,
          maxLines: maxLines,
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 15,
            color: _textMain,
          ),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(
              fontFamily: 'Manrope',
              color: _textVariant,
              fontSize: 14,
            ),
            prefixIcon: Icon(icon, color: _primary, size: 20),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: _primary,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(
              fontFamily: 'Lexend',
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: _textMain,
            ),
          ),
        ],
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(
          backgroundColor: _bg,
          elevation: 0,
          leading: const BackButton(),
          title: const Text('Medical ID'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg.withOpacity(0.95),
        elevation: 0,
        shadowColor: _outline.withOpacity(0.1),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: _textMain),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Medical ID',
          style: TextStyle(
            fontFamily: 'Lexend',
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: _textMain,
          ),
        ),

      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero banner ──────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFd32f2f), Color(0xFFb71c1c)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.health_and_safety,
                        color: Colors.white, size: 36),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'EMERGENCY MEDICAL ID',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _playerName.isNotEmpty ? _playerName : 'Player',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontFamily: 'Lexend',
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Tap Save to update your Medical ID',
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 12,
                            fontFamily: 'Manrope',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ── Blood Group ──────────────────────────────────
            _sectionLabel('Blood Group'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _bloodGroups.map((bg) {
                final selected = _selectedBloodGroup == bg;
                return GestureDetector(
                  onTap: () => setState(() {
                    _selectedBloodGroup = bg;
                    _bloodGroupController.text = bg;
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFFd32f2f)
                          : _surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected
                            ? const Color(0xFFd32f2f)
                            : _outline.withOpacity(0.2),
                        width: selected ? 2 : 1,
                      ),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              )
                            ]
                          : [],
                    ),
                    child: Text(
                      bg,
                      style: TextStyle(
                        fontFamily: 'Lexend',
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: selected ? Colors.white : _textMain,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            // Custom blood group field for rare types
            _field(
              'Or enter manually (e.g. Rh-null)',
              _bloodGroupController,
              icon: Icons.bloodtype_outlined,
            ),
            const SizedBox(height: 24),

            // ── Emergency Contact ────────────────────────────
            _sectionLabel('Emergency Contact'),
            _field(
              'Emergency Contact Number',
              _emergencyContactController,
              icon: Icons.emergency_share_outlined,
              keyboard: TextInputType.phone,
            ),
            const SizedBox(height: 24),

            // ── Home Address ─────────────────────────────────
            _sectionLabel('Home Address'),
            _field(
              'Street, City, Pin Code',
              _addressController,
              icon: Icons.home_outlined,
              maxLines: 2,
              keyboard: TextInputType.streetAddress,
            ),
            const SizedBox(height: 24),

            // ── Medical Conditions ───────────────────────────
            _sectionLabel('Health Issues & Allergies'),
            Container(
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _outline.withOpacity(0.15)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _conditionsController,
                  maxLines: 5,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 15,
                    color: _textMain,
                  ),
                  decoration: InputDecoration(
                    hintText:
                        'e.g. Diabetes, Asthma, Penicillin allergy, Hypertension…',
                    hintStyle: TextStyle(
                      color: _textVariant.withOpacity(0.6),
                      fontFamily: 'Manrope',
                      fontSize: 14,
                    ),
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(bottom: 68),
                      child: Icon(Icons.medical_information_outlined,
                          size: 20),
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),

            // ── Info banner ──────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.amber.withOpacity(0.3)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: Colors.amber, size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'This information appears instantly when the SOS button is pressed — accessible even from the lock screen. Keep it accurate.',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 13,
                        color: Colors.amber,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // ── Save FAB ─────────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isSaving ? null : _save,
        backgroundColor: const Color(0xFFd32f2f),
        icon: _isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
            : const Icon(Icons.save_alt_rounded, color: Colors.white),
        label: const Text(
          'Save Medical ID',
          style: TextStyle(
            fontFamily: 'Lexend',
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
