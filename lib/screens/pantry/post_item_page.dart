import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../../providers/auth/auth_provider.dart';
import '../../providers/posting/posting_provider.dart';
import 'package:location/location.dart';
import 'package:elbi_eats/services/location_service.dart';

class PostItemPage extends StatefulWidget {
  const PostItemPage({super.key});

  @override
  State<PostItemPage> createState() => _PostItemPageState();
}

class _PostItemPageState extends State<PostItemPage> {
  // form controllers
  final itemNameController = TextEditingController();
  final descriptionController = TextEditingController();

  // image picker
  File? selectedImage;
  final ImagePicker _imagePicker = ImagePicker();

  // date picker
  DateTime? expirationDate;

  // tag selector
  final List<String> allTags = [
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

  // validation errors
  String? itemNameError;
  String? descriptionError;
  String? photoError;
  String? dateError;

  @override
  void dispose() {
    itemNameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  /// pick image from camera or gallery
  Future<void> pickImage(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          selectedImage = File(pickedFile.path);
          photoError = null;
        });
      }
    } catch (e) {
      setState(() {
        photoError = 'Failed to pick image $e';
      });
    }
  }

  /// show image picker modal
  void showImagePickerModal() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Pick Item Photo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFFFA5800)),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: Color(0xFFFA5800),
              ),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Open date picker
  Future<void> selectExpirationDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: expirationDate ?? DateTime.now().add(Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: Color(0xFFFA5800)),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != expirationDate) {
      setState(() {
        expirationDate = picked;
        dateError = null;
      });
    }
  }

  /// toggle tag selection
  void toggleTag(String tag) {
    setState(() {
      if (selectedTags.contains(tag)) {
        selectedTags.remove(tag);
      } else {
        selectedTags.add(tag);
      }
    });
  }

  /// validate form inputs
  bool validateInputs() {
    setState(() {
      itemNameError = null;
      descriptionError = null;
      photoError = null;
      dateError = null;
    });

    bool isValid = true;

    // item name validation
    if (itemNameController.text.isEmpty) {
      setState(() {
        itemNameError = 'Item name is required';
      });
      isValid = false;
    } else if (itemNameController.text.length < 3) {
      setState(() {
        itemNameError = 'Item name must be at least 3 characters';
      });
      isValid = false;
    }

    // description validation
    if (descriptionController.text.isEmpty) {
      setState(() {
        descriptionError = 'Description is required';
      });
      isValid = false;
    } else if (descriptionController.text.length < 10) {
      setState(() {
        descriptionError = 'Description must be at least 10 characters';
      });
      isValid = false;
    }

    // photo validation
    if (selectedImage == null) {
      setState(() {
        photoError = 'Please select a photo';
      });
      isValid = false;
    }

    // expiration date validation
    if (expirationDate == null) {
      setState(() {
        dateError = 'Expiration date is required';
      });
      isValid = false;
    }

    return isValid;
  }

  /// handle form submission
  Future<void> handleSubmit() async {
    if (!validateInputs()) {
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final postingProvider = context.read<PostingProvider>();

    if (authProvider.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to post items')),
      );
      return;
    }

    try {
      final location = await LocationService().getCurrentLocation();

      await postingProvider.createPosting(
        currentUser: authProvider.user!,
        itemName: itemNameController.text.trim(),
        description: descriptionController.text.trim(),
        photoFile: selectedImage,
        selectedTags: selectedTags.toList(),
        expirationDate: expirationDate!,
        location: location,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item posted successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error posting item: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PostingProvider>(
      builder: (context, postingProvider, _) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.black),
            ),
            title: const Text(
              'Post an Item',
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
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ===== ITEM NAME =====
                const Text(
                  'Item Name',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: itemNameController,
                  enabled: !postingProvider.isLoading,
                  decoration: InputDecoration(
                    hintText: 'e.g., 3 Extra Eggs',
                    errorText: itemNameError,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Color(0xFFFA5800),
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ===== DESCRIPTION =====
                const Text(
                  'Description',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descriptionController,
                  enabled: !postingProvider.isLoading,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText:
                        'Describe the item, quality, and any special notes',
                    errorText: descriptionError,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Color(0xFFFA5800),
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ===== PHOTO =====
                const Text(
                  'Item Photo',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: postingProvider.isLoading
                      ? null
                      : showImagePickerModal,
                  child: Container(
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: photoError != null
                            ? Colors.red
                            : Colors.grey.shade300,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey.shade50,
                    ),
                    child: selectedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              selectedImage!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.camera_alt,
                                size: 40,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap to add photo',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                if (photoError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      photoError!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                const SizedBox(height: 20),

                // ===== EXPIRATION DATE =====
                const Text(
                  'Expiration Date',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: postingProvider.isLoading
                      ? null
                      : selectExpirationDate,
                  child: TextField(
                    enabled: false,
                    decoration: InputDecoration(
                      hintText: 'DD/MM/YYYY',
                      errorText: dateError,
                      suffixIcon: Icon(
                        Icons.calendar_today,
                        color: Colors.grey.shade600,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    controller: TextEditingController(
                      text: expirationDate != null
                          ? DateFormat('dd/MM/yyyy').format(expirationDate!)
                          : '',
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ===== TAGS =====
                const Text(
                  'Select Tags (optional)',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5,
                    childAspectRatio: 1.8,
                  ),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: allTags.length,
                  itemBuilder: (context, index) {
                    final tag = allTags[index];
                    final isSelected = selectedTags.contains(tag);

                    return GestureDetector(
                      onTap: postingProvider.isLoading
                          ? null
                          : () => toggleTag(tag),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFFA5800)
                              : Colors.white,
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFFFA5800)
                                : Colors.grey.shade300,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              tag,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),

                // ===== SUBMIT BUTTON =====
                if (postingProvider.isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  ElevatedButton(
                    onPressed: handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFA5800),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Post Item',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.upload, color: Colors.white),
                        ],
                      ),
                    ),
                  ),

                // ===== ERROR MESSAGE =====
                if (postingProvider.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        border: Border.all(color: Colors.red.shade200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        postingProvider.errorMessage!,
                        style: TextStyle(color: Colors.red.shade800),
                      ),
                    ),
                  ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}
