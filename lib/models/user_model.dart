class User {
  final String uid;
  final String email;
  final bool isVerified; // for photo verification
  final String? displayName;

  User({
    required this.uid,
    required this.email,
    this.isVerified = false,
    this.displayName
  });

  // convert user to map so we can save to firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'isVerified': isVerified,
      'displayName': displayName,
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
    );
  }
}