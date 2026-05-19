import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth/auth_provider.dart';
import '../../providers/posting/posting_provider.dart';
import '../../models/posting_model.dart';
import '../../widgets/custom_drawer.dart';
import '../pantry/item_detail_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool isDeleteMode = false;
  Set<String> selectedClaimIds = {};
  Map<String, int> selectedQuantities = {};
  
  // Cache for fetched cart items to avoid re-fetching on every build
  Map<String, List<CartItemData>>? _cachedGroupedItems;
  List<Claim>? _lastClaims;

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final postingProvider = context.watch<PostingProvider>();
    final userId = authProvider.user?.uid;

    if (userId == null) {
      return const Center(child: Text('Please log in to view your cart'));
    }

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Custom AppBar for Cart
          SafeArea(
            bottom: false,
            child: Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.menu, color: Colors.black),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Your Cart',
                        style: TextStyle(
                          color: Color(0xFFCB2020),
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      isDeleteMode ? Icons.check_circle_outline : Icons.delete_outline,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      setState(() {
                        isDeleteMode = !isDeleteMode;
                        selectedClaimIds.clear();
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Claim>>(
              stream: postingProvider.getUserClaimsStream(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting && _cachedGroupedItems == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  _cachedGroupedItems = null;
                  _lastClaims = null;
                  return const Center(child: Text('Your cart is empty'));
                }

                final claims = snapshot.data!;
                
                return FutureBuilder<Map<String, List<CartItemData>>>(
                  future: _getCartItemsGroupedBySeller(claims, postingProvider),
                  builder: (context, itemsSnapshot) {
                    if (itemsSnapshot.connectionState == ConnectionState.waiting && _cachedGroupedItems == null) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (itemsSnapshot.hasData) {
                      _cachedGroupedItems = itemsSnapshot.data;
                    }
                    return _buildCartContent(_cachedGroupedItems ?? {});
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  bool _areClaimsSame(List<Claim> list1, List<Claim> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i].id != list2[i].id || list1[i].status != list2[i].status) return false;
    }
    return true;
  }

  Widget _buildCartContent(Map<String, List<CartItemData>> groupedItems) {
    double totalPrice = 0;
    int totalSelected = 0;
    int totalItems = 0;
    List<String> allIds = [];

    for (var items in groupedItems.values) {
      for (var item in items) {
        totalItems++;
        allIds.add(item.claim.id);
        if (selectedClaimIds.contains(item.claim.id)) {
          final qty = selectedQuantities[item.claim.id] ?? 1;
          totalPrice += item.posting.price * qty;
          totalSelected++;
        }
      }
    }

    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.only(
            bottom: 100,
            left: 16,
            right: 16,
            top: 16,
          ),
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
          child: _buildBottomFloatingWidget(
            totalPrice,
            totalItems,
            totalSelected == totalItems && totalItems > 0,
            allIds,
            groupedItems,
          ),
        ),
      ],
    );
  }

  Future<Map<String, List<CartItemData>>> _getCartItemsGroupedBySeller(
    List<Claim> claims,
    PostingProvider provider,
  ) async {
    Map<String, List<CartItemData>> grouped = {};
    for (var claim in claims) {
      final posting = await provider.postingService.getPosting(claim.postingId);
      if (posting != null) {
        final sellerName = posting.posterName;
        if (!grouped.containsKey(sellerName)) {
          grouped[sellerName] = [];
        }

        // Determine status
        String status =
            claim.status; // default: confirmed, pending, rejected, etc.
        if (status == 'pending') {
          final claimCount = await provider.postingService.getClaimCount(
            posting.id,
          );
          if (claimCount > 1) {
            status = 'has bids';
          }
        } else if (status == 'accepted') {
          status = 'confirmed';
        }

        grouped[sellerName]!.add(
          CartItemData(claim: claim, posting: posting, displayStatus: status),
        );
      }
    }
    return grouped;
  }

  Widget _buildSellerGroup(String sellerName, List<CartItemData> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            sellerName,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: items.map((item) => _buildCartItem(item)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildCartItem(CartItemData item) {
    bool isSelected = selectedClaimIds.contains(item.claim.id);
    int qty = selectedQuantities[item.claim.id] ?? 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Image
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ItemDetailPage(item: item.posting),
                ),
              );
            },
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFA35D5D),
                borderRadius: BorderRadius.circular(12),
                image: item.posting.photoUrl != null
                    ? DecorationImage(
                        image: NetworkImage(item.posting.photoUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: item.posting.photoUrl == null
                  ? const Icon(Icons.fastfood, color: Colors.white24)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          // Info Column
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ItemDetailPage(item: item.posting),
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.posting.itemName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  _buildStatusBadge(item.displayStatus),
                  const SizedBox(height: 8),
                  Text(
                    '₱ ${item.posting.price.toInt()}',
                    style: const TextStyle(
                      color: Color(0xFFCB2020),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          // Quantity Selector and Checkbox in a row to be "parallel"
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, size: 16),
                      onPressed: qty > 1
                          ? () {
                              setState(() {
                                selectedQuantities[item.claim.id] = qty - 1;
                              });
                            }
                          : null,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        '$qty',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, size: 16),
                      onPressed: qty < item.posting.stock
                          ? () {
                              setState(() {
                                selectedQuantities[item.claim.id] = qty + 1;
                              });
                            }
                          : null,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildBottomFloatingWidget(
    double total,
    int totalItems,
    bool allSelected,
    List<String> allIds,
    Map<String, List<CartItemData>> groupedItems,
  ) {
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
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Checkbox(
              value: allSelected,
              onChanged: (val) {
                setState(() {
                  if (val == true) {
                    selectedClaimIds = allIds.toSet();
                  } else {
                    selectedClaimIds.clear();
                  }
                });
              },
              activeColor: Colors.black,
            ),
            const Text(
              'All',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const Spacer(),
            Text(
              '₱ ${total.toInt()}',
              style: const TextStyle(
                color: Color(0xFFCB2020),
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: selectedClaimIds.isEmpty
                  ? null
                  : () async {
                      if (isDeleteMode) {
                        final postingProvider = context.read<PostingProvider>();
                        for (final claimId in selectedClaimIds) {
                          await postingProvider.deleteClaim(claimId);
                        }
                        setState(() {
                          selectedClaimIds.clear();
                        });
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Selected items deleted from cart.'),
                            ),
                          );
                        }
                      } else {
                        await _notifySellersForSelections(groupedItems);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB71C1C),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: Text(
                isDeleteMode ? 'Delete Item' : 'Request Item',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _notifySellersForSelections(
    Map<String, List<CartItemData>> groupedItems,
  ) async {
    final authProvider = context.read<AuthProvider>();
    final buyerName =
        authProvider.user?.displayName ??
        authProvider.user?.email?.split('@')[0] ??
        'Buyer';
    final buyerId = authProvider.user?.uid;
    final batch = FirebaseFirestore.instance.batch();
    final now = FieldValue.serverTimestamp();

    for (final group in groupedItems.values) {
      for (final item in group) {
        if (!selectedClaimIds.contains(item.claim.id)) continue;

        final notificationRef = FirebaseFirestore.instance
            .collection('notifications')
            .doc();
        batch.set(notificationRef, {
          'recipientId': item.posting.posterId,
          'senderId': buyerId,
          'senderName': buyerName,
          'postingId': item.posting.id,
          'claimId': item.claim.id,
          'itemName': item.posting.itemName,
          'message': '$buyerName requested ${item.posting.itemName}.',
          'status': 'unread',
          'createdAt': now,
        });
      }
    }

    try {
      await batch.commit();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request sent to seller notifications.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to send request: $e')));
      }
    }
  }
}

class CartItemData {
  final Claim claim;
  final PostedItem posting;
  final String displayStatus;

  CartItemData({
    required this.claim,
    required this.posting,
    required this.displayStatus,
  });
}
