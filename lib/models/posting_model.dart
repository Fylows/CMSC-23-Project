class PostedItem {
  final String id;
  final String posterId;
  final String posterName;
  final bool posterVerified;
  final String itemName;
  final String description;
  final double price;
  final String? photoUrl;
  final List<String> selectedTags;
  final DateTime expirationDate;
  final String status; // 'available' | 'reserved' | 'completed' | 'cancelled'
  final String? claimedBy;
  final int stock;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double? latitude;
  final double? longitude;

  PostedItem({
    required this.id,
    required this.posterId,
    required this.posterName,
    required this.posterVerified,
    required this.itemName,
    required this.description,
    this.price = 0.0,
    this.photoUrl, // not required
    required this.selectedTags,
    required this.expirationDate,
    required this.status,
    this.claimedBy,
    this.stock = 1,
    required this.createdAt,
    required this.updatedAt,
    this.latitude,
    this.longitude,
  });

  /// convert to map for firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'posterId': posterId,
      'posterName': posterName,
      'posterVerified': posterVerified,
      'itemName': itemName,
      'description': description,
      'price': price,
      'photoUrl': photoUrl,
      'selectedTags': selectedTags,
      'expirationDate': expirationDate,
      'status': status,
      'claimedBy': claimedBy,
      'stock': stock,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  /// create from firestore map
  factory PostedItem.fromMap(Map<String, dynamic> map, String docId) {
    return PostedItem(
      id: docId, 
      posterId: map['posterId'] ?? '', 
      posterName: map['posterName'] ?? '', 
      posterVerified: map['posterVerified'] ?? false, 
      itemName: map['itemName'] ?? '', 
      description: map['description'] ?? '', 
      price: (map['price'] ?? 0.0).toDouble(),
      photoUrl: map['photoUrl'],
      selectedTags: List<String>.from(map['selectedTags'] ?? []), 
      expirationDate: (map['expirationDate'] as dynamic).toDate(), 
      status: map['status'] ?? 'available', 
      claimedBy: map['claimedBy'],
      stock: map['stock'] ?? 1,
      createdAt: (map['createdAt'] as dynamic).toDate(),
      updatedAt: (map['updatedAt'] as dynamic).toDate(), 
      latitude: map['latitude'],
      longitude: map['longitude'],
    );
  }
  
  /// copy with updates
  PostedItem copyWith({
    String? id,
    String? posterId,
    String? posterName,
    bool? posterverified,
    String? itemName,
    String? description,
    double? price,
    String? photoUrl,
    List<String>? selectedTags,
    DateTime? expirationDate,
    String? status,
    String? claimedBy,
    int? stock,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? latitude,
    double? longitude,
  }) {
    return PostedItem(
      id: id ?? this.id, 
      posterId: posterId ?? this.posterId, 
      posterName: posterName ?? this.posterName, 
      posterVerified: posterVerified, 
      itemName: itemName ?? this.itemName, 
      description: description ?? this.description, 
      price: price ?? this.price,
      photoUrl: photoUrl ?? this.photoUrl,
      selectedTags: selectedTags ?? this.selectedTags, 
      expirationDate: expirationDate ?? this.expirationDate, 
      status: status ?? this.status, 
      claimedBy: claimedBy ?? this.claimedBy,
      stock: stock ?? this.stock,
      createdAt: createdAt ?? this.createdAt, 
      updatedAt: updatedAt ?? this.updatedAt,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}