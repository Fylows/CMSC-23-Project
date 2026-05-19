class PostedItem {
  final String id;
  final String posterId;
  final String posterName;
  final bool posterVerified;
  final String itemName;
  final String description;
  final String? photoUrl;
  final List<String> selectedTags;
  final DateTime expirationDate;
  final String status; // 'available' | 'reserved' | 'completed' | 'cancelled'
  final String? claimedBy;
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
    this.photoUrl, // not required
    required this.selectedTags,
    required this.expirationDate,
    required this.status,
    this.claimedBy,
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
      'photoUrl': photoUrl,
      'selectedTags': selectedTags,
      'expirationDate': expirationDate,
      'status': status,
      'claimedBy': claimedBy,
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
      photoUrl: map['photoUrl'],
      selectedTags: List<String>.from(map['selectedTags'] ?? []), 
      expirationDate: (map['expirationDate'] as dynamic).toDate(), 
      status: map['status'] ?? 'available', 
      claimedBy: map['claimedBy'],
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
    String? photoUrl,
    List<String>? selectedTags,
    DateTime? expirationDate,
    String? status,
    String? claimedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? latitude,
    double? longitude,
  }) {
    return PostedItem(
      id: id ?? this.id, 
      posterId: posterId ?? this.posterId, 
      posterName: posterName ?? this.posterId, 
      posterVerified: posterVerified, 
      itemName: itemName ?? this.itemName, 
      description: description ?? this.description, 
      selectedTags: selectedTags ?? this.selectedTags, 
      expirationDate: expirationDate ?? this.expirationDate, 
      status: status ?? this.status, 
      createdAt: createdAt ?? this.createdAt, 
      updatedAt: updatedAt ?? this.updatedAt,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}

class Claim {
  final String id;
  final String postingId;
  final String posterId;
  final String claimerId;
  final String claimerName;
  final String status; // 'pending' | 'accepted' | 'rejected' | 'completed'
  final DateTime claimedAt;
  final DateTime? resolvedAt;
  final double? latitude;
  final double? longitude;

  Claim({
    required this.id,
    required this.postingId,
    required this.posterId,
    required this.claimerId,
    required this.claimerName,
    required this.status,
    required this.claimedAt,
    this.resolvedAt,
    this.latitude,
    this.longitude,
  });

  /// convert to map for firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'postingId': postingId,
      'posterId': posterId,
      'claimerId': claimerId,
      'claimerName': claimerName,
      'status': status,
      'claimedAt': claimedAt,
      'resolvedAt': resolvedAt,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

   /// create from firestore map
  factory Claim.fromMap(Map<String, dynamic> map, String docId) {
    return Claim(
      id: docId,
      postingId: map['postingId'] ?? '',
      posterId: map['posterId'] ?? '',
      claimerId: map['claimerId'] ?? '',
      claimerName: map['claimerName'] ?? '',
      status: map['status'] ?? 'pending',
      claimedAt: (map['claimedAt'] as dynamic).toDate(),
      resolvedAt: map['resolvedAt']?.toDate(),
      latitude: map['latitude'],
      longitude: map['longitude'],
    );
  }

  /// copy with updates
  Claim copyWith({
    String? id,
    String? postingId,
    String? posterId,
    String? claimerId,
    String? claimerName,
    String? status,
    DateTime? claimedAt,
    DateTime? resolvedAt,
    double? latitude,
    double? longitude,
  }) {
    return Claim(
      id: id ?? this.id,
      postingId: postingId ?? this.postingId,
      posterId: posterId ?? this.posterId,
      claimerId: claimerId ?? this.claimerId,
      claimerName: claimerName ?? this.claimerName,
      status: status ?? this.status,
      claimedAt: claimedAt ?? this.claimedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}