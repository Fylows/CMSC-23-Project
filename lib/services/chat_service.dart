import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  final _db = FirebaseFirestore.instance;

  Future<String> getOrCreateChat(String uid1, String uid2) async {
    final sorted = [uid1, uid2]..sort();
    final chatId = '${sorted[0]}_${sorted[1]}';

    final chatRef = _db.collection('chats').doc(chatId);
    final chatDoc = await chatRef.get();

    if (!chatDoc.exists) {
      await chatRef.set({
        'members': sorted, // ← same sorted list
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    return chatId;
  }
}
