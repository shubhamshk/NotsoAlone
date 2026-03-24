import 'package:flutter/material.dart';

class MatchParticipantsScreen extends StatelessWidget {
  const MatchParticipantsScreen({super.key});

  final Color _bgColor = const Color(0xFFF8F5FF);
  final Color _primaryColor = const Color(0xFF0052D0);
  final Color _primaryContainer = const Color(0xFF799DFF);
  final Color _secondaryContainer = const Color(0xFFFFC4AF);
  final Color _onSecondaryContainer = const Color(0xFF812B00);
  final Color _tertiaryContainer = const Color(0xFFF797F0);
  final Color _onTertiaryContainer = const Color(0xFF610E63);
  final Color _textColor = const Color(0xFF272B51);
  final Color _textVariantColor = const Color(0xFF545881);
  final Color _surfaceContainer = const Color(0xFFE6E6FF);
  final Color _surfaceContainerLowest = const Color(0xFFFFFFFF);
  final Color _surfaceContainerHigh = const Color(0xFFDFE0FF);
  final Color _outlineColor = const Color(0xFF70749E);

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
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          _buildHeroCard(),
                          const SizedBox(height: 32),
                          _buildListHeader(),
                          const SizedBox(height: 24),
                          _buildPlayerList(),
                          const SizedBox(height: 48),
                          _buildInviteSection(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(bottom: 24, left: 24, right: 24, child: _buildBottomNav()),
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
                'Match Participants',
                style: TextStyle(
                  color: _textColor,
                  fontSize: 24, // Display size adjusted for generic layout
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Lexend',
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Icon(Icons.notifications_outlined, color: _primaryColor),
              const SizedBox(width: 12),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _primaryColor, width: 2),
                  color: _surfaceContainerHigh,
                  image: const DecorationImage(
                    image: NetworkImage(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuCszSFNHY7lj_cEHRvq6TwpR-897VDajK-n2iTUK0oA3DYl2D9h4YPTwhspG2cT94RxzdKpEat4LKzu1zF6FHcsMPdrixTY1dkKk_j5twJU08dlgaEQp_uaZ2UIptM0EkblxzZKjEC0wdGCsC83K2g43tBiBxZhx_6zq12LcTrrPUZf9taEbXrvkYUON5Ci3KxWTigeLr_dV2roY5ZnxdlPrKsF2K9GpG0CHcEezbj-BoKC01flKGR98KOJHs0KKTdQ2fvqyItLyt0',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_primaryColor, _primaryContainer],
        ),
        boxShadow: [
          BoxShadow(
            color: _textColor.withOpacity(0.08),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.groups,
                    color: Colors.white.withOpacity(0.8),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'TEAM ROSTER',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                '12 / 16 Joined',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Lexend',
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '4 slots remaining for the Sunday Showdown',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontFamily: 'Manrope',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildListHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Active Athletes',
          style: TextStyle(
            color: _textColor,
            fontFamily: 'Lexend',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: _secondaryContainer,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Text(
            'Basketball',
            style: TextStyle(
              color: _onSecondaryContainer,
              fontFamily: 'Lexend',
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerList() {
    return Column(
      children: [
        _buildPlayerCard(
          name: 'Marcus Thompson',
          position: 'Point Guard',
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuA0vGvMOf3EyEMuICxy3v30ZdIhI8kRYqTNdmCJMdLNCi8kz_aEDeYqF0kD4VcLYjWtMCSE2wX3URXeZheWFH4wWgzBScwGjsVJ0VeHT5E2sKbJ22KymK866JnuaptnS00LFPxsfrUXBeytwkpaMtkSzscC_1_P00_qYbj35N0D6RsHG13F6LMCdBTi1F8KkCk2WRgANVH2c_5w5Zy1zyTAJKzl0jh6LOWZ8fNEZRuxWCDINdABq19qLLp04nONJKorvt9mRVoEGCg',
          rankDisplay: 'Rank S',
          skillTier: 'ELITE',
          isCaptain: true,
        ),
        const SizedBox(height: 24),
        _buildPlayerCard(
          name: 'Sarah Jenkins',
          position: 'Small Forward',
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuAEZ1iOYe7Od2sR31wh9FB9BX8mtmR3gzabOJDcRCyNiNzrpVFMr1i8woyawIQ-QSM3TGUH2DMkt6hKK6c_zmMQy0H-Ex6GdwmNJTGYtfYRpuTyE9gkZFzNaZn6THeMYCtbCfr_PPq5TXXbbQFGwwbNHqEME-ddmCqhl88xxGMEsinbKKDRPQBgy5yx_dgxmxfYUVa8R09a5FMIqLTrz9PRBfl_lHKJfSwaB0ZvLSssT7fqi43elngcvFwPLGCup6dVq0QtvAU6Zms',
          rankDisplay: 'Rank A',
          skillTier: 'PRO',
        ),
        const SizedBox(height: 24),
        _buildPlayerCard(
          name: 'David Chen',
          position: 'Center',
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuDWX7Q2djqYy-BLTXvOHYWLOyDTl4q9M7niEdYEj5AHf9BGHygi9ItAfa3qhLmldeOvnXCc_K0gEap9RCnxB0aFEYqXF5aN2n0V3Bpc0ByPzRHROiTpccuWYzj0hp1NR3-JKdX4xOTSQBfLV2lGUz-Ef3voo0eW9WSqSwx90mm1FlzN6DVdQ4jLw1z6dFdCtxEzrsfXq8seWLhnjNoYau7OU5Dri5pXV-IPz7_srDxodO4OdGUIh_wJi3FC2Tv1HIu23z5mSlgy-Os',
          rankDisplay: 'Rank S',
          skillTier: 'ELITE',
        ),
        const SizedBox(height: 24),
        _buildPlayerCard(
          name: 'Elena Rodriguez',
          position: 'Shooting Guard',
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuC70_k2mHbbWToyUQ8KAX5LtB32NOE7LtjGa3i_xkwXBwzds7802V0HwrRo4rnIx7ucX1fKWG3F4bjBRwwptXjzOumwD0hjAJPlNT3AaVuVKOkOEIXEusFNDbCQ9neNGXTRoaHmbS-b706Ad8OwfpWtdGuKosbEkFtkv3ukFk4ydEPvZozigJshS1Z7zk0oHBNYiG8LSB8uyJQfzeE7_2MHiqQOCmqyEh6LVT0L9qKji_ldf-zNmgRUDHPsKo5ejOtIntHFTgHSoTY',
          rankDisplay: 'Rank B',
          skillTier: 'ADVANCED',
        ),
        const SizedBox(height: 24),
        _buildPlayerCard(
          name: 'Jordan Smith',
          position: 'Power Forward',
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuDGiZlUOYjfd-tkKbbqXMJ3Sd-zmHEAwYmGkV9PeF1ufVvA7KSsQoio-cBtcwtSK4N6Mu8aNFwQJw4gUcKixv5k2dFEdA-nUuen8bXnufI4S4p-DOOlWuOXmzEgBH-w99OrW9XEuwW-b1C_JIQmVZLkRGfDXozAsvufslfx3sff1n135XUuKsblPBmKFoF-fmUhDBdA4bnPKHcAVQCfS1GzaWllvxrn0iHexO1CBWS4KrGX4q-JXUwdcp8UCm-IV0GbwLHC6npo64I',
          rankDisplay: 'Rank A',
          skillTier: 'PRO',
        ),
        const SizedBox(height: 24),
        _buildPlayerCard(
          name: 'Aisha Kone',
          position: 'Point Guard',
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuAUFkx4LZZIEnt5anCqZzodKdWh2eexKjaCw7mpML5sCb9CJ7nQXeHtQY33xSjZcSTIRaJcayPuI-vo8BH973ECXirtRN0vaYQL2bd3Usxjdgl8DyS7XejKBqbpujRL2C77bfm3ykbYhreTmGhmrlIwwa974MH3T6d_SJMrvR9LJDO1Z04HwVGcE7bzdXge7BpFSUeYztfDuP31iB3mGFrOyL1lFFJPWT6mxBIr97jSZae2fuVLnnQzDp6jYfIwF1tVLQT0XtF4TJw',
          rankDisplay: 'Rank S',
          skillTier: 'ELITE',
        ),
      ],
    );
  }

  Widget _buildPlayerCard({
    required String name,
    required String position,
    required String imageUrl,
    required String rankDisplay,
    required String skillTier,
    bool isCaptain = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.transparent),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  if (isCaptain)
                    Positioned(
                      top: -8,
                      left: -8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _tertiaryContainer,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 2),
                          ],
                        ),
                        child: Text(
                          'CAPTAIN',
                          style: TextStyle(
                            color: _onTertiaryContainer,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            fontFamily:
                                'Manrope', // Using Manrope as robust fallback for 900 weight here
                          ),
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
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    position,
                    style: TextStyle(
                      color: _textVariantColor,
                      fontFamily: 'Manrope',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _surfaceContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  rankDisplay,
                  style: TextStyle(
                    color: _primaryColor,
                    fontFamily: 'Lexend',
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                skillTier,
                style: TextStyle(
                  color: _outlineColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInviteSection() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: _surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.share, color: _primaryColor, size: 48),
          const SizedBox(height: 16),
          Text(
            'Know someone else?',
            style: TextStyle(
              color: _textColor,
              fontFamily: 'Lexend',
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Invite your teammates to join this match and fill the remaining 4 slots.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _textVariantColor,
              fontFamily: 'Manrope',
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 4,
            ),
            child: const Text(
              'Invite Friends',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Lexend',
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: _bgColor.withOpacity(0.8),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: _textColor.withOpacity(0.08),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.home, 'Home', false),
          _buildNavItem(Icons.sports_basketball, 'All Sports', true),
          _buildNavItem(Icons.person, 'Profile', false),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    if (isActive) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [_primaryColor, _primaryContainer]),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Manrope',
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Column(
          children: [
            Icon(icon, color: _textColor.withOpacity(0.6)),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: _textColor.withOpacity(0.6),
                fontFamily: 'Manrope',
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
