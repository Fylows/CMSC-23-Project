import 'package:flutter/material.dart';
import 'package:elbi_eats/widgets/product_card.dart';
import 'package:elbi_eats/widgets/small_product_card.dart';
import 'package:elbi_eats/screens/home/leaderboard_bar.dart';
import 'package:elbi_eats/screens/pantry/item_detail_page.dart';
import 'package:provider/provider.dart';
import 'package:elbi_eats/providers/leaderboard/leaderboard_provider.dart';
import 'package:elbi_eats/providers/auth/auth_provider.dart';
import 'package:elbi_eats/providers/posting/posting_provider.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final leaderboard = context.watch<LeaderboardProvider>();
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            LeaderboardSection(leaderboard: leaderboard),
            const SizedBox(height: 14),
            _TopPicksSection(),
            const SizedBox(height: 14),
            authProvider.user != null
                ? _PostedItemsSection(userId: authProvider.user!.uid)
                : const SizedBox.shrink(),
            const SizedBox(height: 14),
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
    final postingProvider = context.watch<PostingProvider>();

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
          StreamBuilder(
            stream: postingProvider.getAvailablePostingsStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const SizedBox(
                  height: 200,
                  child: Center(
                    child: Text(
                      'No items available',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                );
              }

              final items = snapshot.data!;
              
              // Take first 3 items
              final featured = items.isNotEmpty ? items[0] : null;
              final secondary =
                  items.length > 1 ? items.sublist(1, items.length > 3 ? 3 : items.length) : [];

              return Column(
                children: [
                  // featured item
                  if (featured != null)
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ItemDetailPage(item: featured),
                        ),
                      ),
                      child: ProductCard(
                        imageUrl: featured.photoUrl ??
                            'https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f?w=200',
                        name: featured.itemName,
                        price: 'Exp: ${DateFormat('MM/dd').format(featured.expirationDate)}',
                        meetUp: featured.posterName,
                        seller: featured.posterVerified ? '✓ Verified' : 'Not verified',
                      ),
                    )
                  else
                    const Text('No featured item'),
                  
                  if (secondary.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    // two smaller cards side by side
                    Row(
                      children: secondary
                          .asMap()
                          .entries
                          .map((entry) {
                            final item = entry.value;
                            return GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ItemDetailPage(item: item),
                                ),
                              ),
                              child: SmallProductCard(
                                imageUrl: item.photoUrl ??
                                    'https://images.unsplash.com/photo-1569050467447-ce54b3bbc37d?w=200',
                                name: item.itemName,
                              ),
                            );
                          })
                          .toList()
                          .asMap()
                          .entries
                          .map((entry) {
                            final widget = entry.value;
                            return entry.key == 0
                                ? widget
                                : Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: widget,
                                  );
                          })
                          .toList(),
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─── Posted Items Section ─────────────────────────────────────────────────────

class _PostedItemsSection extends StatelessWidget {
  final String userId;

  const _PostedItemsSection({required this.userId});

  @override
  Widget build(BuildContext context) {
    final postingProvider = context.watch<PostingProvider>();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF6BBF6B),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Posted Items',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          StreamBuilder(
            stream: postingProvider.getUserPostingsStream(userId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 120,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return SizedBox(
                  height: 120,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'You haven\'t posted any items yet',
                          style: TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/post-item'),
                          child: const Text(
                            'Post an item',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final items = snapshot.data!;
              
              // Count stats
              final available = items.where((i) => i.status == 'available').length;
              final claimed = items.where((i) => i.status == 'reserved').length;
              final completed = items.where((i) => i.status == 'completed').length;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // stats row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatChip(
                        label: 'Total',
                        value: items.length.toString(),
                      ),
                      _StatChip(
                        label: 'Available',
                        value: available.toString(),
                      ),
                      _StatChip(
                        label: 'Claimed',
                        value: claimed.toString(),
                      ),
                      _StatChip(
                        label: 'Completed',
                        value: completed.toString(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Horizontal scrollable list
                  SizedBox(
                    height: 140,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return Padding(
                          padding: EdgeInsets.only(
                            right: 10,
                            left: index == 0 ? 0 : 0,
                          ),
                          child: GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ItemDetailPage(item: item),
                              ),
                            ),
                            child: Container(
                              width: 120,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.white,
                              ),
                              child: Column(
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(12),
                                        topRight: Radius.circular(12),
                                      ),
                                      child: Image.network(
                                        item.photoUrl ?? '',
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(Icons.image),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.itemName,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                        Text(
                                          item.status,
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: _getStatusColor(item.status),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'available':
        return Colors.green;
      case 'reserved':
        return Colors.orange;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;

  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
    );
  }
}

class LeaderboardSection extends StatelessWidget {
  final LeaderboardProvider leaderboard;

  const LeaderboardSection({super.key, required this.leaderboard});
  final tempPfp =
      'https://www.gravatar.com/avatar/?d=mp'; // ← grey silhouette, no face;
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
          leaderboard.state.topThree.length >= 3
              ? _buildLeaderboardDisplay(leaderboard)
              : const SizedBox(
                  height: 100,
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildLeaderboardDisplay(LeaderboardProvider leaderboard) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLeaderboardCard(
          position: '2',
          name: leaderboard.state.topThree[1].username,
          score: leaderboard.state.topThree[1].contributions,
          imageUrl: leaderboard.state.topThree[1].imageUrl ?? tempPfp,
          height: 100,
        ),
        const SizedBox(width: 12),
        _buildLeaderboardCard(
          position: '1',
          name: leaderboard.state.topThree[0].username,
          score: leaderboard.state.topThree[0].contributions,
          imageUrl: leaderboard.state.topThree[0].imageUrl ?? tempPfp,
          height: 120,
        ),
        const SizedBox(width: 12),
        _buildLeaderboardCard(
          position: '3',
          name: leaderboard.state.topThree[2].username,
          score: leaderboard.state.topThree[2].contributions,
          imageUrl: leaderboard.state.topThree[2].imageUrl ?? tempPfp,
          height: 90,
        ),
      ],
    );
  }

  Widget _buildLeaderboardCard({
    required String position,
    required String name,
    required int score,
    required String imageUrl,
    required double height,
  }) {
    return Column(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundImage: NetworkImage(imageUrl),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                position,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              Text(
                name,
                style: const TextStyle(color: Colors.white70, fontSize: 10),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '$score pts',
                style: const TextStyle(color: Colors.white70, fontSize: 9),
              ),
            ],
          ),
        ),
      ],
    );
  }
}