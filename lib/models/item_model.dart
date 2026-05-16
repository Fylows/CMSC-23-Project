class PostedItem {
  final String id;
  final String name;
  final String? imageUrl;
  final DateTime expirationDate;

  PostedItem({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.expirationDate,
  });
}

class OrderTransaction {
  final String id;
  final String name;
  final String? imageUrl;
  final String quantity;
  final String status; // 'Pending', 'To Claim', 'Completed', 'Cancelled'

  OrderTransaction({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.quantity,
    required this.status,
  });
}
