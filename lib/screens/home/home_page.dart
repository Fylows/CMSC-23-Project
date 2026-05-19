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
import 'package:elbi_eats/models/posting_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final leaderboard = context.watch<LeaderboardProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            LeaderboardSection(leaderboard: leaderboard),
            const SizedBox(height: 14),
            const _TopPicksSection(),
            const SizedBox(height: 14),
            const _UserPostedItemsSection(),
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
              final secondary = items.length > 1
                  ? items.sublist(1, items.length > 3 ? 3 : items.length)
                  : [];

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
                        imageUrl:
                            featured.photoUrl ??
                            'https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f?w=200',
                        name: featured.itemName,
                        price:
                            'Exp: ${DateFormat('MM/dd').format(featured.expirationDate)}',
                        meetUp: featured.posterName,
                        seller: featured.posterVerified
                            ? '✓ Verified'
                            : 'Not verified',
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
                                imageUrl:
                                    item.photoUrl ??
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

class _UserPostedItemsSection extends StatelessWidget {
  const _UserPostedItemsSection();

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final postingProvider = context.watch<PostingProvider>();
    final userId = authProvider.user?.uid;

    if (userId == null) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<List<PostedItem>>(
      stream: postingProvider.getUserPostingsStream(userId),
      builder: (context, snapshot) {
        final items = snapshot.data ?? [];

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Your Posted Items',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  IconButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/posted-items'),
                    icon: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (items.isEmpty)
                const Text(
                  'You have no posted items yet.',
                  style: TextStyle(color: Colors.white70),
                )
              else
                SizedBox(
                  height: 200,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return GestureDetector(
                        onTap: () =>
                            Navigator.pushNamed(context, '/posted-items'),
                        child: Container(
                          width: 140,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(16),
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF9B7FD4),
                                      image: item.photoUrl != null
                                          ? DecorationImage(
                                              image: NetworkImage(
                                                item.photoUrl!,
                                              ),
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                                    ),
                                    child: item.photoUrl == null
                                        ? const Icon(
                                            Icons.fastfood,
                                            color: Colors.white30,
                                            size: 36,
                                          )
                                        : null,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.itemName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize: 14,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      'Stock ${item.stock}',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
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
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    LeaderboardBar(
                      imageUrl:
                          leaderboard.state.topThree[1].imageUrl ?? tempPfp,
                      username: leaderboard.state.topThree[1].username,
                      height: 80,
                      rank: 2,
                    ),
                    const SizedBox(width: 12),
                    LeaderboardBar(
                      imageUrl:
                          leaderboard.state.topThree[0].imageUrl ?? tempPfp,
                      username: leaderboard.state.topThree[0].username,
                      height: 110,
                      rank: 1,
                      isCenter: true,
                    ),
                    const SizedBox(width: 12),
                    LeaderboardBar(
                      imageUrl:
                          leaderboard.state.topThree[2].imageUrl ?? tempPfp,
                      username: leaderboard.state.topThree[2].username,
                      height: 65,
                      rank: 3,
                    ),
                  ],
                )
              : const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
