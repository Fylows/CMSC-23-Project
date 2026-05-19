import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:elbi_eats/providers/auth/auth_provider.dart';
import 'package:elbi_eats/providers/notification/notification_provider.dart';
import 'package:intl/intl.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final notificationProvider = context.watch<NotificationProvider>();
    final uid = authProvider.user?.uid;

    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text('Not logged in')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: StreamBuilder<List>(
        stream: notificationProvider.watchNotifications(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No notifications yet'),
            );
          }

          final notifications = snapshot.data!;

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notif = notifications[index];
              return GestureDetector(
                onTap: () {
                  notificationProvider.markAsRead(uid, notif.id);
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: notif.read ? Colors.grey[100] : Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: notif.read ? Colors.grey[300]! : Colors.blue,
                      width: notif.read ? 1 : 2,
                    ),
                  ),
                  child: ListTile(
                    leading: Icon(
                      _getIconForType(notif.type),
                      color: _getColorForType(notif.type),
                    ),
                    title: Text(notif.title),
                    subtitle: Text(notif.body),
                    trailing: GestureDetector(
                      onTap: () {
                        notificationProvider.deleteNotification(uid, notif.id);
                      },
                      child: Icon(
                        Icons.close,
                        size: 20,
                        color: Colors.grey,
                      ),
                    ),
                    isThreeLine: true,
                    dense: true,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'chat':
        return Icons.message;
      case 'claim':
        return Icons.shopping_cart;
      case 'claimStatus':
        return Icons.done_all;
      default:
        return Icons.notifications;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'chat':
        return Colors.blue;
      case 'claim':
        return Colors.orange;
      case 'claimStatus':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
