import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_page.dart';

class MessageRequestPage extends StatelessWidget {
  final String currentUserId;

  const MessageRequestPage({super.key, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    final pendingQuery = FirebaseFirestore.instance
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .where('status', isEqualTo: 'pending');

    return Scaffold(
      appBar: AppBar(
        title: const Text("Message Requests"),
        backgroundColor: Colors.purple,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: pendingQuery.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;

          if (docs.isEmpty) return const Center(child: Text("No message requests."));

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final chat = docs[index];
              final users = Map<String, dynamic>.from(chat['users']);
              final otherUser = users.entries.firstWhere((e) => e.key != currentUserId).value;
              final otherUserId = chat['participants'].firstWhere((id) => id != currentUserId);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(otherUser['avatar']),
                  ),
                  title: Text(otherUser['name']),
                  subtitle: const Text("Sent you a message"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () async {
                          // Accept the request → make chat active
                          await chat.reference.update({'status': 'active'});
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Request accepted.")),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () async {
                          // Reject → delete chat
                          await chat.reference.delete();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Request ignored.")),
                          );
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatPage(
                          chatId: chat.id,
                          currentUserId: currentUserId,
                          receiverId: otherUserId,
                          receiverEmail: otherUser['email'],
                          receiverName: otherUser['name'],
                          receiverAvatar: otherUser['avatar'], chatName: '', peerImage: '', 
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
