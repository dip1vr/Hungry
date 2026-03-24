import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hungry/features/home/presentation/widgets/promo_card.dart';

class PromoCarousel extends StatefulWidget {
  const PromoCarousel({super.key});

  @override
  State<PromoCarousel> createState() => _PromoCarouselState();
}

class _PromoCarouselState extends State<PromoCarousel> {
  late PageController _pageController;
  Timer? _timer;

  final List<Map<String, dynamic>> _promos = const [
    {
      'title': 'Midnight\nCravings?',
      'subtitle': 'Flat 50% OFF\n11 PM - 3 AM',
      'code': 'NIGHTWL',
      'image':
          'https://images.unsplash.com/photo-1594212699903-ec8a3eca50f5?w=600&q=80', // Dark Burger
      'bg_colors': [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
      'accent': Color(0xFF00F260), // Neon Green
      'is_dark': true,
    },
    {
      'title': 'Healthy\nIs Tasty!',
      'subtitle': 'Fresh Salads &\nBowls at ₹149',
      'code': 'FRESH100',
      'image':
          'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=600&q=80', // Salad
      'bg_colors': [Color(0xFF11998e), Color(0xFF38ef7d)],
      'accent': Colors.blue,
      'is_dark': false,
    },
    {
      'title': 'Biryani\nFeast',
      'subtitle': 'Buy 1 Get 1\nOn Party Packs',
      'code': 'PARTYON',
      'image':
          'https://images.unsplash.com/photo-1589302168068-964664d93dc0?w=600&q=80', // Biryani
      'bg_colors': [Color(0xFFFF416C), Color(0xFFFF4B2B)],
      'accent': Color(0xFFFFD700), // Gold
      'is_dark': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    // Start at a reasonable number to allow "infinite" scrolling.
    // Reduced from 1000 to 50 to avoid layout precision errors.
    int initialPage = 50 * _promos.length;
    _pageController = PageController(
      viewportFraction: 0.9,
      initialPage: initialPage,
    );
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: PageView.builder(
        controller: _pageController,
        // padEnds: false, // Removed to avoid layout assertions
        physics: const BouncingScrollPhysics(),
        // Infinite items
        itemBuilder: (context, index) {
          // Use modulo to cycle through data
          final promo = _promos[index % _promos.length];
          return Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: RepaintBoundary(child: PromoCard(data: promo)),
          );
        },
      ),
    );
  }
}
