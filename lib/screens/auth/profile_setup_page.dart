import 'package:flutter/material.dart';

class ProfileSetupPage extends StatefulWidget {
  final VoidCallback? onComplete;

  const ProfileSetupPage({
    this.onComplete,
    super.key
  });

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  // all available tags (subject to change)
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

  // tracker for selected tags
  Set<String> selectedTags = {};

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

  /// handle "lets eat" button
  Future<void> handleComplete() async {
    // TODO: save selected tags to firestore user profile
    // i'll finish implementing this in milestone 2 after we set up firestore
    // for now just proceed to home 
    widget.onComplete?.call();
  }

  @override
  Widget build(BuildContext build) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // initially there was a back button here (as seen in our figma wireframe)
            // but I realize that it is already redundant since the profile setup is part of 
            // the mandatory onboarding (its not optional!), the user HAS to complete it or they
            // cannot proceed, so I opted to remove it
            // anyway, if users want to change preferences later, they can do so in a profile edit screen

            const SizedBox(height: 48),
            // ====== header ==========
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "What's your",
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      height: 1.1,
                    ),
                  ),
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: 'Elbi craving ',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFFA5800),
                          ),
                        ),
                        TextSpan(
                          text: 'today?',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFCB2020),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Help us find your preferences',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // ==== tag grid ====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GridView.builder(
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
                    onTap: () => toggleTag(tag),
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
                              fontSize: 14,
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
            ),
            const SizedBox(height: 32),

            // ==== info box ==== 
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  border: Border.all(
                    color: Colors.orange.shade200,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: Colors.orange.shade700,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "We'll use this to personalize your food feed in Los Banos",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // ===== button =====
            Padding(
              padding:  const EdgeInsets.symmetric(horizontal: 24),
              child: ElevatedButton(
                onPressed: handleComplete,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFA5800),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Let's Eat!",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_forward, color: Color(0xFFFA5800), size: 18),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}