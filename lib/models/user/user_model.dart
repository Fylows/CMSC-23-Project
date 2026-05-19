class User {
  final String uid;
  final String email;
  final String? displayName;
  final String? username;
  final String? firstName;
  final String? lastName;
  final DateTime? dateOfBirth;
  final List<String>? selectedTags;
  final String? profilePictureUrl;
  final bool isVerified;
  final String? verificationSelfieUrl;
  final int contributorScore; // Defaults to 0 or 67
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final double? latitude;
  final double? longitude;
  final double discoveryRadius; // in km, default 5.0

  User({
    required this.uid,
    required this.email,
    this.displayName,
    this.username,
    this.firstName,
    this.lastName,
    this.dateOfBirth,
    this.selectedTags,
    this.profilePictureUrl,
    this.isVerified = false,
    this.verificationSelfieUrl,
    this.contributorScore = 0,
    this.createdAt,
    this.updatedAt,
    this.latitude,
    this.longitude,
    this.discoveryRadius = 5.0,
  });

  // convert user to map so we can save to firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth,
      'selectedTags': selectedTags ?? [],
      'profilePictureUrl': profilePictureUrl,
      'isVerified': isVerified,
      'verificationSelfieUrl': verificationSelfieUrl,
      'contributorScore': contributorScore,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'latitude': latitude,
      'longitude': longitude,
      'discoveryRadius': discoveryRadius,
    };
  }

  // Factory constructor to instantiate object from map format
  // easier exp: create User from firestore map
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'],
      username: map['username'],
      firstName: map['firstName'] ?? map['firstname'], // fallback to old
      lastName: map['lastName'],
      dateOfBirth: map['dateOfBirth']?.toDate(),
      selectedTags: List<String>.from(map['selectedTags'] ?? []),
      profilePictureUrl: map['profilePictureUrl'],
      isVerified: map['isVerified'] ?? false,
      verificationSelfieUrl: map['verificationSelfieUrl'],
      contributorScore: map['contributorScore'] ?? 0,
      createdAt: map['createdAt']?.toDate(),
      updatedAt: map['updatedAt']?.toDate(),
      latitude: map['latitude'],
      longitude: map['longitude'],
      discoveryRadius: map['discoveryRadius'] ?? 5.0,
    );
  }

  /// create a copy with the fields
  User copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? username,
    String? firstName,
    String? lastName,
    DateTime? dateOfBirth,
    List<String>? selectedTags,
    String? profilePicutreUrl,
    bool? isVerified,
    String? verificationSelfieUrl,
    int? contributorScore,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? latitude,
    double? longitude,
    double? discoveryRadius,
  }) {
    return User(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      username: username ?? this.username,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      selectedTags: selectedTags ?? this.selectedTags,
      profilePictureUrl: profilePicutreUrl ?? this.profilePictureUrl,
      isVerified: isVerified ?? this.isVerified,
      verificationSelfieUrl: verificationSelfieUrl ?? this.verificationSelfieUrl,
      contributorScore: contributorScore ?? this.contributorScore,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      discoveryRadius: discoveryRadius ?? this.discoveryRadius,
      
    );
  }

  @override
  String toString() => 'User(uid: $uid, email: $email, firstName: $firstName, displayName: $displayName, isVerified: $isVerified)';
}