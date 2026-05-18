import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth/auth_provider.dart';
import '../../providers/posting/posting_provider.dart';
import '../../models/posting_model.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool isDeleteMode = false;
  Set<String> selectedClaimIds = {};

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final postingProvider = context.watch<PostingProvider>();
    final userId = authProvider.user?.uid;

    if (userId == null) {
      return const Scaffold(body: Center(child: Text('Please log in to view your cart')));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          'Your Cart',
          style: TextStyle(
            color: Color(0xFFCB2020),
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(isDeleteMode ? Icons.check_circle_outline : Icons.delete_outline, color: Colors.black),
            onPressed: () {
              setState(() {
                isDeleteMode = !isDeleteMode;
                selectedClaimIds.clear();
              });
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Claim>>(
        stream: postingProvider.getUserClaimsStream(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Your cart is empty'));
          }

          final claims = snapshot.data!;
          
          return FutureBuilder<Map<String, List<CartItemData>>>(
            future: _getCartItemsGroupedBySeller(claims, postingProvider),
            builder: (context, itemsSnapshot) {
              if (!itemsSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final groupedItems = itemsSnapshot.data!;
              double totalPrice = 0;
              for (var items in groupedItems.values) {
                for (var item in items) {
                  if (selectedClaimIds.contains(item.claim.id)) {
                    totalPrice += item.posting.price;
                  }
                }
              }

              return Stack(
                children: [
                  ListView.builder(
                    padding: const EdgeInsets.only(bottom: 100, left: 16, right: 16, top: 16),
                    itemCount: groupedItems.keys.length,
                    itemBuilder: (context, index) {
                      final sellerName = groupedItems.keys.elementAt(index);
                      final items = groupedItems[sellerName]!;
                      return _buildSellerGroup(sellerName, items);
                    },
                  ),
                  Positioned(
                    bottom: 20,
                    left: 16,
                    right: 16,
                    child: _buildBottomFloatingWidget(totalPrice, claims.length),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Future<Map<String, List<CartItemData>>> _getCartItemsGroupedBySeller(List<Claim> claims, PostingProvider provider) async {
    Map<String, List<CartItemData>> grouped = {};
    for (var claim in claims) {
      final posting = await provider.postingService.getPosting(claim.postingId);
      if (posting != null) {
        final sellerName = posting.posterName;
        if (!grouped.containsKey(sellerName)) {
          grouped[sellerName] = [];
        }
        
        // Determine status
        String status = claim.status; // default: confirmed, pending, rejected, etc.
        if (status == 'pending') {
          final claimCount = await provider.postingService.getClaimCount(posting.id);
          if (claimCount > 1) {
            status = 'has bids';
          }
        } else if (status == 'accepted') {
          status = 'confirmed';
        }

        grouped[sellerName]!.add(CartItemData(claim: claim, posting: posting, displayStatus: status));
      }
    }
    return grouped;
  }

  Widget _buildSellerGroup(String sellerName, List<CartItemData> items) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              sellerName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          ...items.map((item) => _buildCartItem(item)).toList(),
        ],
      ),
    );
  }

  Widget _buildCartItem(CartItemData item) {
    bool isSelected = selectedClaimIds.contains(item.claim.id);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          // Image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFA35D5D),
              borderRadius: BorderRadius.circular(12),
              image: item.posting.photoUrl != null
                  ? DecorationImage(image: NetworkImage(item.posting.photoUrl!), fit: BoxFit.cover)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.posting.itemName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                _buildStatusBadge(item.displayStatus),
                const SizedBox(height: 4),
                Text(
                  '₱ ${item.posting.price.toInt()}',
                  style: const TextStyle(color: Color(0xFFCB2020), fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          // Quantity & Checkbox
          Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(width: 4),
                    const Icon(Icons.remove, size: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text('${item.posting.stock}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    const Icon(Icons.add, size: 16),
                    const SizedBox(width: 4),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Checkbox(
                value: isSelected,
                onChanged: (val) {
                  setState(() {
                    if (val == true) {
                      selectedClaimIds.add(item.claim.id);
                    } else {
                      selectedClaimIds.remove(item.claim.id);
                    }
                  });
                },
                activeColor: Colors.black,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String text = status.toUpperCase();
    if (status == 'confirmed') {
      color = Colors.greenAccent[400]!;
    } else if (status == 'has bids') {
      color = Colors.red;
    } else {
      color = Colors.orange;
      text = 'PENDING';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildBottomFloatingWidget(double total, int totalItems) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFE0B2), Color(0xFFFFF3E0)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -2)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Checkbox(
              value: selectedClaimIds.length == totalItems && totalItems > 0,
              onChanged: (val) {
                // Not fully implemented for all yet, but you get the idea
              },
            ),
            const Text('All'),
            const Spacer(),
            Text(
              '₱ ${total.toInt()}',
              style: const TextStyle(color: Color(0xFFCB2020), fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: () {
                if (isDeleteMode) {
                  // TODO: Delete selected items logic
                } else {
                  // TODO: Request item logic
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB71C1C),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Text(
                isDeleteMode ? 'Delete Item' : 'Request Item',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CartItemData {
  final Claim claim;
  final PostedItem posting;
  final String displayStatus;

  CartItemData({required this.claim, required this.posting, required this.displayStatus});
}
