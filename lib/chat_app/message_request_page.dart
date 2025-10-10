import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_lu/chat_app/chat_page.dart';
import 'package:my_lu/chat_app/chat_utils.dart';

class MessageRequestsPage extends StatelessWidget {
  const MessageRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const Scaffold(body: Center(child: Text('Login required')));

    return Scaffold(
      appBar: AppBar(title: const Text('Message Requests')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('messageRequests')
            .where('to', isEqualTo: uid)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final requests = snapshot.data!.docs;
          if (requests.isEmpty) {
            return const Center(child: Text('No requests'));
          }
          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final data = requests[index].data() as Map<String, dynamic>;
              final fromId = data['from'] ?? '';
              final fromName = data['fromName'] ?? '';
              final status = data['status'] ?? 'pending';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: ListTile(
                  title: Text(fromName.isNotEmpty ? fromName : 'Unknown'),
                  subtitle: Text('Status: $status'),
                  trailing: status == 'pending'
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.check, color: Colors.green),
                              onPressed: () async {
                                await requests[index].reference.update({'status': 'accepted'});
                                final chatId = getChatId(uid, fromId);
                                await FirebaseFirestore.instance.collection('chats').doc(chatId).set({
                                  'members': [uid, fromId],
                                  'createdAt': FieldValue.serverTimestamp(),
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Request accepted')),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () async {
                                await requests[index].reference.update({'status': 'rejected'});
                              },
                            ),
                          ],
                        )
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
