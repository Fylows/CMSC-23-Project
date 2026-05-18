import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../providers/auth/auth_provider.dart';
import '../../providers/posting/posting_provider.dart';

class PostItemPage extends StatefulWidget {
  const PostItemPage({super.key});

  @override
  State<PostItemPage> createState() => _PostItemPageState();
}

class _PostItemPageState extends State<PostItemPage> {
  final itemNameController = TextEditingController();
  final descriptionController = TextEditingController();
  final stockController = TextEditingController(text: '0');

  File? selectedImage;
  final ImagePicker _imagePicker = ImagePicker();

  final List<String> allTags = [
    'Meat',
    'Veggies',
    'Fastfood',
    'Fish',
    'vegan',
    'cafes',
    'gluten-free',
    'trending',
    'sisig',
    'buko pie',
    'balut',
    'healthy',
    'taho',
    'korean',
    'halal',
    'lumpia',
    'kakanin',
    'home-cooked',
    'halo-halo',
    'raw ingredients',
    'sulit-meals',
    'pancit',
  ];
  Set<String> selectedTags = {};

  Future<void> pickImage() async {
    final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });
    }
  }

  void _showTextEditDialog(String title, TextEditingController controller, {bool isNumeric = false}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Enter $title...'),
          content: TextField(
            controller: controller,
            keyboardType: isNumeric ? TextInputType.number : TextInputType.multiline,
            maxLines: isNumeric ? 1 : null,
            decoration: InputDecoration(
              hintText: 'Type $title here',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {});
                Navigator.pop(context);
              },
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  void _showTagsDialog() {
    String searchQuery = "";
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final filteredTags = allTags.where((t) => t.toLowerCase().contains(searchQuery.toLowerCase())).toList();
            return AlertDialog(
              title: TextField(
                decoration: const InputDecoration(
                  hintText: 'Enter item name...', // Based on Image 3
                  border: UnderlineInputBorder(),
                ),
                onChanged: (val) {
                  setDialogState(() => searchQuery = val);
                },
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: filteredTags.map((tag) {
                      final isSelected = selectedTags.contains(tag);
                      return GestureDetector(
                        onTap: () {
                          setDialogState(() {
                            if (isSelected) {
                              selectedTags.remove(tag);
                            } else {
                              selectedTags.add(tag);
                            }
                          });
                          setState(() {}); // Update main screen
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.yellow[200] : Colors.white,
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(tag),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              actions: [
                Center(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: const Text('Done'),
                  ),
                ),
              ],
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

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
                    // --- Header Image Area ---
                    Stack(
                      children: [
                        GestureDetector(
                          onTap: pickImage,
                          child: Container(
                            height: 300,
                            width: double.infinity,
                            color: Colors.grey[600],
                            child: selectedImage != null
                                ? Image.file(selectedImage!, fit: BoxFit.cover)
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.camera_alt_outlined, size: 80, color: Colors.white),
                                      SizedBox(height: 10),
                                      Text('Add picture', style: TextStyle(color: Colors.white, fontSize: 18)),
                                    ],
                                  ),
                          ),
                        ),
                        Positioned(
                          top: 10,
                          left: 10,
                          child: CircleAvatar(
                            backgroundColor: Colors.white.withValues(alpha: 0.5),
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
                          GestureDetector(
                            onTap: () => _showTextEditDialog('item name', itemNameController),
                            child: Text(
                              itemNameController.text.isEmpty ? 'Item name' : itemNameController.text,
                              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  selectedTags.isEmpty ? 'Tags go here.' : selectedTags.join(', '),
                                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined),
                                onPressed: _showTagsDialog,
                              ),
                            ],
                          ),
                          const Divider(),
                          ListTile(
                            leading: const Icon(Icons.person_outline),
                            title: Text('Seller: ${user?.displayName ?? 'Anonymous'}'),
                            contentPadding: EdgeInsets.zero,
                          ),
                          const Divider(),
                          GestureDetector(
                            onTap: () => _showTextEditDialog('stock', stockController, isNumeric: true),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Stock', style: TextStyle(fontWeight: FontWeight.bold)),
                                Text(stockController.text),
                              ],
                            ),
                          ),
                          const Divider(),
                          const Text('Description', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 5),
                          GestureDetector(
                            onTap: () => _showTextEditDialog('description', descriptionController),
                            child: Text(
                              descriptionController.text.isEmpty ? 'Write Something...' : descriptionController.text,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                          const SizedBox(height: 40),
                          // --- Location Placeholder ---
                          const Row(
                            children: [
                              Icon(Icons.location_on),
                              SizedBox(width: 5),
                              Text('Location', style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Container(
                            height: 150,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Center(child: Icon(Icons.map, color: Colors.green[200], size: 50)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- Bottom Buttons ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              color: const Color(0xFFCB2020),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (itemNameController.text.isEmpty || selectedImage == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please add an image and item name')),
                          );
                          return;
                        }
                        final postingProvider = Provider.of<PostingProvider>(context, listen: false);
                        await postingProvider.createPosting(
                          currentUser: user!,
                          itemName: itemNameController.text,
                          description: descriptionController.text,
                          photoFile: selectedImage,
                          selectedTags: selectedTags.toList(),
                          expirationDate: DateTime.now().add(const Duration(days: 7)), // Default
                        );
                        if (mounted) Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6BBF6B),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Save'),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE67E22),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Cancel'),
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
}
