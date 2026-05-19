import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth/auth_provider.dart';
import '../../providers/posting/posting_provider.dart';
import '../../models/item_model.dart' as item_model;
import '../../models/posting_model.dart';
import 'transaction_detail_page.dart';

class OrderTransactionsPage extends StatelessWidget {
  const OrderTransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final postingProvider = context.watch<PostingProvider>();
    final userId = authProvider.user?.uid;

    if (userId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Order Transactions',
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
      body: StreamBuilder<List<Claim>>(
        stream: postingProvider.getUserClaimsStream(userId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final claims = snapshot.data!;
          if (claims.isEmpty) {
            return const Center(
              child: Text(
                'No order transactions yet.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.separated(
            itemCount: claims.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final claim = claims[index];
              return FutureBuilder<PostedItem?>(
                future: postingProvider.postingService.getPosting(
                  claim.postingId,
                ),
                builder: (context, postSnapshot) {
                  final posting = postSnapshot.data;
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    leading: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFFA35D5D),
                        borderRadius: BorderRadius.circular(8),
                        image: posting?.photoUrl != null
                            ? DecorationImage(
                                image: NetworkImage(posting!.photoUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: posting?.photoUrl == null
                          ? const Icon(Icons.receipt, color: Colors.white24)
                          : null,
                    ),
                    title: Text(
                      posting?.itemName ?? 'Unknown item',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          'Seller: ${posting?.posterName ?? 'Unknown'}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Price: ₱ ${posting?.price.toStringAsFixed(2) ?? '0.00'}',
                          style: const TextStyle(
                            color: Color(0xFFCB2020),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(claim.status),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            claim.status[0].toUpperCase() +
                                claim.status.substring(1),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      final orderTransaction = item_model.OrderTransaction(
                        id: claim.id,
                        name: posting?.itemName ?? 'Unknown item',
                        imageUrl: posting?.photoUrl,
                        sellerName: posting?.posterName ?? 'Unknown',
                        quantity: '1',
                        price: posting?.price ?? 0.0,
                        status:
                            claim.status[0].toUpperCase() +
                            claim.status.substring(1),
                        requestedAt: claim.claimedAt,
                        respondedAt: (claim.status == 'accepted' ||
                                claim.status == 'rejected' ||
                                claim.status == 'completed')
                            ? claim.resolvedAt
                            : null,
                        completedAt: (claim.status == 'completed')
                            ? claim.resolvedAt
                            : null,
                      );

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TransactionDetailPage(
                            transaction: orderTransaction,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'to claim':
      case 'accepted':
        return Colors.pink;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
