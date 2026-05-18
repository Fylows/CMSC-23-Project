import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:elbi_eats/providers/auth/auth_provider.dart';
import 'package:elbi_eats/widgets/custom_drawer.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
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
  bool localHideTransactions = false;
  
  late TextEditingController _nameController;
  File? _pickedImage;
  final ImagePicker _picker = ImagePicker();

  // Scroll controllers for horizontal sections to sync with progress indicator
  final ScrollController _postedItemsScrollController = ScrollController();
  final ScrollController _transactionsScrollController = ScrollController();
  
  double _postedItemsProgress = 0.0;
  double _transactionsProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    
    // Initialize state from provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;
      if (user != null) {
        setState(() {
          _nameController.text = user.displayName ?? 'Real Name';
          localHideTransactions = user.hideTransactions;
        });
      }
    });

    _postedItemsScrollController.addListener(() {
      if (_postedItemsScrollController.hasClients && _postedItemsScrollController.position.maxScrollExtent > 0) {
        setState(() {
          _postedItemsProgress = _postedItemsScrollController.offset / 
            _postedItemsScrollController.position.maxScrollExtent;
        });
      }
    });
    _transactionsScrollController.addListener(() {
      if (_transactionsScrollController.hasClients && _transactionsScrollController.position.maxScrollExtent > 0) {
        setState(() {
          _transactionsProgress = _transactionsScrollController.offset / 
            _transactionsScrollController.position.maxScrollExtent;
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _postedItemsScrollController.dispose();
    _transactionsScrollController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _pickedImage = File(image.path);
      });
    }
  }

  void _showNameEditDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter shown name...'),
          content: TextField(
            controller: _nameController,
            maxLength: 15,
            decoration: const InputDecoration(
              hintText: 'Real Name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {}); // Trigger rebuild to show new name in UI
                Navigator.pop(context);
              },
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  // Dummy data for demonstration
  final List<PostedItem> postedItems = [
    PostedItem(id: '1', name: 'Hotdog', expirationDate: DateTime(2026, 4, 30)),
    PostedItem(id: '2', name: 'Rice', expirationDate: DateTime(2026, 5, 3)),
    PostedItem(id: '3', name: 'Fish', expirationDate: DateTime(2026, 5, 26)),
    PostedItem(id: '4', name: 'Egg', expirationDate: DateTime(2026, 6, 1)),
  ];

  final List<OrderTransaction> transactions = [
    OrderTransaction(
      id: '1',
      name: 'Pork',
      quantity: '2kgs',
      status: 'Pending',
    ),
    OrderTransaction(
      id: '2',
      name: 'Beef',
      quantity: '5kgs',
      status: 'To Claim',
    ),
    OrderTransaction(
      id: '3',
      name: 'Cabbage',
      quantity: '1kg',
      status: 'Completed',
    ),
    OrderTransaction(
      id: '4',
      name: 'Coke',
      quantity: '1.5L',
      status: 'Completed',
    ),
  ];

  void _showFilterPopup(BuildContext context, Offset offset) {
    if (isEditing) return; // Filters removed when editing

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
                          Radio<bool>(
                            value: true,
                            groupValue: isAscending,
                            activeColor: const Color(0xFFCB2020),
                            onChanged: (val) {
                              setState(() => isAscending = val!);
                              Navigator.pop(context);
                            },
                          ),
                          const Text(
                            'Ascending',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFFCB2020),
                            ),
                          ),
                          Radio<bool>(
                            value: false,
                            groupValue: isAscending,
                            activeColor: const Color(0xFFCB2020),
                            onChanged: (val) {
                              setState(() => isAscending = val!);
                              Navigator.pop(context);
                            },
                          ),
                          const Text(
                            'Descending',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFFCB2020),
                            ),
                          ),
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
                  // --- Left Column: Profile Picture ---
                  Expanded(
                    child: Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 80,
                            backgroundColor: Colors.grey[300],
                            backgroundImage: _pickedImage != null
                                ? FileImage(_pickedImage!)
                                : (user?.profilePictureUrl != null
                                    ? NetworkImage(user!.profilePictureUrl!)
                                    : null) as ImageProvider?,
                            child: _pickedImage == null &&
                                    user?.profilePictureUrl == null
                                ? const Icon(
                                    Icons.person,
                                    size: 100,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                          if (isEditing)
                            Positioned(
                              bottom: 5,
                              right: 5,
                              child: GestureDetector(
                                onTap: _pickImage,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFA5800),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // --- Right Column: User Info ---
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (isEditing)
                          GestureDetector(
                            onTap: _showNameEditDialog,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      _nameController.text.isEmpty ? (user?.displayName ?? 'Real Name') : _nameController.text,
                                      style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFCB2020),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.edit_outlined,
                                  color: Color(0xFFCB2020),
                                  size: 24,
                                ),
                              ],
                            ),
                          )
                        else
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              user?.displayName ?? 'Real Name',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFCB2020),
                              ),
                            ),
                          ),
                        Text(
                          '@${user?.username ?? user?.email?.split('@')[0] ?? 'username'}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: const Color(
                              0xFFCB2020,
                            ).withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.emoji_events,
                              color: Color(0xFFFA5800),
                              size: 45,
                            ),
                            const SizedBox(width: 15),
                            Container(
                              width: 1.5,
                              height: 35,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(width: 15),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${user?.contributorScore ?? 67}',
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFFA5800),
                                  ),
                                ),
                                const Text(
                                  'Contributor',
                                  style: TextStyle(
                                    fontSize: 14,
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
              items: postedItems
                  .map((item) => _buildPostedItemCard(item))
                  .toList(),
              onFilterTap: (offset) => _showFilterPopup(context, offset),
              showAddIcon: isEditing,
              onTitleTap: () => Navigator.pushNamed(context, '/posted-items'),
              scrollController: _postedItemsScrollController,
              progress: _postedItemsProgress,
              onAddTap: () => Navigator.pushNamed(context, '/post-item'),
            ),
            const SizedBox(height: 20),

            // --- Your Order Transactions Section ---
            if (!user!.hideTransactions || isEditing)
            _buildSection(
              title: 'Your Order Transactions',
              items: transactions.map((t) => _buildTransactionCard(t)).toList(),
              onFilterTap: (offset) => _showFilterPopup(context, offset),
              showVisibilityIcon: isEditing,
              onTitleTap: () =>
                  Navigator.pushNamed(context, '/order-transactions'),
              scrollController: _transactionsScrollController,
              progress: _transactionsProgress,
              isTransactions: true,
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
                    onPressed: () {
                      setState(() {
                        isEditing = true;
                        _nameController.text = user.displayName ?? 'Real Name';
                        localHideTransactions = user.hideTransactions;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(220, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
                        onPressed: () async {
                          // Persistent Save
                          await authProvider.saveUserProfile(
                            firstName: _nameController.text.split(' ').first,
                            lastName: _nameController.text.contains(' ') ? _nameController.text.split(' ').last : '',
                            dateOfBirth: user.dateOfBirth ?? DateTime.now(),
                            selectedTags: user.selectedTags ?? [],
                            hideTransactions: localHideTransactions,
                          );
                          // TODO: Profile picture upload logic if _pickedImage != null
                          setState(() => isEditing = false);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.greenAccent[700],
                          foregroundColor: Colors.white,
                          minimumSize: const Size(160, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
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
                        onPressed: () {
                          // Discard Changes
                          setState(() {
                            isEditing = false;
                            _pickedImage = null;
                            _nameController.text = user.displayName ?? 'Real Name';
                            localHideTransactions = user.hideTransactions;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(160, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Discard Changes',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),
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
    required ScrollController scrollController,
    required double progress,
    VoidCallback? onAddTap,
    bool isTransactions = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFA5800),
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
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      if (showAddIcon)
                        Padding(
                          padding: const EdgeInsets.only(right: 12.0),
                          child: GestureDetector(
                            onTap: onAddTap,
                            child: const Icon(
                              Icons.add_circle,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      if (showVisibilityIcon)
                        Padding(
                          padding: const EdgeInsets.only(right: 12.0),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                localHideTransactions = !localHideTransactions;
                              });
                            },
                            child: Icon(
                              localHideTransactions ? Icons.visibility_off : Icons.visibility,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      if (!isEditing)
                      GestureDetector(
                        onTapDown: (details) =>
                            onFilterTap(details.globalPosition),
                        child: const Icon(
                          Icons.swap_vert,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
              controller: scrollController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 16, bottom: 16),
              child: Row(children: items),
            ),
            // Progress indicator at the bottom
            Container(
              height: 4,
              width: double.infinity,
              margin: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
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
              image: item.imageUrl != null ? DecorationImage(
                image: NetworkImage(item.imageUrl!),
                fit: BoxFit.cover,
              ) : null,
            ),
            child: item.imageUrl == null ? const Icon(Icons.fastfood, color: Colors.white30) : null,
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
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
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
              image: transaction.imageUrl != null ? DecorationImage(
                image: NetworkImage(transaction.imageUrl!),
                fit: BoxFit.cover,
              ) : null,
            ),
            child: transaction.imageUrl == null ? const Icon(Icons.receipt, color: Colors.white30) : null,
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
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
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
