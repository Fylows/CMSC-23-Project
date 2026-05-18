import 'package:flutter/material.dart';
import '../../models/item_model.dart';
import 'transaction_detail_page.dart';

class OrderTransactionsPage extends StatelessWidget {
  const OrderTransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data
    final List<OrderTransaction> transactions = [
      OrderTransaction(id: '1', name: 'Pork', quantity: '2kgs', status: 'Pending'),
      OrderTransaction(id: '2', name: 'Beef', quantity: '5kgs', status: 'To Claim'),
      OrderTransaction(id: '3', name: 'Cabbage', quantity: '1kg', status: 'Completed'),
      OrderTransaction(id: '4', name: 'BBQ Sticks', quantity: '20pcs', status: 'Cancelled'),
      OrderTransaction(id: '5', name: 'Coke', quantity: '1.5L', status: 'Completed'),
    ];

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
      body: ListView.separated(
        itemCount: transactions.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final t = transactions[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFA35D5D),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            title: Text(
              t.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.quantity, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getStatusColor(t.status),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    t.status,
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Redirect to item details (not implemented)
            },
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending': return Colors.orange;
      case 'To Claim': return Colors.pink;
      case 'Completed': return Colors.green;
      case 'Cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }
}
