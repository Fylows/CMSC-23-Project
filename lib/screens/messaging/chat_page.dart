import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:elbi_eats/providers/message/message_provider.dart';
import 'package:elbi_eats/models/message_model.dart';

// Adjust these imports to match your folder structure
import 'package:elbi_eats/providers/qr/qr_provider.dart';
import 'qr_scanner.dart';

class ChatPage extends StatefulWidget {
  final String chatId;
  final String currentUserId;
  final String otherUserName;
  final String itemName;

  const ChatPage({
    super.key,
    required this.chatId,
    required this.currentUserId,
    required this.otherUserName,
    required this.itemName,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final QrProvider _qrHandler = QrProvider();

  late Future<void> _chatReady;

  // ── Init ───────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _chatReady = _setup();
  }

  Future<void> _setup() async {
    await context.read<MessageProvider>().ensureChatExists(
      widget.chatId,
      widget.currentUserId,
    );
  }

  // ── Messaging ──────────────────────────────────────────────────

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    await context.read<MessageProvider>().sendMessage(widget.chatId, text);
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

  // ── QR: Owner generates ────────────────────────────────────────

  void _onGenerateQr({
    required String itemId,
    required String claimingID,
    required String claimerUID,
  }) {
    final payload = _qrHandler.generatePayload(
      chatId: widget.chatId,
      itemID: itemId,
      claimingID: claimingID,
      ownerUID: widget.currentUserId,
      claimerUID: claimerUID,
    );

    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _QrBottomSheet(qrData: payload.toQrString()),
    );
  }

  // ── QR: Claimer scans ──────────────────────────────────────────

  Future<void> _onScanQr() async {
    final confirmed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const QrScannerScreen()),
    );

    if (confirmed == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item successfully claimed! 🎉')),
      );
    }
  }

  // ── Build ──────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.itemName),
            Text(widget.otherUserName, style: const TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          StreamBuilder<Map<String, dynamic>?>(
            stream: context.read<MessageProvider>().watchChat(widget.chatId),
            builder: (context, snapshot) {
              final data = snapshot.data;
              final itemId = data?['itemId'] as String?;
              final claimingID = data?['claimingId'] as String?;
              final claimerUID = data?['claimerUid'] as String?;

              print(
                'Chat data updated: itemId=$itemId, claimingID=$claimingID, claimerUID=$claimerUID',
              );
              // All three must be present before any button appears
              if (itemId == null || claimingID == null || claimerUID == null) {
                return const SizedBox.shrink();
              }

              final isOwner = widget.currentUserId != claimerUID;
              final isClaimer = widget.currentUserId == claimerUID;

              if (isOwner) {
                return IconButton(
                  tooltip: 'Generate QR',
                  icon: const Icon(Icons.qr_code_2_rounded),
                  onPressed: () => _onGenerateQr(
                    itemId: itemId,
                    claimingID: claimingID,
                    claimerUID: claimerUID,
                  ),
                );
              }

              if (isClaimer) {
                return IconButton(
                  tooltip: 'Scan QR to claim',
                  icon: const Icon(Icons.qr_code_scanner_rounded),
                  onPressed: _onScanQr,
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ],
      ),

      body: FutureBuilder(
        future: _chatReady,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          return Column(
            children: [
              Expanded(child: _buildMessageList()),

              StreamBuilder<Map<String, dynamic>?>(
                stream: context.read<MessageProvider>().watchChat(
                  widget.chatId,
                ),
                builder: (context, snapshot) {
                  final claimed = snapshot.data?['claimed'] == true;

                  return claimed
                      ? SafeArea(
                          child: Container(
                            width: double.infinity,
                            margin: const EdgeInsets.all(12),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Text(
                              'Transaction has completed',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        )
                      : _buildInputBar(claimed);
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMessageList() {
    final otherUid = widget.chatId
        .replaceAll(widget.currentUserId, '')
        .replaceAll('_', '');

    return FutureBuilder<Map<String, dynamic>?>(
      future: context.read<MessageProvider>().getUserProfile(otherUid),
      builder: (context, profileSnapshot) {
        final profile = profileSnapshot.data;
        final avatarUrl = profile?['profilePictureUrl'] as String?;

        return StreamBuilder<List<Message>>(
          stream: context.read<MessageProvider>().watchMessages(widget.chatId),
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

            WidgetsBinding.instance.addPostFrameCallback(
              (_) => _scrollToBottom(),
            );

            return ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isMe = message.senderId == widget.currentUserId;
                final showHeader =
                    !isMe &&
                    (index == 0 ||
                        messages[index - 1].senderId != message.senderId);

                return _buildMessageBubble(
                  message,
                  showHeader: showHeader,
                  avatarUrl: avatarUrl,
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildMessageBubble(
    Message message, {
    bool showHeader = false,
    String? avatarUrl,
  }) {
    final isMe = message.senderId == widget.currentUserId;

    if (isMe) {
      // My bubble — right aligned, no avatar or name
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.72,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(4),
            ),
          ),
          child: Text(
            message.text,
            style: const TextStyle(color: Colors.white, fontSize: 15),
          ),
        ),
      );
    }

    // Their bubble — left aligned, with optional avatar and name
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Avatar — only show on first message in a group
          if (showHeader)
            CircleAvatar(
              radius: 16,
              backgroundImage: avatarUrl != null
                  ? NetworkImage(avatarUrl)
                  : null,
              child: avatarUrl == null
                  ? Text(widget.otherUserName[0].toUpperCase())
                  : null,
            )
          else
            const SizedBox(width: 32), // spacer to align non-first bubbles

          const SizedBox(width: 8),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Username above first bubble in a group
              if (showHeader)
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 2),
                  child: Text(
                    widget.otherUserName,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.62,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(4),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Text(
                  message.text,
                  style: const TextStyle(color: Colors.black87, fontSize: 15),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar(isCompleted) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: isCompleted
            ? Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  'Transaction has completed',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
            : Row(
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
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primaryContainer,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

// ── QR Bottom Sheet (shown to the owner) ──────────────────────────

class _QrBottomSheet extends StatelessWidget {
  const _QrBottomSheet({required this.qrData});

  final String qrData;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          Text(
            'Show this QR to the claimer',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            'They scan this to confirm the transaction.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 24),

          // QR code
          // Add to pubspec.yaml:  qr_flutter: ^4.1.0
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: 220,
              backgroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 20),

          Text(
            'Valid for 15 minutes',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
