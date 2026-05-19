import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/item_model.dart';

class TransactionDetailPage extends StatelessWidget {
  final OrderTransaction transaction;

  const TransactionDetailPage({required this.transaction, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Header Image ---
                    Stack(
                      children: [
                        Container(
                          height: 300,
                          width: double.infinity,
                          color: Colors.grey[600],
                          child: transaction.imageUrl != null
                              ? Image.network(transaction.imageUrl!, fit: BoxFit.cover)
                              : const Icon(Icons.fastfood, size: 80, color: Colors.white),
                        ),
                        Positioned(
                          top: 10,
                          left: 10,
                          child: CircleAvatar(
                            backgroundColor: Colors.white.withOpacity(0.5),
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back, color: Colors.black),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // --- Content ---
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            transaction.name,
                            style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '₱ ${transaction.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFCB2020),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              _buildTag('Organics', const Color(0xFFFFD180)),
                              const SizedBox(width: 8),
                              _buildTag('Veggies', const Color(0xFFA5D6A7)),
                              const SizedBox(width: 8),
                              _buildTag('Fastfood', const Color(0xFFE6EE9C)),
                              const SizedBox(width: 8),
                              const CircleAvatar(
                                radius: 15,
                                backgroundColor: Colors.grey,
                                child: Text('...', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                          const Divider(height: 32),
                          ListTile(
                            leading: const Icon(Icons.person_outline),
                            title: Text('Seller: ${transaction.sellerName ?? 'Unknown'}'),
                            contentPadding: EdgeInsets.zero,
                          ),
                          const Divider(height: 32),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text(
                                'Transaction',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Details',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (transaction.requestedAt != null)
                            _buildTransactionRow(
                              transaction.requestedAt!,
                              'You requested the item',
                            ),
                          if (transaction.respondedAt != null)
                            _buildTransactionRow(
                              transaction.respondedAt!,
                              transaction.status == 'Rejected'
                                  ? 'Seller rejected your order'
                                  : 'Seller accepted your order',
                            ),
                          if (transaction.completedAt != null)
                            _buildTransactionRow(
                              transaction.completedAt!,
                              'Order complete',
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // --- Bottom Navigation ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              color: const Color(0xFFCB2020),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 30),
                    onPressed: () {
                      // TODO: Go to chat
                    },
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: _getStatusColor(transaction.status),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        transaction.status,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black54),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildTransactionRow(DateTime date, String details) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            DateFormat('MM/dd/yyyy | hh:mm a').format(date),
            style: const TextStyle(fontSize: 12),
          ),
          Text(
            details,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'To Claim':
        return Colors.pink;
      case 'Completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
