import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:elbi_eats/providers/auth/auth_provider.dart';
import 'package:elbi_eats/providers/posting/posting_provider.dart';
import 'package:elbi_eats/providers/leaderboard/leaderboard_provider.dart';
import 'package:elbi_eats/widgets/custom_drawer.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import '../../models/posting_model.dart';
import '../../models/item_model.dart' as item_model;
import '../pantry/item_detail_page.dart';
import 'transaction_detail_page.dart';
import '../../models/claim_model.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isEditing = false;
  bool isAscending = true;
  String selectedSortField = 'Date of Expiration';
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
          _nameController.text =
              '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim();
          if (_nameController.text.isEmpty)
            _nameController.text = user.displayName ?? 'Real Name';
          localHideTransactions = user.hideTransactions;
        });
      }
    });

    _postedItemsScrollController.addListener(() {
      if (_postedItemsScrollController.hasClients &&
          _postedItemsScrollController.position.maxScrollExtent > 0) {
        setState(() {
          _postedItemsProgress =
              _postedItemsScrollController.offset /
              _postedItemsScrollController.position.maxScrollExtent;
        });
      }
    });
    _transactionsScrollController.addListener(() {
      if (_transactionsScrollController.hasClients &&
          _transactionsScrollController.position.maxScrollExtent > 0) {
        setState(() {
          _transactionsProgress =
              _transactionsScrollController.offset /
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
            decoration: const InputDecoration(hintText: 'Real Name'),
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

  void _showFilterPopup(BuildContext context, Offset offset) {
    if (isEditing) return; // Filters removed when editing

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFilterOption(
                            'Date of Expiration',
                            setDialogState,
                          ),
                          _buildFilterOption(
                            'Date of Uploaded Items',
                            setDialogState,
                          ),
                          _buildFilterOption(
                            'Number of Stocks',
                            setDialogState,
                          ),
                          _buildFilterOption(
                            'Alphabetical Order',
                            setDialogState,
                          ),
                          const Divider(),
                          Padding(
                            padding: const EdgeInsets.only(
                              right: 20,
                            ), // Adjust to prevent overflow
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Radio<bool>(
                                      value: true,
                                      groupValue: isAscending,
                                      activeColor: const Color(0xFFCB2020),
                                      onChanged: (val) {
                                        setDialogState(
                                          () => isAscending = val!,
                                        );
                                        setState(() {});
                                      },
                                    ),
                                    const Text(
                                      'Ascending',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFFCB2020),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Radio<bool>(
                                      value: false,
                                      groupValue: isAscending,
                                      activeColor: const Color(0xFFCB2020),
                                      onChanged: (val) {
                                        setDialogState(
                                          () => isAscending = val!,
                                        );
                                        setState(() {});
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
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildFilterOption(String title, StateSetter setDialogState) {
    return Row(
      children: [
        Radio<String>(
          value: title,
          groupValue: selectedSortField,
          activeColor: const Color(0xFFCB2020),
          onChanged: (val) {
            setDialogState(() => selectedSortField = val!);
            setState(() {});
          },
        ),
        Text(title, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  List<PostedItem> _sortItems(List<PostedItem> items) {
    List<PostedItem> sorted = List.from(items);
    sorted.sort((a, b) {
      int cmp = 0;
      switch (selectedSortField) {
        case 'Date of Expiration':
          cmp = a.expirationDate.compareTo(b.expirationDate);
          break;
        case 'Date of Uploaded Items':
          cmp = a.createdAt.compareTo(b.createdAt);
          break;
        case 'Number of Stocks':
          cmp = a.stock.compareTo(b.stock);
          break;
        case 'Alphabetical Order':
          cmp = a.itemName.toLowerCase().compareTo(b.itemName.toLowerCase());
          break;
      }
      return isAscending ? cmp : -cmp;
    });
    return sorted;
  }

  Future<void> _confirmRemovePosting(
    PostedItem item,
    PostingProvider postingProvider,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remove posted item?'),
          content: const Text(
            'Are you sure you want to remove this item from your profile so other users will no longer see it in the pantry?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await postingProvider.deletePosting(item.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Item removed successfully.')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to remove item: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final postingProvider = Provider.of<PostingProvider>(context);
    final leaderboardProvider = Provider.of<LeaderboardProvider>(context);
    final user = authProvider.user;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final leaderboardUser = leaderboardProvider.currentUser;
    final fullName = '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim();

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
                                : (user.profilePictureUrl != null
                                          ? (user.profilePictureUrl!.startsWith(
                                                  'data:image',
                                                )
                                                ? MemoryImage(
                                                    base64Decode(
                                                      user.profilePictureUrl!
                                                          .split(',')
                                                          .last,
                                                    ),
                                                  )
                                                : NetworkImage(
                                                    user.profilePictureUrl!,
                                                  ))
                                          : null)
                                      as ImageProvider?,
                            child:
                                _pickedImage == null &&
                                    user.profilePictureUrl == null
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
                                      _nameController.text.isEmpty
                                          ? (fullName.isEmpty
                                                ? 'Real Name'
                                                : fullName)
                                          : _nameController.text,
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
                              fullName.isEmpty ? 'Real Name' : fullName,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFCB2020),
                              ),
                            ),
                          ),
                        Text(
                          '@${user.username ?? user.email.split('@')[0]}',
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
                                  '${leaderboardUser?.rank ?? '-'}',
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFFA5800),
                                  ),
                                ),
                                Text(
                                  'Contributor',
                                  style: const TextStyle(
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
            StreamBuilder<List<PostedItem>>(
              stream: postingProvider.getUserPostingsStream(user.uid),
              builder: (context, snapshot) {
                final items = _sortItems(snapshot.data ?? []);
                return _buildSection(
                  title: 'Your Posted Items',
                  items: items
                      .map(
                        (item) => _buildPostedItemCard(item, postingProvider),
                      )
                      .toList(),
                  onFilterTap: (offset) => _showFilterPopup(context, offset),
                  showAddIcon: isEditing,
                  onTitleTap: () =>
                      Navigator.pushNamed(context, '/posted-items'),
                  scrollController: _postedItemsScrollController,
                  progress: _postedItemsProgress,
                  onAddTap: () => Navigator.pushNamed(context, '/post-item'),
                );
              },
            ),
            const SizedBox(height: 20),

            // --- Your Order Transactions Section ---
            if (!user.hideTransactions || isEditing)
              StreamBuilder<List<Claim>>(
                stream: postingProvider.getUserClaimsStream(user.uid),
                builder: (context, snapshot) {
                  final claims = snapshot.data ?? [];
                  return _buildSection(
                    title: 'Your Order Transactions',
                    items: claims
                        .map(
                          (claim) => _buildTransactionCardFromClaim(
                            claim,
                            postingProvider,
                          ),
                        )
                        .toList(),
                    onFilterTap: (offset) => _showFilterPopup(context, offset),
                    showVisibilityIcon: isEditing,
                    onTitleTap: () =>
                        Navigator.pushNamed(context, '/order-transactions'),
                    scrollController: _transactionsScrollController,
                    progress: _transactionsProgress,
                    isTransactions: true,
                  );
                },
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
                        _nameController.text = fullName.isEmpty
                            ? (user.displayName ?? 'Real Name')
                            : fullName;
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
                          final names = _nameController.text.split(' ');
                          String firstName = names.isNotEmpty
                              ? names.first
                              : (user.firstName ?? '');
                          String lastName = names.length > 1
                              ? names.sublist(1).join(' ')
                              : (user.lastName ?? '');

                          String? base64Image;
                          if (_pickedImage != null) {
                            final bytes = await _pickedImage!.readAsBytes();
                            base64Image =
                                'data:image/jpeg;base64,${base64Encode(bytes)}';
                          }

                          await authProvider.saveUserProfile(
                            firstName: firstName,
                            lastName: lastName,
                            dateOfBirth: user.dateOfBirth ?? DateTime.now(),
                            selectedTags: user.selectedTags ?? [],
                            hideTransactions: localHideTransactions,
                            profilePictureUrl: base64Image,
                          );
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
                            _nameController.text = fullName.isEmpty
                                ? (user.displayName ?? 'Real Name')
                                : fullName;
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
                              localHideTransactions
                                  ? Icons.visibility_off
                                  : Icons.visibility,
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

  Widget _buildPostedItemCard(
    PostedItem item,
    PostingProvider postingProvider,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ItemDetailPage(item: item)),
        );
      },
      child: Container(
        width: 130,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(15),
              ),
              child: Container(
                height: 90,
                decoration: BoxDecoration(
                  color: const Color(0xFFA35D5D),
                  image: item.photoUrl != null
                      ? DecorationImage(
                          image: NetworkImage(item.photoUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: item.photoUrl == null
                    ? const Icon(
                        Icons.fastfood,
                        color: Colors.white30,
                        size: 36,
                      )
                    : null,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 4),
              child: Text(
                item.itemName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                'Expires ${DateFormat('MM/dd/yyyy').format(item.expirationDate)}',
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Text(
                'Stock: ${item.stock}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (isEditing)
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                child: ElevatedButton(
                  onPressed: () => _confirmRemovePosting(item, postingProvider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    minimumSize: const Size.fromHeight(36),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Remove',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionCardFromClaim(
    Claim claim,
    PostingProvider postingProvider,
  ) {
    return FutureBuilder<PostedItem?>(
      future: postingProvider.postingService.getPosting(claim.postingId),
      builder: (context, snapshot) {
        final posting = snapshot.data;
        final title = posting?.itemName ?? 'Unknown item';
        final statusLabel =
            claim.status[0].toUpperCase() + claim.status.substring(1);
        final imageUrl = posting?.photoUrl;
        final subtitle = posting != null
            ? 'Seller: ${posting.posterName}'
            : 'Seller unavailable';

        return GestureDetector(
          onTap: () {
            if (posting != null) {
              final orderTransaction = item_model.OrderTransaction(
                id: claim.id,
                name: title,
                imageUrl: imageUrl,
                sellerName: posting?.posterName ?? 'Unknown',
                quantity: '1', // Placeholder or add to claim
                price: posting?.price ?? 0.0,
                status: statusLabel,
                requestedAt: claim.claimedAt,
                respondedAt:
                    (claim.status == 'accepted' ||
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
                  builder: (_) =>
                      TransactionDetailPage(transaction: orderTransaction),
                ),
              );
            }
          },
          child: Container(
            width: 130,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(15),
                  ),
                  child: Container(
                    height: 90,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6BC76B),
                      image: imageUrl != null
                          ? DecorationImage(
                              image: NetworkImage(imageUrl),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: imageUrl == null
                        ? const Icon(
                            Icons.receipt_long,
                            color: Colors.white30,
                            size: 36,
                          )
                        : null,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 4),
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    subtitle,
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(statusLabel),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      statusLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
