class Claim {
  final String id;
  final String postingId;
  final String posterId;
  final String claimerId;
  final String claimerName;
  final String posterName;
  final String itemName;
  final String status; // 'pending' | 'accepted' | 'rejected'
  final DateTime claimedAt;
  final DateTime? meetupDate; // NEW - when they plan to pick up
  final DateTime? resolvedAt;
  final bool reminderSent; // NEW - tracks if reminder was sent
  final String? reminderSentAt;

  Claim({
    required this.id,
    required this.postingId,
    required this.posterId,
    required this.claimerId,
    required this.claimerName,
    required this.posterName,
    required this.itemName,
    required this.status,
    required this.claimedAt,
    this.meetupDate,
    this.resolvedAt,
    this.reminderSent = false,
    this.reminderSentAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'postingId': postingId,
      'posterId': posterId,
      'claimerId': claimerId,
      'claimerName': claimerName,
      'posterName': posterName,
      'itemName': itemName,
      'status': status,
      'claimedAt': claimedAt,
      'meetupDate': meetupDate,
      'resolvedAt': resolvedAt,
      'reminderSent': reminderSent,
      'reminderSentAt': reminderSentAt,
    };
  }

  factory Claim.fromMap(Map<String, dynamic> map, String docId) {
    return Claim(
      id: docId,
      postingId: map['postingId'] ?? '',
      posterId: map['posterId'] ?? '',
      claimerId: map['claimerId'] ?? '',
      claimerName: map['claimerName'] ?? '',
      posterName: map['posterName'] ?? '',
      itemName: map['itemName'] ?? '',
      status: map['status'] ?? 'pending',
      claimedAt: (map['claimedAt'] as dynamic).toDate(),
      meetupDate: map['meetupDate']?.toDate(),
      resolvedAt: map['resolvedAt']?.toDate(),
      reminderSent: map['reminderSent'] ?? false,
      reminderSentAt: map['reminderSentAt'],
    );
  }
}