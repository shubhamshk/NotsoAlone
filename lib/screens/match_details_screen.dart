import 'package:flutter/material.dart';
import 'match_participants_screen.dart';

class MatchDetailsScreen extends StatelessWidget {
  const MatchDetailsScreen({super.key});

  final Color _bgColor = const Color(0xFFF8F5FF);
  final Color _primaryColor = const Color(0xFF0052D0);
  final Color _primaryContainer = const Color(0xFF799DFF);
  final Color _secondaryColor = const Color(0xFFA33800);
  final Color _secondaryContainer = const Color(0xFFFFC4AF);
  final Color _onSecondaryContainer = const Color(0xFF812B00);
  final Color _tertiaryContainer = const Color(0xFFF797F0);
  final Color _onTertiaryContainer = const Color(0xFF610E63);
  final Color _textColor = const Color(0xFF272B51);
  final Color _textVariantColor = const Color(0xFF545881);
  final Color _surfaceContainer = const Color(0xFFE6E6FF);
  final Color _surfaceContainerLow = const Color(0xFFF1EFFF);
  final Color _surfaceContainerLowest = const Color(0xFFFFFFFF);
  final Color _outlineVariant = const Color(0xFFA6AAD7);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 120),
                    child: Column(
                      children: [
                        _buildHeroImage(),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 32),
                              _buildMatchStats(),
                              const SizedBox(height: 32),
                              _buildJoinedPlayers(context),
                              const SizedBox(height: 32),
                              _buildLocationMeta(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [_bgColor.withOpacity(0.0), _bgColor],
                ),
              ),
              child: _buildJoinButton(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      color: _bgColor,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
          Text(
            'Match Details',
            style: TextStyle(
              color: _textColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Lexend',
            ),
          ),
          InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(24),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: Icon(Icons.share, color: _primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroImage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
      child: Container(
        height: 320,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _textColor.withOpacity(0.08),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
          ],
          image: const DecorationImage(
            image: NetworkImage(
              'https://lh3.googleusercontent.com/aida-public/AB6AXuDj_orFyqFYqq75b8Wi1CeUgBT4frDvIW0vAJIpFgwszcnU2_G7WQpyMFo3CMw7dPg6GbXw5g9yvPk85rRqgsO5Tm6W9W9e5JEPxdZPu7Jk1qx9GK1dGhTGM_HgOUsTtkVyEYAcj4x4a9vvvc4qo4FCmGKS1JE2ynii3JSbY-x_b6FtcNk3RTllFnYLxgAz5cBh1R_LuEcz3uApPaQgLM-WHrdkccPM_0VUxJcayQmqCY4SCXrNoZGND-y5RJpkNAs-CEwwGvg4-UA',
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 24,
              left: 24,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _secondaryContainer,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  'BASKETBALL',
                  style: TextStyle(
                    color: _onSecondaryContainer,
                    fontFamily: 'Lexend',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchStats() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: _surfaceContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.calendar_today,
                            color: _primaryColor,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Date & Time',
                              style: TextStyle(
                                color: _textVariantColor,
                                fontFamily: 'Manrope',
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'Sat, Oct 24 • 18:30',
                              style: TextStyle(
                                color: _textColor,
                                fontFamily: 'Lexend',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _tertiaryContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'LIVE SOON',
                        style: TextStyle(
                          color: _onTertiaryContainer,
                          fontFamily: 'Lexend',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ORGANIZER',
                      style: TextStyle(
                        color: _textVariantColor,
                        fontFamily: 'Manrope',
                        fontSize: 12,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: _primaryColor, width: 2),
                            image: const DecorationImage(
                              image: NetworkImage(
                                'https://lh3.googleusercontent.com/aida-public/AB6AXuA-a88jsRkKyzY4y8doC7oxInX3T9v5QDRv-l9aSxVXYq5m4Li1tjfn2dcYDkYNlqDBz6Zm0A8HxJP23JIxBbl3ZZcP38-TjCUWpATveVJArkRgFR4185A4TN4gyqjcCbf-3tGrRSUmEfFN1GcJaFgsp_ymBt5Fuy5hdlND5OzGVDqMKNqywUD6ypbm5sDEqHNvtucanLl1LZUcAqmlHULGOqJG1IjTP1SU3AXM90eHxf-3YlSXLlglEpsUJy-6ROGrrHGxPPmhv5c',
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Marcus Chen',
                          style: TextStyle(
                            color: _textColor,
                            fontFamily: 'Lexend',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'VENUE OWNER',
                      style: TextStyle(
                        color: _textVariantColor,
                        fontFamily: 'Manrope',
                        fontSize: 12,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Stack(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: NetworkImage(
                                    'https://lh3.googleusercontent.com/aida-public/AB6AXuCDJ1aqz97pjGaFyQFTnvzdhVfC9Ao63LsbbY-4hTA359Ge2_3M1q-eMkAVfLLfu7r7GOA31xvkc1aua9ZmSNIKA4_mgPM32p8x0qCUw_S4rwMAHObMzRs1XE9ElgqwlCll0hkCYgBfey9rTfY2bDYQ1XSbDerRZg7p9miKznRAq3LP1E1DT_1BKLlmhSxJwyzKAQWmnlrwyjAfX_N9Jnmjkcs9WIaAuSZaGtO2QiQT9ygUv0mNn7bifHzsSlSS8p84cXEwfmhH82c',
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: -2,
                              right: -2,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: _primaryColor,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.verified,
                                  color: Colors.white,
                                  size: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Elite Arena',
                          style: TextStyle(
                            color: _textColor,
                            fontFamily: 'Lexend',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildJoinedPlayers(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  'Joined Players',
                  style: TextStyle(
                    color: _textColor,
                    fontFamily: 'Lexend',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '(8/12)',
                  style: TextStyle(
                    color: _textVariantColor,
                    fontFamily: 'Manrope',
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MatchParticipantsScreen(),
                  ),
                );
              },
              child: Row(
                children: [
                  Text(
                    'See All',
                    style: TextStyle(
                      color: _primaryColor,
                      fontFamily: 'Lexend',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.open_in_new, color: _primaryColor, size: 16),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: _surfaceContainerLowest,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              _buildPlayerRow(
                name: 'Sarah Jenkins',
                roleRank: 'Guard • Rank S',
                imageUrl:
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuBUcuK2LTrXRF7xfb-0t5kz8fZS5d3gsTt1d62tzOZANknCPMzIwnYnugrzWtsexWf2rONmDp__-k3rXkr-i2-xUwmLpNfKC6XDNgS4X6mPVbXCzVQq21FGsIhP9FqTi0bBlHpt0wZZP_rOYZCgxQXz2i8YyDVyAOJkGh4-otrUXWHzryNiffxiA-10iV_Sw1_zcxVhNWrI4p_p3Roxog2hR7HljaHZ0g5zH7oprAj7P9a6T88cgLEH6nG3ZXdWvdV9xvySrDcaJEo',
              ),
              Divider(height: 1, color: _surfaceContainer.withOpacity(0.5)),
              _buildPlayerRow(
                name: 'David Ortiz',
                roleRank: 'Forward • Rank A',
                imageUrl:
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuDj_orFyqFYqq75b8Wi1CeUgBT4frDvIW0vAJIpFgwszcnU2_G7WQpyMFo3CMw7dPg6GbXw5g9yvPk85rRqgsO5Tm6W9W9e5JEPxdZPu7Jk1qx9GK1dGhTGM_HgOUsTtkVyEYAcj4x4a9vvvc4qo4FCmGKS1JE2ynii3JSbY-x_b6FtcNk3RTllFnYLxgAz5cBh1R_LuEcz3uApPaQgLM-WHrdkccPM_0VUxJcayQmqCY4SCXrNoZGND-y5RJpkNAs-CEwwGvg4-UA',
              ), // re-used image to avoid another link
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerRow({
    required String name,
    required String roleRank,
    required String imageUrl,
  }) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
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
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      roleRank,
                      style: TextStyle(
                        color: _textVariantColor,
                        fontFamily: 'Manrope',
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Icon(Icons.chevron_right, color: _outlineVariant),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationMeta() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: _secondaryColor),
              const SizedBox(width: 12),
              Text(
                'Downtown Sports Complex, Court 4',
                style: TextStyle(
                  color: _textColor,
                  fontFamily: 'Manrope',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: const DecorationImage(
                image: NetworkImage(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuCJZzEuhsASybWfTSZJEOOTj2dpfi9N5nUNlI-HHHQMfWdMJTtE7enM4Y7anDVNhUYeu-brrp1nZ6Nfc08aGfGjK6K43v3-2AKR8jenKfbQU1AutAa-M1Va6gS-9rLSJEHOVfN7qTfyudhw1Ct3wtI85Hy9AUv97Xg517SAp0VwfUnmRIIVWvEiQwU48vwo3Zu1jJYxViY4rTqw6E3SkNRzqGnRobQHXDeAK4WlFNtBQ0pp4vOCf01BPRA2e-L-4UoHK9hdqqxEER0',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJoinButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_primaryColor, _primaryContainer],
        ),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Joined match successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.sports_basketball, color: Colors.white),
            const SizedBox(width: 12),
            const Text(
              'JOIN MATCH',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Lexend',
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
