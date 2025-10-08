import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_page.dart';
import 'chat_utils.dart';

class UsersList extends StatelessWidget {
  const UsersList({super.key});

  @override
  Widget build(BuildContext context) {
    final current = FirebaseAuth.instance.currentUser;
    if (current == null) return const Scaffold(body: Center(child: Text('Please login')));

    final currentUserId = current.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('All Users')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snap.data!.docs;
          final others = docs.where((d) => (d.data() as Map<String, dynamic>)['uid'] != currentUserId).toList();

          final display = others.isEmpty ? docs : others;

          return ListView.builder(
            itemCount: display.length,
            itemBuilder: (context, i) {
              final data = display[i].data() as Map<String, dynamic>;
              final receiverId = data['uid'] ?? '';
              final chatId = getChatId(currentUserId, receiverId);

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: data['avatar'] != null && data['avatar'] != '' 
                    ? NetworkImage(data['avatar'])
                    : null,
                  child: (data['avatar'] == null || data['avatar'] == '') ? const Icon(Icons.person) : null,
                ),
                title: Text(data['name'] ?? 'No name'),
                subtitle: Text(data['email'] ?? ''),
                onTap: () {
                  if (receiverId.isEmpty || chatId.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid user id')));
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatPage(
                        chatId: chatId,
                        currentUserId: currentUserId,
                        receiverId: receiverId,
                        receiverEmail: data['email'] ?? '',
                        receiverName: data['name'] ?? '',
                        receiverAvatar: data['avatar'] ?? '',
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
