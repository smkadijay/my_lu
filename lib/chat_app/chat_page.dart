import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/chat_bubble.dart';
import 'chat_input.dart';

String getChatId(String user1, String user2) {
  if (user1.compareTo(user2) < 0) {
    return "${user1}_$user2";
  } else {
    return "${user2}_$user1";
  }
}

class ChatPage extends StatelessWidget {
  final String chatId;
  final String currentUserId;

  const ChatPage({super.key, required this.chatId, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    final messagesRef = FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false);

    return Scaffold(
      appBar: AppBar(title: const Text("Chat")),
      body: Container(
  decoration: const BoxDecoration(
    image: DecorationImage(
      image: AssetImage("assets/chat_bg.jpeg"), // add your background image in assets
      fit: BoxFit.cover,
            ),
          ),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: messagesRef.snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                  final messages = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index].data() as Map<String, dynamic>;
                      final isMe = msg["senderId"] == currentUserId;
                      return ChatBubble(message: msg, isMe: isMe);
                    },
                  );
                },
              ),
            ),
            ChatInput(chatId: chatId, currentUserId: currentUserId),
          ],
        ),
      ),
    );
  }
}
