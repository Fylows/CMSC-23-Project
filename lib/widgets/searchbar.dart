import 'package:flutter/material.dart';

class AppSearchBar extends StatefulWidget {
  final String hintText;

  const AppSearchBar({
    super.key,
    this.hintText = 'Find Anything',
  });

  @override
  State<AppSearchBar> createState() => AppSearchBarState();
}

class AppSearchBarState extends State<AppSearchBar> {
  final searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE05A00), width: 1.8),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          const Icon(Icons.search, color: Color(0xFFE05A00), size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: searchController,
              enabled: true, // just a setting to allow typing
              onSubmitted: (value) {
                Navigator.pushNamed(context, '/pantry', arguments: value);
              },
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade400,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            const SizedBox(width: 8),
        ],
      ),
    );
  }
}
