import 'package:flutter/material.dart';
import '../widgets/event_calendar_popup.dart';

class VenueDetailsScreen extends StatelessWidget {
  const VenueDetailsScreen({super.key});

  final Color _bgColor = const Color(0xFFF8F5FF);
  final Color _primaryColor = const Color(0xFF0052D0);
  final Color _primaryContainer = const Color(0xFF799DFF);
  final Color _secondaryColor = const Color(0xFFA33800);
  final Color _secondaryContainer = const Color(0xFFFFC4AF);
  final Color _onSecondaryContainer = const Color(0xFF812B00);
  final Color _tertiaryColor = const Color(0xFF8D3A8B);
  final Color _surfaceContainerLowest = const Color(0xFFFFFFFF);
  final Color _surfaceContainerHigh = const Color(0xFFDFE0FF);
  final Color _surfaceContainerLow = const Color(0xFFF1EFFF);
  final Color _surfaceContainer = const Color(0xFFE6E6FF);
  final Color _textColor = const Color(0xFF272B51);
  final Color _textVariantColor = const Color(0xFF545881);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(
              bottom: 120,
            ), // Padding for the fixed bottom button
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroImage(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Offset canvas overlap
                      Transform.translate(
                        offset: const Offset(0, -40),
                        child: _buildVenueHeaderInfo(),
                      ),
                      _buildBentoGrid(),
                      const SizedBox(height: 32),
                      _buildDescriptionSection(),
                      const SizedBox(height: 32),
                      _buildPeopleSection(),
                      const SizedBox(height: 32),
                      _buildReviewsSection(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _buildAppBar(context),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildStickyActionButton(context),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: MediaQuery.of(context).padding.top + 64,
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top,
          left: 24,
          right: 24,
        ),
        decoration: BoxDecoration(color: _bgColor.withOpacity(0.7)),
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
                  'Venue Details',
                  style: TextStyle(
                    color: _textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Lexend',
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
                child: Icon(Icons.share, color: _primaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroImage() {
    return SizedBox(
      height: 397,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            'https://lh3.googleusercontent.com/aida-public/AB6AXuDkf5rJBrR0C8DeGpYnI2Ikny2obUVq1kii353LZ3QrA4Ij3tg9FW6xwqqG_idyy93KGqpZcgufiy8D7Xodd8l9Xx5cW-Wxpg5zV6bBO0Gw_Kf1YjV6cvorsg0aaShVfgzuZATb-NT-lDzWVnrJjV5-D8_NgEPKe1M4FlUcdtSV1cSHuOeMbuBCFzkczTLKCnzhyhXkiMiUIuaGwKfWEwJpwPNupfO0e_LaG3PQhYXR8nvphzOBCNSOLy2NSRZbcQDrlHE3x-OoytU',
            fit: BoxFit.cover,
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [_bgColor, Colors.transparent, Colors.transparent],
                  stops: const [0.0, 0.3, 1.0],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVenueHeaderInfo() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _textColor.withOpacity(0.06),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
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
                  'Greenfield Arena',
                  style: TextStyle(
                    color: _textColor,
                    fontFamily: 'Lexend',
                    fontSize: 28, // Scaled roughly to 3xl
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _secondaryContainer,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, color: _onSecondaryContainer, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '4.8',
                      style: TextStyle(
                        color: _onSecondaryContainer,
                        fontFamily: 'Lexend',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on, color: _primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Boring Road, Patna',
                style: TextStyle(
                  color: _textVariantColor,
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

  Widget _buildBentoGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: 160,
                decoration: BoxDecoration(
                  color: _surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ColorFiltered(
                        colorFilter: const ColorFilter.mode(
                          Colors.grey,
                          BlendMode.saturation,
                        ),
                        child: Image.network(
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuDZI8DZOZwcDhESQUcsjCeA6uMSbGdPpW4jYowMZIKR7WH3tVd3y-OJE6BviL-Pxwka4Ae0x6D5LRbuj9b9BGml9io4WqXg-yqqal0y-Q18hgfHMZYxJmPN_fMWwA6IpAtWW3720TDRG_6LbNIn6niaJPUjpduUXU6A_zBE8tbA2aB6mVczmB_5HEMqu4N7zC2q847CtXVSBtQQ9oL26Ix5C6v9WP4eKuiZBxS48KkMy1f1bJprdvTcRQcq7YEMms6y1lI9lOWw6Uk',
                          fit: BoxFit.cover,
                        ),
                      ),
                      Center(
                        child: Icon(
                          Icons.location_on,
                          color: _primaryColor,
                          size: 48,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_primaryColor, _primaryContainer],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Next Available Match',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Lexend',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'DATE',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontFamily: 'Manrope',
                            fontSize: 12,
                            letterSpacing: 2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Tomorrow, 24th Oct',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Lexend',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Icon(Icons.event, color: Colors.white.withOpacity(0.5)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TIME',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontFamily: 'Manrope',
                            fontSize: 12,
                            letterSpacing: 2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '06:00 PM - 08:00 PM',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Lexend',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Icon(Icons.schedule, color: Colors.white.withOpacity(0.5)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 6,
              height: 32,
              decoration: BoxDecoration(
                color: _primaryColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'About the Venue',
              style: TextStyle(
                color: _textColor,
                fontFamily: 'Lexend',
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            border: Border(left: BorderSide(color: _primaryColor, width: 4)),
          ),
          child: Text(
            'Experience the peak of performance at Greenfield Arena. Featuring professional-grade high-quality turf, advanced floodlighting for nocturnal matches, and premium amenities. Our facilities include climate-controlled changing rooms and purified water stations to ensure you stay focused on the game.',
            style: TextStyle(
              color: _textVariantColor,
              fontFamily: 'Manrope',
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPeopleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Organizer',
          style: TextStyle(
            color: _textColor,
            fontFamily: 'Lexend',
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _surfaceContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: _primaryColor, width: 2),
                      image: const DecorationImage(
                        image: NetworkImage(
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuDh5Hs_weXJts-TqAC04DOKOtjrs9ZsPp6Hk0kxYAKaOC3vLryLmGY02_t-TJv3qI9naqE93vmXadg7eUVU9EaUgHXvLVNdDvlu6KkUXboGt1EvWbsASQqNzaKmLi2RNHrIWReL6vpL09ZvOczCH8OHb8M_liHeigenHE_2dori-aADptjjfzdoJ0V07qB3GreBFOZyvhqmBdDNIxnyKLLf-gRMSmcSZ4ZtHDXRzASZCT631LVhaqSL6y0AtHSEceWOmfcFEcjDFzM',
                        ),
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
                        border: Border.all(color: _surfaceContainer, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rahul Singh',
                      style: TextStyle(
                        color: _textColor,
                        fontFamily: 'Lexend',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Active Venue Manager',
                      style: TextStyle(
                        color: _textVariantColor,
                        fontFamily: 'Manrope',
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.chat, color: Colors.white, size: 20),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Landowner',
          style: TextStyle(
            color: _textColor,
            fontFamily: 'Lexend',
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _surfaceContainerHigh,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                ),
                padding: const EdgeInsets.all(8),
                child: Image.network(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuBwhTUVHOA8Mko7b_vyj_mdV498oXRyt_kibG40e2Zsw82cXZMnTxGPDzRqWTnke2usH_Zo3bkD8SwAwDCStAUeHIuUchT16HYh1KPjYpiHLjzB6HJquRkEnEgH2Me9388EAYieXsluIqwAsoj8k_D9qd_9TuTLuGw3tBpXii7IimPKtltmOth0Z-a7r76T-QgXJaItHOOGyO_hD83-cvI5w9RSSx4km9xM7Qw1-GtOth8SOf7DRCzpRLXHj7JhMQKGrvwWaoszkR0',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Patna Sports Club',
                        style: TextStyle(
                          color: _textColor,
                          fontFamily: 'Lexend',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.verified, color: _primaryColor, size: 18),
                    ],
                  ),
                  Text(
                    'Certified Partner',
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
        ),
      ],
    );
  }

  Widget _buildReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                Container(
                  width: 6,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _tertiaryColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Community Reviews',
                  style: TextStyle(
                    color: _textColor,
                    fontFamily: 'Lexend',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Text(
              'See All',
              style: TextStyle(
                color: _primaryColor,
                fontFamily: 'Lexend',
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildReviewCard(
          name: 'Ananya K.',
          date: '2 days ago',
          review:
              '"Best turf in Patna! The lighting is perfect for night matches and the crowd is always great."',
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuBXgOt9uj38uBwMplsHlzNU-qY7IcxQ-pTu8SQAmX89Nond2ra9bDCKwtE3AqYgxT1pIlOMAwbLcG240ey7xRGfQgwbuUHFu40GaFaXKJIO6QtXCS9qrsxlb1I1URSb7CinGVnhBy_I1S7g4RmRDQ2Jwe9wqLxcsc62MtBenDyvEXeCYFxg9g-gZlG0yQZVLEx0OJiW0g4pptEG6yEgVe2g7SnajLZF7gnDeP3FsD3RKcup5_LAe5BT2XmAJnzCEBEx-tIo6hDyObs',
        ),
        const SizedBox(height: 16),
        _buildReviewCard(
          name: 'Vikram S.',
          date: '1 week ago',
          review:
              '"Amazing drainage even after rain. The organizer Rahul is very helpful with booking."',
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuA4mkHP67n-t8CHqCM7KWVsfGZxKw3BcTAsuBUgAyortH04U27762NTqdaNeAJsuHlpkCgpeXotQWp6wq45i-vTNBtpFoLA42WeG2RH626v3-d4Q5DqS1g1ZB9hvhxGt_ocfoH9cmb-ZgI6Jx0ozxUmbHh_lpAsUfzK6-gBcVNTwnPXbl2mYF3bkZmT_yT5ANEW045kroSItAAIzqbvBxVlxoCGEvN0yfeHo-LwmTVXmkoGkq5REB3zHhX9vynYo60YuSBv9tHWXKI',
        ),
      ],
    );
  }

  Widget _buildReviewCard({
    required String name,
    required String date,
    required String review,
    required String imageUrl,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border(bottom: BorderSide(color: _surfaceContainer, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _surfaceContainerHigh,
                      image: DecorationImage(
                        image: NetworkImage(imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          color: _textColor,
                          fontFamily: 'Lexend',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: List.generate(
                          5,
                          (index) => Icon(
                            Icons.star,
                            color: _secondaryColor,
                            size: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Text(
                date,
                style: TextStyle(
                  color: _textVariantColor,
                  fontFamily: 'Manrope',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review,
            style: TextStyle(
              color: _textVariantColor,
              fontFamily: 'Manrope',
              fontSize: 14,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyActionButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_bgColor.withOpacity(0.0), _bgColor],
        ),
      ),
      child: Container(
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
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => const EventCalendarPopup(),
            );
          },
          child: const Text(
            'Book Venue',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Lexend',
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}
