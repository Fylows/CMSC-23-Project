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
  final String? sellerName;
  final String quantity;
  final double price;
  final String status; // 'Pending', 'To Claim', 'Completed', 'Cancelled'
  final DateTime? requestedAt;
  final DateTime? respondedAt;
  final DateTime? completedAt;

  OrderTransaction({
    required this.id,
    required this.name,
    this.imageUrl,
    this.sellerName,
    required this.quantity,
    this.price = 0.0,
    required this.status,
    this.requestedAt,
    this.respondedAt,
    this.completedAt,
  });
}
