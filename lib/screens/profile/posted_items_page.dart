import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/item_model.dart';

class PostedItemsPage extends StatelessWidget {
  const PostedItemsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data
    final List<PostedItem> items = [
      PostedItem(id: '1', name: 'Hotdog', expirationDate: DateTime(2026, 4, 30)),
      PostedItem(id: '2', name: 'Rice', expirationDate: DateTime(2026, 5, 3)),
      PostedItem(id: '3', name: 'Fish', expirationDate: DateTime(2026, 5, 26)),
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
          'Your Posted Items',
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
        itemCount: items.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = items[index];
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
              item.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            subtitle: Text(
              'Expires: ${DateFormat('MM/dd/yyyy').format(item.expirationDate)}',
              style: const TextStyle(color: Colors.grey),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Item details
            },
          );
        },
      ),
    );
  }
}
