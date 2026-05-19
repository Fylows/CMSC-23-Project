class AppNotification {
  final String id;
  final String? userId;
  final String type; // 'chat', 'claim', 'claimStatus'
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final bool read;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    this.userId,
    required this.type,
    required this.title,
    required this.body,
    required this.data,
    required this.read,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'type': type,
    'title': title,
    'body': body,
    'data': data,
    'read': read,
    'createdAt': createdAt.toIso8601String(),
  };

  factory AppNotification.fromMap(String id, Map<String, dynamic> map) =>
      AppNotification(
        id: id,
        userId: map['userId'],
        type: map['type'],
        title: map['title'],
        body: map['body'],
        data: map['data'] ?? {},
        read: map['read'] ?? false,
        createdAt: DateTime.parse(map['createdAt']),
      );
}