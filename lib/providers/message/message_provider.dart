import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elbi_eats/models/message_model.dart';

Stream<List<Message>> getMessages(String chatId) {
  return FirebaseFirestore.instance
      .collection('chats')
      .doc(chatId)
      .collection('messages')
      .orderBy('timestamp')
      .snapshots()
      .map(
        (snapshot) =>
            snapshot.docs.map((doc) => Message.fromMap(doc.data())).toList(),
      );
}
