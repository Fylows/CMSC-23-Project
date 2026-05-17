import 'package:flutter/material.dart';
import 'package:elbi_eats/widgets/searchbar.dart';
import 'package:elbi_eats/widgets/product_card.dart';
import 'package:elbi_eats/widgets/small_product_card.dart';
import 'package:elbi_eats/widgets/leaderboard_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: const [
            _LeaderboardSection(),
            SizedBox(height: 14),
            _TopPicksSection(),
            SizedBox(height: 14),
            _PostedItemsSection(),
            SizedBox(height: 14),
          ],
        ),
      ),
    );
  }
}

// ─── Top Picks Section ────────────────────────────────────────────────────────

class _TopPicksSection extends StatelessWidget {
  const _TopPicksSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF9B7FD4),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top Picks For You!',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          // Featured product
          const ProductCard(
            imageUrl:
                'https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f?w=200',
            name: 'Wholesale\nEggs',
            price: '215 Pesos',
            meetUp: 'Meet-up at Junction',
            seller: 'Seller: Sandrone',
          ),
          const SizedBox(height: 10),
          // Two smaller cards side by side
          Row(
            children: [
              const SmallProductCard(
                imageUrl:
                    'https://images.unsplash.com/photo-1569050467447-ce54b3bbc37d?w=200',
                name: 'Kimchi',
              ),
              const SizedBox(width: 10),
              const SmallProductCard(
                imageUrl:
                    'https://images.unsplash.com/photo-1604908176997-125f25cc6f3d?w=200',
                name: 'Ilocos\nEmpanada',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Posted Items Section ─────────────────────────────────────────────────────

class _PostedItemsSection extends StatelessWidget {
  const _PostedItemsSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 120),
      decoration: BoxDecoration(
        color: const Color(0xFF6BBF6B),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(14),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Posted Items',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 60),
          // Placeholder — populate with your items list
        ],
      ),
    );
  }
}

class _LeaderboardSection extends StatelessWidget {
  const _LeaderboardSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE05A00), Color(0xFFFF7A00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "This Week's Leaderboard",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const LeaderboardBar(
                imageUrl: 'https://i.pravatar.cc/150?img=47',
                height: 80,
                barColor: const Color(0xFFB0B0B0),
                rank: 2,
              ),
              const SizedBox(width: 12),
              const LeaderboardBar(
                imageUrl: 'https://i.pravatar.cc/150?img=12',
                height: 110,
                barColor: const Color(0xFFE8C84A),
                rank: 1,
                isCenter: true,
              ),
              const SizedBox(width: 12),
              const LeaderboardBar(
                imageUrl: 'https://i.pravatar.cc/150?img=32',
                height: 65,
                barColor: const Color(0xFF6BC76B),
                rank: 3,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
