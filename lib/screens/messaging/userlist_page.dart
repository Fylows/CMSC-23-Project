import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elbi_eats/services/chat_service.dart';
import 'chat_page.dart';

class UserListPage extends StatelessWidget {
  final String currentUserId;
  final _chatService = ChatService();

  UserListPage({super.key, required this.currentUserId});

  Future<void> _openOrCreateChat(
    BuildContext context,
    String otherUserId,
    String otherUserName,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final sorted = [currentUserId, otherUserId]..sort();
      final chatId = '${sorted[0]}_${sorted[1]}';
      final chatRef = FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId);

      // Step 1 — check existence
      final chatDoc = await chatRef.get();

      // Step 2 — write if needed and WAIT for confirmation
      if (!chatDoc.exists) {
        await chatRef.set({
          'members': sorted,
          'lastMessage': '',
          'lastMessageTime': FieldValue.serverTimestamp(),
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      // Step 3 — only NOW navigate
      if (!context.mounted) return;
      Navigator.pop(context); // dismiss loader

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatPage(
            chatId: chatId,
            currentUserId: currentUserId,
            otherUserName: otherUserName,
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to open chat: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Chat')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            // Exclude the current user from the list
            .where(FieldPath.documentId, isNotEqualTo: currentUserId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final data = users[index].data() as Map<String, dynamic>;
              final otherUserId = users[index].id;
              final otherUserName = data['name'] ?? 'Unknown';

              return ListTile(
                leading: CircleAvatar(
                  child: Text(otherUserName[0].toUpperCase()),
                ),
                title: Text(otherUserName),
                subtitle: Text(data['email'] ?? ''),
                onTap: () =>
                    _openOrCreateChat(context, otherUserId, otherUserName),
              );
            },
          );
        },
      ),
    );
  }
}
