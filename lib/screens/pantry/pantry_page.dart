import 'package:elbi_eats/screens/pantry/item_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth/auth_provider.dart';
import '../../providers/posting/posting_provider.dart';
import '../../models/posting_model.dart';

class PantryPage extends StatefulWidget {
  final String? initialSearch;

  const PantryPage({this.initialSearch, super.key});

  @override
  State<PantryPage> createState() => _PantryPageState();
}

class _PantryPageState extends State<PantryPage> {
  late final searchController;
  String selectedFilter = 'available'; // available, expired, claimed, bids, completed, reserved
  bool showOnlyMyItems = false;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController(text: widget.initialSearch ?? '');
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final postingProvider = context.watch<PostingProvider>();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Browse Pantry',
          style: TextStyle(
            color: Color(0xFFCB2020),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1), 
          child: Container(color: Colors.grey[300], height: 1),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ====== SEARCH & FILETER =========
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // filter tabs
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('available', 'All'),
                        const SizedBox(width: 8),
                        _buildFilterChip('reserved', 'Reserved'),
                        const SizedBox(width: 8),
                        _buildFilterChip('expired', 'Expired'),
                        const SizedBox(width: 8),
                        _buildFilterChip('claimed', 'Claim'),
                        const SizedBox(width: 8),
                        _buildFilterChip('bids', 'Bids'),
                        const SizedBox(width: 8),
                        _buildFilterChip('completed', 'Confirmed'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // only show my items checkbox
                  Row(
                    children: [
                      Checkbox(
                        value: showOnlyMyItems, 
                        onChanged: (value) {
                          setState(() {
                            showOnlyMyItems = value ?? false;
                          });
                        },
                      ),
                      const Text(
                        'Only show my items',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ======== FEED =============
            Expanded(
              child: StreamBuilder<List<PostedItem>>(
                stream: postingProvider.getAllPostingsStream(), 
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox, size: 64, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          Text(
                            'No items available',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  List<PostedItem> items = snapshot.data!;

                  // apply filter based on selected tab
                  if (selectedFilter == 'reserved') {
                    items = items.where((item) => item.status == 'reserved').toList();
                  } else if (selectedFilter == 'expired') {
                    items = items
                      .where((item) => item.expirationDate.isBefore(DateTime.now()))
                      .toList();
                  } else if (selectedFilter == 'claimed') {
                    // show items user has claimed (pending or accepted)
                    items = items.where((item) => item.claimedBy == authProvider.user?.uid).toList();
                  } else if (selectedFilter == 'bids') {
                    // show items with multiple pending claims
                    // note: filter will be done in itembuilder via stream
                    items = items.where((item) => item.status == 'available').toList();
                  }  else if (selectedFilter == 'completed') {
                    items = items.where((item) => item.status == 'completed').toList();
                  } else {
                    // 'available' - default
                    items = items.where((item) => item.status == 'available').toList();
                  }

                  // filter by user's items if checked
                  if (showOnlyMyItems && authProvider.user != null) {
                    items = items
                      .where((item) => item.posterId == authProvider.user!.uid)
                      .toList();
                  }

                  // filter by search query
                  if (searchController.text.isNotEmpty) {
                    final query = searchController.text.toLowerCase();
                    items = items
                      .where((item) =>
                        item.itemName.toLowerCase().contains(query) ||
                        item.description.toLowerCase().contains(query))
                      .toList();
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.75
                    ),
                    itemCount: items.length, 
                    itemBuilder: (context, index) {
                      final item = items[index];

                      // special handling for "bids" filter
                      if (selectedFilter == 'bids') {
                        return StreamBuilder<List<Claim>>(
                          stream: postingProvider.getClaimsForPostingStream(item.id), 
                          builder: (context, claimsSnapshot) {
                            // only show items with 2+ pending claims
                            if (!claimsSnapshot.hasData || claimsSnapshot.data!.where((c) => c.status == 'pending').length < 2) {
                              return const SizedBox.shrink();
                            }
                            return ItemCard(
                              item: item, 
                              onTap: () {
                                Navigator.push(
                                  context, 
                                  MaterialPageRoute(
                                    builder: (context) => ItemDetailPage(item: item),
                                  ),
                                );
                              }
                            );
                          }
                        );
                      }
                      return ItemCard(
                        item: item,
                        onTap: () {
                          Navigator.push(
                            context, 
                            MaterialPageRoute(
                              builder: (context) => ItemDetailPage(item: item),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          final isVerified = authProvider.user?.isVerified ?? false;

          return FloatingActionButton(
            onPressed: isVerified
              ? () => Navigator.pushNamed(context, '/post-item')
              : () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Complete verification to post items'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            backgroundColor: isVerified ? const Color(0xFFFA5800) : Colors.grey,
            child: const Icon(Icons.add),
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          selectedFilter = value;
        });
      },
      backgroundColor: Colors.white,
      selectedColor: const Color(0xFFFA5800),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
        fontWeight: FontWeight.w500,
      ),
      side: BorderSide(
        color: isSelected ? const Color(0xFFFA5800) : Colors.grey.shade300,
      ),
    );
  }
}

// ======== ITEM CARD COMPONENT ======
class ItemCard extends StatelessWidget {
  final PostedItem item;
  final VoidCallback onTap;

  const ItemCard({
    required this.item,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // photo
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: item.photoUrl != null
                ? Image.network(
                    item.photoUrl!,
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 140,
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.broken_image),
                      );
                    },
                )
              : Container(
                  height: 140,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.image),
                ),
            ),

            // info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // item name
                    Text(
                      item.itemName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // tags 
                    Wrap(
                      spacing: 4,
                      children: item.selectedTags.take(2).map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFA5800),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            tag,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const Spacer(),

                    // expiration date
                    Text(
                      'Exp: ${DateFormat('MM/dd').format(item.expirationDate)}',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    // poster
                    Text(
                      item.posterName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11),
                    )
                  ],
                ),
              )
            )
          ],
        ),
      ),
    );
  }
}