import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/posting_model.dart';
import '../../providers/auth/auth_provider.dart';
import '../../providers/posting/posting_provider.dart';
import '../../providers/message/message_provider.dart';
import '../messaging/chat_page.dart';

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
                    onTap: () => Navigator.pop(context),
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
                                Icon(
                                  Icons.check_circle,
                                  size: 14,
                                  color: Color(0xFFFA5800),
                                ),
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
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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
                      const Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Color(0xFFFA5800),
                      ),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
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
                    child: Text(
                      item.status.replaceFirst(
                        item.status[0],
                        item.status[0].toUpperCase(),
                      ),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
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
          : Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: Row(
                children: [
                  // Fixed width chat button
                  IconButton(
                    icon: const Icon(Icons.chat_bubble_outline),
                    onPressed: () async {
                      final chatId = await context
                          .read<MessageProvider>()
                          .getOrCreateChat(item.posterId, item.posterName);
                      if (chatId != null && context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatPage(
                              chatId: chatId,
                              currentUserId: authProvider.user!.uid,
                              otherUserName: item.posterName,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  // Claim button takes remaining space
                  Expanded(child: _buildClaimButton(context, postingProvider)),
                ],
              ),
            ),
    );
  }

  Widget _buildClaimButton(
    BuildContext context,
    PostingProvider postingProvider,
  ) {
    final authProvider = context.read<AuthProvider>();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: item.status == 'available'
            ? () async {
                if (authProvider.user == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('You must be logged in to claim items'),
                    ),
                  );
                  return;
                }

                // check if user already has a pending/accepted claim
                final hasExistingClaim = await postingProvider
                    .userHasExistingClaim(item.id, authProvider.user!.uid);

                if (hasExistingClaim) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'You already claimed this item. Waiting for owner response.',
                        ),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                  return;
                }

                try {
                  await postingProvider.createClaim(
                    item.id,
                    authProvider.user!.uid,
                    authProvider.user!.displayName ?? 'Anonymous',
                  );

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Item claimed! Waiting for owner approval.',
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error claiming item: $e')),
                    );
                  }
                }
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFA5800),
          disabledBackgroundColor: Colors.grey.shade400,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(8),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shopping_cart, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              item.status == 'available'
                  ? 'Claim Item'
                  : item.status == 'reserved'
                  ? 'Already Claimed,'
                  : 'Completed',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemoveButton(
    BuildContext context,
    PostingProvider postingProvider,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // show pending claims if item is still available
          if (item.status == 'available')
            StreamBuilder<List<Claim>>(
              stream: postingProvider.getClaimsForPostingStream(item.id),
              builder: (context, claimsSnapshot) {
                if (!claimsSnapshot.hasData || claimsSnapshot.data!.isEmpty) {
                  return const SizedBox.shrink();
                }

                final pendingClaims = claimsSnapshot.data!
                    .where((c) => c.status == 'pending')
                    .toList();

                if (pendingClaims.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Claims (${pendingClaims.length})',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: pendingClaims.length,
                      itemBuilder: (context, index) {
                        final claim = pendingClaims[index];
                        return _buildClaimCard(context, postingProvider, claim);
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),

          // remove button
          ElevatedButton(
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
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        'Remove',
                        style: TextStyle(color: Colors.red),
                      ),
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
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// build individual claim cards with accept/reject buttons
Widget _buildClaimCard(
  BuildContext context,
  PostingProvider postingProvider,
  Claim claim,
) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey.shade300),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          claim.claimerName,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'claimed on ${DateFormat('MMM dd, yyyy').format(claim.claimedAt)}',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () async {
                  try {
                    await postingProvider.acceptClaim(
                      claim.id,
                      claim.postingId,
                      claim.claimerId,
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Claim accepted!')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('Error: $e')));
                    }
                  }
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFFA5800)),
                ),
                child: const Text(
                  'Accept',
                  style: TextStyle(color: Color(0xFFFA5800)),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                // todo: implement reject functionality
                // completed 01:10 18/05/2026
                onPressed: () async {
                  try {
                    await postingProvider.rejectClaim(claim.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Claim rejected')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('Error: $e')));
                    }
                  }
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.red),
                ),
                child: Text('Reject', style: TextStyle(color: Colors.red)),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
