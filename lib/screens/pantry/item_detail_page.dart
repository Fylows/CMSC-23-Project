import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/posting_model.dart';
import '../../providers/auth/auth_provider.dart';
import '../../providers/posting/posting_provider.dart';

class ItemDetailPage extends StatelessWidget {
  final PostedItem item;

  const ItemDetailPage({required this.item, super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final postingProvider = context.watch<PostingProvider>();

    final isOwnItem = authProvider.user?.uid == item.posterId;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ========= PHOTO ============
            Stack(
              children: [
                item.photoUrl != null
                  ? Image.network(
                    item.photoUrl!,
                    height: 300,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 300,
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.broken_image, size: 64),
                      );
                    },
                  )
                  : Container(
                    height: 300,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.image, size: 64),
                  ),
                // back button
                Positioned(
                  top: 40,
                  left: 16,
                  child: GestureDetector(
                    onTap: () =>  Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),

            // ==== CONTENT ======
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // item name
                  Text(
                    item.itemName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // tags
                  Wrap(
                    spacing: 8,
                    children: item.selectedTags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFA5800),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          tag,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // poster info
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.grey.shade300,
                        child: const Icon(Icons.person),
                      ),
                      const SizedBox(width: 12),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.posterName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (item.posterVerified)
                            const Row(
                              children: [
                                Icon(Icons.check_circle,
                                  size: 14, color: Color(0xFFFA5800)),
                                SizedBox(width: 4),
                                Text(
                                  'Verified',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // divider
                  Divider(color: Colors.grey.shade300),
                  const SizedBox(height: 16),

                  // description
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // expiration date
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16, color: Color(0xFFFA5800)),
                      const SizedBox(width: 8),
                      Text(
                        'Expires: ${DateFormat('MMM dd, yyyy').format(item.expirationDate)}',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // status badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: item.status == 'available'
                        ? Colors.green.shade50
                        : Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: item.status == 'available'
                          ? Colors.green
                          : Colors.orange,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: isOwnItem
        ? _buildRemoveButton(context, postingProvider)
        : _buildClaimButton(context, postingProvider),
    );
  }

  Widget _buildClaimButton(BuildContext context, PostingProvider postingProvider) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: item.status == 'available'
          ? () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Claim functionality coming soon!'))
              );
            }
          : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFA5800),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(8)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shopping_cart, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              item.status == 'available' ? 'Claim Item' : 'Already Claimed,',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            )
          ],
        )
      ),
    );
  }

  Widget _buildRemoveButton(BuildContext context, PostingProvider postingProvider) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: () async {
          final confirm = await showDialog<bool>(
            context: context, 
            builder: (context) => AlertDialog(
              title: const Text('Remove Item?'),
              content: const Text(
                'Are you sure you want to remove this item from the pantry?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false), 
                  child: const Text('Cancel')
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true), 
                  child: const Text('Remove', style: TextStyle(color: Colors.red),)
                ),
              ],
            ),
          );

          if (confirm == true && context.mounted) {
            try {
              await postingProvider.deletePosting(item.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Item removed')),
                );
                Navigator.pop(context);
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: $e')),
              );
            }
          }
        }, 
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.delete, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Remove Item',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            )
          ],
        )
      ),
    );
  }
}