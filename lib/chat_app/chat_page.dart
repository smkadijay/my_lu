import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_lu/widgets/chat_bubble.dart';
import 'chat_input.dart';

class ChatPage extends StatelessWidget {
  final String chatId;
  final String currentUserId;
  final String receiverId;
  final String receiverEmail;
  final String receiverName;
  final String receiverAvatar;

  const ChatPage({
    super.key,
    required this.chatId,
    required this.currentUserId,
    required this.receiverId,
    required this.receiverEmail,
    required this.receiverName,
    required this.receiverAvatar,
  });

  @override
  Widget build(BuildContext context) {
    if (chatId.isEmpty || currentUserId.isEmpty) {
      return Scaffold(body: Center(child: Text('Invalid chat')));
    }

    final messagesQuery = FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black87),
        elevation: 1,
        title: Row(
          children: [
            CircleAvatar(backgroundImage: receiverAvatar.isNotEmpty ? NetworkImage(receiverAvatar) : null, radius: 18),
            const SizedBox(width: 10),
            Text(receiverName, style: const TextStyle(color: Colors.black87)),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF1F9FF), // light blue
              Color(0xFFFDF3FF), // very light pink
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: messagesQuery.snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final docs = snapshot.data!.docs;
                  return ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final msg = doc.data()! as Map<String, dynamic>;
                      final isMe = msg['senderId'] == currentUserId;

                      // mark seen when receiver opens (only for messages that are for current user)
                      if (!isMe && (msg['seen'] == null || msg['seen'] == false)) {
                        try {
                          doc.reference.update({'seen': true});
                        } catch (_) {}
                      }

                      return ChatBubble(message: msg, isMe: isMe);
                    },
                  );
                },
              ),
            ),
            ChatInput(chatId: chatId, currentUserId: currentUserId, receiverId: receiverId),
          ],
        ),
      ),
    );
  }
}
