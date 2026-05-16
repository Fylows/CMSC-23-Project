import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:elbi_eats/providers/auth/auth_provider.dart';
import 'package:elbi_eats/widgets/custom_drawer.dart';
import 'package:intl/intl.dart';
import '../../models/item_model.dart';
import 'order_transactions_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isEditing = false;
  bool isAscending = true;
  
  // Dummy data for demonstration
  final List<PostedItem> postedItems = [
    PostedItem(id: '1', name: 'Hotdog', expirationDate: DateTime(2026, 4, 30)),
    PostedItem(id: '2', name: 'Rice', expirationDate: DateTime(2026, 5, 3)),
    PostedItem(id: '3', name: 'Fish', expirationDate: DateTime(2026, 5, 26)),
  ];

  final List<OrderTransaction> transactions = [
    OrderTransaction(id: '1', name: 'Pork', quantity: '2kgs', status: 'Pending'),
    OrderTransaction(id: '2', name: 'Beef', quantity: '5kgs', status: 'To Claim'),
    OrderTransaction(id: '3', name: 'Cabbage', quantity: '1kg', status: 'Completed'),
  ];

  void _showFilterPopup(BuildContext context, Offset offset) {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) {
        return Stack(
          children: [
            Positioned(
              top: offset.dy,
              right: 20,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 250,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildFilterOption('Date of Expiration', true),
                      _buildFilterOption('Date of Uploaded Items', false),
                      _buildFilterOption('Number of Stocks', false),
                      _buildFilterOption('Alphabetical Order', false),
                      const Divider(),
                      Row(
                        children: [
                          RadioGroup<bool>(
                            groupValue: isAscending,
                            onChanged: (bool? val) {
                              setState(() {
                                isAscending = val ?? true;
                              });
                            },
                            child: Row( 
                              children: [
                                // First Radio Button (Ascending)
                                Radio<bool>(
                                  value: true,
                                  activeColor: const Color(0xFFCB2020),
                                  // groupValue and onChanged are removed!
                                ),
                                const Text(
                                  'Ascending', 
                                  style: TextStyle(fontSize: 12, color: Color(0xFFCB2020)),
                                ),
                                
                                // Second Radio Button (Descending)
                                Radio<bool>(
                                  value: false,
                                  activeColor: const Color(0xFFCB2020),
                                  // groupValue and onChanged are removed!
                                ),
                                const Text(
                                  'Descending', 
                                  style: TextStyle(fontSize: 12, color: Color(0xFFCB2020)),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterOption(String title, bool value) {
    return Row(
      children: [
        SizedBox(
          height: 30,
          width: 30,
          child: Checkbox(
            value: value,
            onChanged: (val) {},
            activeColor: const Color(0xFFCB2020),
          ),
        ),
        Text(title, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      drawer: const CustomDrawer(),
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
          'Profile',
          style: TextStyle(
            color: Color(0xFFCB2020),
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey[300], height: 1),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // --- Profile Header ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 55,
                        backgroundColor: Colors.grey[300],
                        child: const Icon(Icons.person, size: 70, color: Colors.white),
                      ),
                      if (isEditing)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFA5800),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.add, color: Colors.white, size: 20),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              user?.displayName ?? 'Real Name',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFCB2020),
                              ),
                            ),
                            if (isEditing)
                              const Padding(
                                padding: EdgeInsets.only(left: 8.0),
                                child: Icon(Icons.edit_outlined, color: Color(0xFFCB2020), size: 20),
                              ),
                          ],
                        ),
                        Text(
                          '@${user?.username ?? user?.email?.split('@')[0] ?? 'username'}',
                          style: TextStyle(
                            fontSize: 16,
                            color: const Color(0xFFCB2020).withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.emoji_events, color: Color(0xFFFA5800), size: 40),
                            const SizedBox(width: 12),
                            Container(width: 1.5, height: 30, color: Colors.grey[400]),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${user?.contributorScore ?? 67}',
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFFA5800),
                                  ),
                                ),
                                const Text(
                                  'Contributor',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFFFA5800),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // --- Your Posted Items Section ---
            _buildSection(
              title: 'Your Posted Items',
              items: postedItems.map((item) => _buildPostedItemCard(item)).toList(),
              onFilterTap: (offset) => _showFilterPopup(context, offset),
              showAddIcon: isEditing,
              onTitleTap: () => Navigator.pushNamed(context, '/posted-items'),
            ),
            const SizedBox(height: 20),

            // --- Your Order Transactions Section ---
            _buildSection(
              title: 'Your Order Transactions',
              items: transactions.map((t) => _buildTransactionCard(t)).toList(),
              onFilterTap: (offset) => _showFilterPopup(context, offset),
              showVisibilityIcon: isEditing,
              onTitleTap: () => Navigator.pushNamed(context, '/order-transactions'),
            ),
            const SizedBox(height: 40),

            // --- Buttons ---
            if (!isEditing)
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () => setState(() => isEditing = true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(220, 55),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      elevation: 0,
                    ),
                    child: const Text('Edit Profile', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(bottom: 30, left: 20, right: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () => setState(() => isEditing = false),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.greenAccent[700],
                          foregroundColor: Colors.white,
                          minimumSize: const Size(160, 50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          elevation: 0,
                        ),
                        child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () => setState(() => isEditing = false),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(160, 50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          elevation: 0,
                        ),
                        child: const Text('Discard Changes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: const Color(0xFFCB2020),
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(icon: const Icon(Icons.home, color: Colors.white, size: 30), onPressed: () {}),
            IconButton(icon: const Icon(Icons.inventory_2, color: Colors.white, size: 30), onPressed: () {}),
            IconButton(icon: const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 30), onPressed: () {}),
            IconButton(icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 30), onPressed: () {}),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> items,
    required Function(Offset) onFilterTap,
    bool showAddIcon = false,
    bool showVisibilityIcon = false,
    VoidCallback? onTitleTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFA5800), // Updated to the orange from prompt
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: onTitleTap,
                    child: Text(
                      title,
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Row(
                    children: [
                      if (showAddIcon)
                        const Padding(
                          padding: EdgeInsets.only(right: 12.0),
                          child: Icon(Icons.add_circle, color: Colors.white, size: 24),
                        ),
                      if (showVisibilityIcon)
                        const Padding(
                          padding: EdgeInsets.only(right: 12.0),
                          child: Icon(Icons.visibility_off, color: Colors.white, size: 24),
                        ),
                      GestureDetector(
                        onTapDown: (details) => onFilterTap(details.globalPosition),
                        child: const Icon(Icons.swap_vert, color: Colors.white, size: 24),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 16, bottom: 16),
              child: Row(children: items),
            ),
            // Progress indicator at the bottom (optional, but looks like it might be in figma)
            Container(
              height: 4,
              width: 80,
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostedItemCard(PostedItem item) {
    return Container(
      width: 110,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              item.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            height: 70,
            width: 90,
            decoration: BoxDecoration(
              color: const Color(0xFFA35D5D),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              DateFormat('MM/dd/yyyy').format(item.expirationDate),
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
            ),
          ),
          if (isEditing)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Remove',
                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(OrderTransaction transaction) {
    return Container(
      width: 110,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              transaction.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            height: 70,
            width: 90,
            decoration: BoxDecoration(
              color: const Color(0xFFA35D5D),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              transaction.quantity,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _getStatusColor(transaction.status),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              transaction.status,
              style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending': return Colors.orange;
      case 'To Claim': return Colors.pink;
      case 'Completed': return Colors.green;
      default: return Colors.grey;
    }
  }
}
