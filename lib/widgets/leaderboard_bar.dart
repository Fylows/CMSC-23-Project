import 'package:flutter/material.dart';

class LeaderboardBar extends StatelessWidget {
  final String imageUrl;
  final double height;
  final Color barColor;
  final int rank;
  final bool isCenter;

  const LeaderboardBar({
    required this.imageUrl,
    required this.height,
    required this.barColor,
    required this.rank,
    this.isCenter = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Avatar
        Container(
          width: isCenter ? 56 : 48,
          height: isCenter ? 56 : 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            image: DecorationImage(
              image: NetworkImage(imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 6),
        // Bar
        Container(
          width: isCenter ? 70 : 58,
          height: height,
          decoration: BoxDecoration(
            color: barColor,
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
