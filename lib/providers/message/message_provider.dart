import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:elbi_eats/models/message_model.dart';

class MessageProvider extends ChangeNotifier {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // ─── State ───────────────────────────────────────────────────────────────
  List<Map<String, dynamic>> _chats = [];
  List<Message> _messages = [];
  bool _isLoading = false;
  String? _error;
  String? _activeChatId;

  // ─── Getters ─────────────────────────────────────────────────────────────
  List<Map<String, dynamic>> get chats => _chats;
  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get activeChatId => _activeChatId;

  // ─── Stream subscriptions ────────────────────────────────────────────────
  Stream<QuerySnapshot>? _chatListSubscription;
  Stream<QuerySnapshot>? _messagesSubscription;

  // ─── Chat List ───────────────────────────────────────────────────────────

  /// Call this on startup to listen to all chats for the current user
  Stream<List<Map<String, dynamic>>> watchChats(String uid) {
    return _db
        .collection('chats')
        .where('members', arrayContains: uid)
        .snapshots()
        .map(
          (snap) => snap.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final memberNames = Map<String, String>.from(
              data['memberNames'] ?? {},
            );

            // Get the OTHER person's name
            final otherName = memberNames.entries
                .firstWhere(
                  (e) => e.key != uid,
                  orElse: () => MapEntry('', 'Unknown'),
                )
                .value;

            // "You: ..." or the last message as-is
            final lastSenderId = data['lastMessageSenderId'] ?? '';
            final lastMessage = data['lastMessage'] ?? '';
            final preview = lastMessage.isEmpty
                ? ''
                : lastSenderId == uid
                ? 'You: $lastMessage'
                : lastMessage;

            return {
              'chatId': doc.id,
              'otherUserName': otherName,
              'itemName': data['itemName'] ?? '',
              'lastMessage': preview,
              'lastMessageTime': data['lastMessageTime'],
              'members': data['members'] ?? [],
            };
          }).toList(),
        );
  }

  // ─── Get or Create Chat ──────────────────────────────────────────────────

  /// Returns chatId. Creates the doc if it doesn't exist.
  Future<String?> getOrCreateChat({
    required String otherUserId,
    required String otherUserName,
    required String itemId,
    required String itemName,
    required String currentUserName,
    required String claimerId,
    String? claimingId,
  }) async {
    final currentUid = _auth.currentUser?.uid;
    if (currentUid == null) return null;

    try {
      _isLoading = true;
      notifyListeners();

      final sorted = [currentUid, otherUserId]..sort();
      final chatId = '${sorted[0]}_${sorted[1]}_$itemId';

      final chatRef = _db.collection('chats').doc(chatId);
      final chatDoc = await chatRef.get();

      if (!chatDoc.exists) {
        await chatRef.set({
          'members': sorted,
          'memberNames': {
            currentUid: currentUserName,
            otherUserId: otherUserName,
          },
          'itemId': itemId,
          'itemName': itemName,
          'lastMessage': '',
          'lastMessageSenderId': '',
          'lastMessageTime': FieldValue.serverTimestamp(),
          'createdAt': FieldValue.serverTimestamp(),
          'claimingId': claimingId,
          'claimerUid': claimerId,
          'claimed': false,
          'claimTime': null,
        });
      }

      _isLoading = false;
      notifyListeners();
      return chatId;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }
  // ─── Messages ────────────────────────────────────────────────────────────

  /// Stream of messages for a given chatId
  Stream<List<Message>> watchMessages(String chatId) {
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) => Message.fromMap(d.data())).toList(),
        );
  }

  /// Send a message and update lastMessage on the chat doc
  Future<void> sendMessage(String chatId, String text) async {
    final currentUid = _auth.currentUser?.uid;
    if (currentUid == null || text.trim().isEmpty) return;

    try {
      final chatRef = _db.collection('chats').doc(chatId);
      final batch = _db.batch();

      final msgRef = chatRef.collection('messages').doc();
      batch.set(
        msgRef,
        Message(
          senderId: currentUid,
          text: text.trim(),
          timestamp: DateTime.now(),
        ).toMap(),
      );

      batch.update(chatRef, {
        'lastMessage': text.trim(),
        'lastMessageSenderId': currentUid, // ← track who sent last
        'lastMessageTime': FieldValue.serverTimestamp(),
      });
      await batch.commit();
    } catch (e) {
      _error = e.toString();
      debugPrint('DEBUG sendMessage error: $e');
      notifyListeners();
    }
  }

  /// Delete chat and all its messages
  Future<void> deleteChat(String chatId) async {
    try {
      // Delete all messages first
      final messages = await _db
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .get();

      final batch = _db.batch();
      for (final doc in messages.docs) {
        batch.delete(doc.reference);
      }
      // Then delete the chat doc itself
      batch.delete(_db.collection('chats').doc(chatId));
      await batch.commit();
    } catch (e) {
      _error = e.toString();
      debugPrint('DEBUG deleteChat error: $e');
      notifyListeners();
    }
  }

  // delete chat relating to item when posting is deleted
  Future<void> deleteChatsForItem(String itemId) async {
    try {
      // Find all chats containing this itemId
      final chatsSnap = await _db
          .collection('chats')
          .where('itemId', isEqualTo: itemId)
          .get();

      for (final chatDoc in chatsSnap.docs) {
        // Delete all messages in each chat
        final messages = await chatDoc.reference.collection('messages').get();

        final batch = _db.batch();
        for (final msg in messages.docs) {
          batch.delete(msg.reference);
        }
        // Delete the chat doc itself
        batch.delete(chatDoc.reference);
        await batch.commit();
      }

      debugPrint(
        'DEBUG deleted ${chatsSnap.docs.length} chats for item $itemId',
      );
    } catch (e) {
      _error = e.toString();
      debugPrint('DEBUG deleteChatsForItem error: $e');
      notifyListeners();
    }
  }
  // ─── Helpers ─────────────────────────────────────────────────────────────

  /// Build a consistent chatId from two uids
  String buildChatId(String uid1, String uid2, String itemId) {
    final sorted = [uid1, uid2]..sort();
    // Use itemId not itemName — names can have spaces/special chars
    return '${sorted[0]}_${sorted[1]}_$itemId';
  }

  /// Clear active chat
  void clearActiveChat() {
    _activeChatId = null;
    _messages = [];
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Called by ChatPage on open — guarantees doc exists before stream starts
  Future<void> ensureChatExists(String chatId, String currentUserId) async {
    final chatRef = _db.collection('chats').doc(chatId);
    final doc = await chatRef.get();

    if (!doc.exists) {
      final uids = chatId.split('_');
      await chatRef.set({
        'members': uids,
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      debugPrint('DEBUG ensureChatExists: created $chatId');
    }
  }

  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      return doc.data();
    } catch (e) {
      debugPrint('DEBUG getUserProfile error: $e');
      return null;
    }
  }

  Stream<Map<String, dynamic>?> watchChat(String chatId) {
    return _db
        .collection('chats')
        .doc(chatId)
        .snapshots()
        .map((snap) => snap.data());
  }
}
