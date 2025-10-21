// lib/chat_app/chat_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_lu/widgets/chat_bubble.dart' hide Timestamp;
import 'chat_input.dart';
String? currentUid() {
  return FirebaseAuth.instance.currentUser?.uid;
}

class ChatScreen extends StatefulWidget {
  final String receiverId;
  final String receiverName;
  final String? receiverPhoto;

  const ChatScreen({
    Key? key,
    required this.receiverId,
    required this.receiverName,
    this.receiverPhoto,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  
  get ChatMessage => null;

  Stream<DocumentSnapshot> _receiverStatusStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(widget.receiverId)
        .snapshots();
  }

  Stream<QuerySnapshot> _messageStream() {
    final convId = conversationIdFor(currentUid()!, widget.receiverId);
    return FirebaseFirestore.instance
        .collection('conversations')
        .doc(convId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots();
  }

  Stream<DocumentSnapshot> _typingStream() {
    return FirebaseFirestore.instance
        .collection('typing')
        .doc(conversationIdFor(currentUid()!, widget.receiverId))
        .snapshots();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 120,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();
    setUserOnline(currentUid()!); // mark myself online
  }

  @override
  void dispose() {
    setUserOnline(currentUid()!); // mark myself offline
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final myId = currentUid()!;

    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.deepPurple),
        title: StreamBuilder<DocumentSnapshot>(
          stream: _receiverStatusStream(),
          builder: (context, snapshot) {
            final data = snapshot.data?.data() as Map<String, dynamic>?;

            String statusText = 'Offline';
            if (data != null && data['isOnline'] == true) {
              statusText = 'Online';
            } else if (data != null && data['lastSeen'] != null) {
              final ts = data['lastSeen'] as Timestamp;
              statusText = 'Last seen ${formatTimestamp(ts)}';
            }

            return Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: widget.receiverPhoto != null
                      ? NetworkImage(widget.receiverPhoto!)
                      : null,
                  backgroundColor: Colors.grey.shade300,
                  child: widget.receiverPhoto == null
                      ? const Icon(Icons.person, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.receiverName,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    StreamBuilder<DocumentSnapshot>(
                      stream: _typingStream(),
                      builder: (context, snapshot) {
                        final data = snapshot.data?.data() as Map<String, dynamic>?;
                        final convId =
                            conversationIdFor(widget.receiverId, myId);
                        final isTyping = data != null &&
                            data['$convId-${widget.receiverId}-typing'] == true;
                        return Text(
                          isTyping ? "Typing..." : statusText,
                          style: TextStyle(
                            fontSize: 12,
                            color: isTyping
                                ? Colors.green
                                : Colors.grey.shade600,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _messageStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data?.docs ?? [];
                final messages = docs.map((d) => ChatMessage.fromDoc(d)).toList();

                WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(bottom: 8, top: 12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final m = messages[index];
                    final isMe = m.senderId == myId;
                    return ChatBubble(
                      message: m,
                      isMe: isMe,
                      avatarUrl: isMe ? null : widget.receiverPhoto, messageType: '',
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  conversationIdFor(String receiverId, myId) {}
  
  void setUserOnline(String s) {}
  
  formatTimestamp(Timestamp ts) {}
}

class _TypingAwareInput extends StatefulWidget {
  final String receiverId;
  const _TypingAwareInput({Key? key, required this.receiverId})
      : super(key: key);

  @override
  State<_TypingAwareInput> createState() => _TypingAwareInputState();
}

class _TypingAwareInputState extends State<_TypingAwareInput> {
  final TextEditingController _controller = TextEditingController();
  bool _isTyping = false;
  DateTime _lastTyped = DateTime.now();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleTyping);
  }

  void _handleTyping() {
    final text = _controller.text.trim();
    final now = DateTime.now();
    final diff = now.difference(_lastTyped).inSeconds;

    if (text.isNotEmpty && (!_isTyping || diff > 2)) {
      setTypingStatus(
        fromUserId: currentUid()!,
        toUserId: widget.receiverId,
        isTyping: true,
      );
      _isTyping = true;
      _lastTyped = now;
    } else if (text.isEmpty && _isTyping) {
      setTypingStatus(
        fromUserId: currentUid()!,
        toUserId: widget.receiverId,
        isTyping: false,
      );
      _isTyping = false;
    }
  }

  @override
  void dispose() {
    if (_isTyping) {
      setTypingStatus(
        fromUserId: currentUid()!,
        toUserId: widget.receiverId,
        isTyping: false,
      );
    }
    _controller.removeListener(_handleTyping);
    _controller.dispose();
    super.dispose();
  }

  /// Update the typing status for the conversation in Firestore.
  /// This resolves the undefined method error by providing a local
  /// implementation used by this state class.
  Future<void> setTypingStatus({
    required String fromUserId,
    required String toUserId,
    required bool isTyping,
  }) async {
    // Build a deterministic conversation id (lexicographic order)
    final convId = fromUserId.compareTo(toUserId) > 0
        ? '$fromUserId\_$toUserId'
        : '$toUserId\_$fromUserId';

    final docRef =
        FirebaseFirestore.instance.collection('typing').doc(convId);

    // Store a field keyed to this conversation and the recipient to indicate typing state
    await docRef.set(
      {'$convId-$toUserId-typing': isTyping},
      SetOptions(merge: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChatInput(receiverId: widget.receiverId, chatId: '', currentUserId: '',);
  }
}
