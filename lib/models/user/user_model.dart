class User {
  final String uid;
  final String email;
  final bool isVerified;
  final String? displayName; // Used as Real Name
  final String? username;
  final String? photoUrl;
  final int contributorScore; // Defaults to 0 or 67
  final bool hideTransactions;

  User({
    required this.uid,
    required this.email,
    this.isVerified = false,
    this.displayName,
    this.username,
    this.photoUrl,
    this.contributorScore = 0,
    this.hideTransactions = false,
  });

  // convert user to map so we can save to firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'isVerified': isVerified,
      'displayName': displayName,
      'username': username,
      'photoUrl': photoUrl,
      'contributorScore': contributorScore,
      'hideTransactions': hideTransactions,
      'createdAt': DateTime.now(),
    };
  }

  // Factory constructor to instantiate object from map format
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      isVerified: map['isVerified'] ?? false,
      displayName: map['displayName'],
      username: map['username'],
      photoUrl: map['photoUrl'],
      contributorScore: map['contributorScore'] ?? 0,
      hideTransactions: map['hideTransactions'] ?? false,
    );
  }
}