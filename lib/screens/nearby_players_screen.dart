import 'package:flutter/material.dart';

class NearbyPlayersScreen extends StatelessWidget {
  const NearbyPlayersScreen({super.key});

  final Color _bgColor = const Color(0xFFF8F5FF);
  final Color _primaryColor = const Color(0xFF0052D0);
  final Color _primaryContainer = const Color(0xFF799DFF);
  final Color _secondaryColor = const Color(0xFFA33800);
  final Color _secondaryContainer = const Color(0xFFFFC4AF);
  final Color _onSecondaryContainer = const Color(0xFF812B00);
  final Color _surfaceContainerLowest = const Color(0xFFFFFFFF);
  final Color _surfaceContainerHighest = const Color(0xFFD8DAFF);
  final Color _surfaceContainerHigh = const Color(0xFFDFE0FF);
  final Color _surfaceContainer = const Color(0xFFE6E6FF);
  final Color _textColor = const Color(0xFF272B51);
  final Color _textVariantColor = const Color(0xFF545881);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: Column(
        children: [
          _buildAppBar(context),
          Expanded(
            child: Stack(
              children: [
                Column(
                  children: [
                    _buildMapHeader(),
                    const Expanded(
                      child: SizedBox(),
                    ), // Space for the content canvas to overlap
                  ],
                ),
                Positioned(
                  top: 270, // Overlap the map header
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _buildContentCanvas(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      color: _bgColor,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 24,
        right: 24,
        bottom: 16,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  child: Icon(Icons.arrow_back, color: _primaryColor),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Not So Alone',
                style: TextStyle(
                  color: _primaryColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Lexend',
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(24),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: Icon(Icons.filter_list, color: _primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapHeader() {
    return Container(
      height: 300,
      width: double.infinity,
      color: _surfaceContainerHigh,
      child: Stack(
        children: [
          Positioned.fill(
            child: ColorFiltered(
              colorFilter: const ColorFilter.mode(
                Colors.grey,
                BlendMode.saturation,
              ),
              child: Opacity(
                opacity: 0.8,
                child: Image.network(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuBHDYs3b5x2XTPgeNlp9-VMpde1dtkcxizNcVcMEp6UCnB6WCZx-IE3Q0p3H0YWj27Tj_AoEF9Qi48MONp1xUxbTEAVZu-ikaDfWj8Bv7t7YYRIpDw29g35WlEafumq79al6eO7RuceRXJJlHA7119AJJXp-20LyQHYe6YAMYVs_WeN2qA7vDtR4n7nDoo7LoFgsbduOPKZWV6bih07SncutecK7Ea00i1ukd3KKYaBRHwHL-oGDXlCWVVZuBCziX8y6pQY2WXBpug',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned(
            top: 75,
            left: 100,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _primaryColor,
                shape: BoxShape.circle,
                border: Border.all(color: _surfaceContainerLowest, width: 2),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 4),
                ],
              ),
              child: const Icon(
                Icons.sports_basketball,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
          Positioned(
            top: 150,
            right: 80,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _secondaryColor,
                shape: BoxShape.circle,
                border: Border.all(color: _surfaceContainerLowest, width: 2),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 4),
                ],
              ),
              child: const Icon(
                Icons.sports_soccer,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [_bgColor, Colors.transparent],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentCanvas() {
    return Container(
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: _buildFiltersRow(),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Nearby Players',
                  style: TextStyle(
                    color: _textColor,
                    fontFamily: 'Lexend',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '24 active now',
                  style: TextStyle(
                    color: _textVariantColor,
                    fontFamily: 'Manrope',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(child: _buildPlayerList()),
        ],
      ),
    );
  }

  Widget _buildFiltersRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip('All', isSelected: true),
          const SizedBox(width: 12),
          _buildFilterChip('Basketball'),
          const SizedBox(width: 12),
          _buildFilterChip('Football'),
          const SizedBox(width: 12),
          _buildFilterChip('Cricket'),
          const SizedBox(width: 12),
          _buildFilterChip('Tennis'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, {bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? _primaryColor : _surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : _primaryColor,
          fontFamily: 'Lexend',
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildPlayerList() {
    return ListView(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 40),
      children: [
        _buildPlayerCard(
          name: 'Alex Rivers',
          sport: 'BASKETBALL',
          skill: 'Intermediate',
          sportColorBg: _secondaryContainer,
          sportColorText: _onSecondaryContainer,
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuDh1I3rVwSCx0itb7zU4rB4hUziBJjty_E8qkz7rhmjrIxsAR-_QEW3sN-G78Aatc1abt9SSpj__J-4ha-tgruTMlahfJcnvLTfqZS8DssRGyltEiJrupCFpn-dYFJF3feTwIo3vRe6etGrT4-pftrsQHzBcFYUGVvUbr0o43K_w2VYIDwtr8aEOwoXled7se3WeNLmQJURX0Qn71LzJzkYWZf-E1KmqJ23bw1RfDEbLr0LI-9pyB9PFANjugUTGXbKbcY9e73Nd8Q',
          avatarBorderColor: _primaryContainer,
          isOnline: true,
        ),
        const SizedBox(height: 16),
        _buildPlayerCard(
          name: 'Jordan Lee',
          sport: 'FOOTBALL',
          skill: 'Pro',
          sportColorBg: _surfaceContainerHighest,
          sportColorText: _primaryColor,
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuBZiV0AMvu4qXNKn5ASM7_xrW7n-N909bvjl8zAkSrZgoYL9VkbAnCiS6DPb6uuN9DLzX7z16bsSky2XxIw2wk_tcUwMkLZXGVE6DkF2QuqkEcP9Y9IPB-xZPjixw0k2K8ugRCbgmhSfpneCNfRDySIhFEKbiCfLmMMeUpoxZbj6K3wwQOa4VrYWAMqJLFySKzLHCQ97E7juWRsfnUhQjf5oKB0OA7TpsASv847RYv0EtQQjwhr1Imj6HnBND7KzT9T-dixGVrDnnY',
          avatarBorderColor: _surfaceContainer,
        ),
        const SizedBox(height: 16),
        _buildPlayerCard(
          name: 'Marcus Chen',
          sport: 'CRICKET',
          skill: 'Beginner',
          sportColorBg: _secondaryContainer,
          sportColorText: _onSecondaryContainer,
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuD-JnFGOdwl9FnsL3L0v16EEyGr3nmT2aUDhl3rVcIl-6BkDotMaA2DxYR9YBmHdEs2x5E8OWGRk23WeG8j_fZ_1YXv4UU_odQ_lPtlryTG-Tt7crDLaTB0bNNK0Hup2cTHX4NuEL2KZq6AcZnhjwK8ZZXAEsZ8szRD5xQMD1LdzQOfFADbXEU8USpXZrAYzpngwCh3qB6mQDJUCJ7Mk1n3C79eg8tQi2zpsReCNy3m-1e8LhScUKpezp885PA7nINeFz5JVEl6-5k',
          avatarBorderColor: _surfaceContainer,
        ),
        const SizedBox(height: 16),
        _buildPlayerCard(
          name: 'Sarah Taylor',
          sport: 'TENNIS',
          skill: 'Intermediate',
          sportColorBg: _surfaceContainerHighest,
          sportColorText: _primaryColor,
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuDd4VCmaer1zi7YxTgwKCP-EDPFLopNI0dRTiFvYgR9zIkbcFpebQd6L9cwd8MytdNLshddqrztRBnhFFGK72QJAgYqe0xrVdgSLULbrih4NJgtGXZ1RF0vRknbG47Gd68xpQ8P7lJ-nAmCSqF749efTxP1Skvs3iE6_z2gIOmbn1mI9NF2KPMO03WCc7ideftFmQIXP3JMXo9Mof0EDnfKhUCmeuFCMjTrLoQ4s-gyhoodpRmMOF1dXT4fPvNZMX8hZkwWOavbGUg',
          avatarBorderColor: _surfaceContainer,
        ),
      ],
    );
  }

  Widget _buildPlayerCard({
    required String name,
    required String sport,
    required String skill,
    required Color sportColorBg,
    required Color sportColorText,
    required String imageUrl,
    required Color avatarBorderColor,
    bool isOnline = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: _textColor.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: avatarBorderColor, width: 2),
                      image: DecorationImage(
                        image: NetworkImage(imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  if (isOnline)
                    Positioned(
                      bottom: -4,
                      right: -4,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF797F0), // tertiary-container
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.bolt,
                          color: const Color(
                            0xFF610E63,
                          ), // on-tertiary-container
                          size: 14,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      color: _textColor,
                      fontFamily: 'Lexend',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: sportColorBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          sport,
                          style: TextStyle(
                            color: sportColorText,
                            fontFamily: 'Manrope',
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        skill,
                        style: TextStyle(
                          color: _textVariantColor,
                          fontFamily: 'Manrope',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_primaryColor, _primaryContainer],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: _primaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Text(
              'Message',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Lexend',
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
