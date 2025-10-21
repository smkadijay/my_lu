import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_input.dart';
import 'package:my_lu/widgets/chat_bubble.dart';

class ChatPage extends StatelessWidget {
  final String chatId;
  final String currentUserId;
  final String receiverId;
  final String receiverEmail;
  final String receiverName;
  final String receiverAvatar;
  final String chatName;
  final String peerImage;

  const ChatPage({
    super.key,
    required this.chatId,
    required this.currentUserId,
    required this.receiverId,
    required this.receiverEmail,
    required this.receiverName,
    required this.receiverAvatar,
    required this.chatName,
    required this.peerImage,
  });

  @override
  Widget build(BuildContext context) {
    if (chatId.isEmpty || currentUserId.isEmpty) {
      return const Scaffold(body: Center(child: Text('Invalid chat')));
    }

    final messagesQuery = FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false);

    return Scaffold(
      body: Stack(
        children: [
          // 🌈 Gradient + wavy background
          ClipPath(
            clipper: ChatBackgroundClipper(),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFB2FEFA), Color(0xFF0ED2F7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          Column(
            children: [
              // 🔹 AppBar like header
              Container(
                padding: const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 16),
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundImage: peerImage.isNotEmpty ? NetworkImage(peerImage) : null,
                      backgroundColor: Colors.deepPurple.shade200,
                      child: peerImage.isEmpty ? Text(chatName[0].toUpperCase(), style: const TextStyle(color: Colors.white)) : null,
                    ),
                    const SizedBox(width: 12),
                    Text(chatName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
              ),
              // 🔹 Messages
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

                        // mark seen
                        if (!isMe && (msg['seen'] == null || msg['seen'] == false)) {
                          try {
                            doc.reference.update({'seen': true});
                          } catch (_) {}
                        }

                        return ChatBubble(message: msg, isMe: isMe, messageType: '',);
                      },
                    );
                  },
                ),
              ),
              // 🔹 Chat input
              ChatInput(chatId: chatId, currentUserId: currentUserId, receiverId: receiverId,),
            ],
          ),
        ],
      ),
    );
  }
}

// 🌊 Wavy background for chat
class ChatBackgroundClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height * 0.8);
    path.quadraticBezierTo(size.width / 2, size.height, size.width, size.height * 0.8);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}