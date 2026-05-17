import 'package:flutter/material.dart';

class LeaderboardBar extends StatelessWidget {
  final String imageUrl;
  final double height;
  final Color outlineColor; // replaces barColor
  final int rank;
  final bool isCenter;

  const LeaderboardBar({
    super.key,
    required this.imageUrl,
    required this.height,
    required this.outlineColor,
    required this.rank,
    this.isCenter = false,
  });

  Color get _barColor => switch (rank) {
    1 => const Color(0xFFE8C84A),
    2 => const Color(0xFFB0B0B0),
    3 => const Color(0xFF6BC76B),
    _ => Colors.grey,
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: isCenter ? 56 : 48,
          height: isCenter ? 56 : 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: outlineColor,
              width: 2,
            ), // uses outlineColor
            image: DecorationImage(
              image: NetworkImage(imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: isCenter ? 70 : 58,
          height: height,
          decoration: BoxDecoration(
            color: _barColor, // hardcoded per rank
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
          ),
          alignment: Alignment.topCenter,
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            '#$rank',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}
