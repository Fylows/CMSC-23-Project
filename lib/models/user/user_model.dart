class User {
  final String uid;
  final String email;
  final bool isVerified;
  final String? displayName; // Used as Real Name
  final String? username;
  final int contributorScore; // Defaults to 0 or 67

  User({
    required this.uid,
    required this.email,
    this.isVerified = false,
    this.displayName,
    this.username,
    this.contributorScore = 0,
  });

  // convert user to map so we can save to firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'isVerified': isVerified,
      'displayName': displayName,
      'username': username,
      'contributorScore': contributorScore,
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
      contributorScore: map['contributorScore'] ?? 0,
    );
  }
}