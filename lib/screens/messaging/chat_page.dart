import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elbi_eats/models/message_model.dart';

// ─── Page ───────────────────────────────────────────────────────────────────

class ChatPage extends StatefulWidget {
  final String chatId;
  final String currentUserId;
  final String otherUserName;

  const ChatPage({
    super.key,
    required this.chatId,
    required this.currentUserId,
    required this.otherUserName,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  void initState() {
    super.initState();
    _ensureChatExists(); // ← add this
  }

  Future<void> _ensureChatExists() async {
    final chatRef = FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId);
    print('DEBUG databaseId: ${FirebaseFirestore.instance.databaseId}');
    final doc = await chatRef.get();
    print('DEBUG ChatPage initState - doc exists: ${doc.exists}');

    if (!doc.exists) {
      // Extract uids from chatId (they're separated by _)
      final uids = widget.chatId.split('_');
      if (uids.length == 2) {
        await chatRef.set({
          'members': uids,
          'lastMessage': '',
          'lastMessageTime': FieldValue.serverTimestamp(),
          'createdAt': FieldValue.serverTimestamp(),
        });
        print('DEBUG ChatPage created missing doc');
      }
    }
  }

  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // ─── Stream ──────────────────────────────────────────────────────────────

  Stream<List<Message>> get _messagesStream => FirebaseFirestore.instance
      .collection('chats')
      .doc(widget.chatId)
      .collection('messages')
      .orderBy('timestamp')
      .snapshots()
      .map((snap) => snap.docs.map((d) => Message.fromMap(d.data())).toList());

  // ─── Actions ─────────────────────────────────────────────────────────────

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();

    final chatRef = FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId);

    // Run both writes together
    final batch = FirebaseFirestore.instance.batch();

    final msgRef = chatRef.collection('messages').doc();
    batch.set(
      msgRef,
      Message(
        senderId: widget.currentUserId,
        text: text,
        timestamp: DateTime.now(),
      ).toMap(),
    );

    // Keep the chat list preview up to date
    batch.update(chatRef, {
      'lastMessage': text,
      'lastMessageTime': FieldValue.serverTimestamp(),
    });

    await batch.commit();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ─── Lifecycle ───────────────────────────────────────────────────────────

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ─── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          _buildInputBar(),
        ],
      ),
    );
  }

  // ─── Widgets ─────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    return AppBar(title: Text(widget.otherUserName), centerTitle: true);
  }

  Widget _buildMessageList() {
    return StreamBuilder<List<Message>>(
      stream: _messagesStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong.'));
        }

        final messages = snapshot.data ?? [];

        if (messages.isEmpty) {
          return const Center(child: Text('No messages yet. Say hello!'));
        }

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          itemCount: messages.length,
          itemBuilder: (context, index) => _buildMessageBubble(messages[index]),
        );
      },
    );
  }

  Widget _buildMessageBubble(Message message) {
    final isMe = message.senderId == widget.currentUserId;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        decoration: BoxDecoration(
          color: isMe
              ? Theme.of(context).colorScheme.primary
              : Colors.grey[300],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: isMe ? Colors.white : Colors.black87,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Message...',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _sendMessage,
              icon: const Icon(Icons.send_rounded),
              color: Theme.of(context).colorScheme.primary,
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
