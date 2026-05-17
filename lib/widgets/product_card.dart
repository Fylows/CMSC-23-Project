import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String? price;
  final String? meetUp;
  final String? seller;
  final bool isWide;

  const ProductCard({
    required this.imageUrl,
    required this.name,
    this.price,
    this.meetUp,
    this.seller,
    this.isWide = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF7B5EA7),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          // Circular image
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Text info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  name,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                if (price != null)
                  Text(
                    price!,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                if (meetUp != null)
                  Text(
                    meetUp!,
                    textAlign: TextAlign.right,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                if (seller != null)
                  Text(
                    seller!,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
