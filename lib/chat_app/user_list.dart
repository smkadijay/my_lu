import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'find_user_page.dart';
import 'chat_page.dart';
import 'chat_utils.dart';

class UsersList extends StatelessWidget {
  const UsersList({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(body: Center(child: Text('Login required')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const FindUserPage()));
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('members', arrayContains: uid)
            .orderBy('lastTime', descending: true)
            .snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final chats = snap.data!.docs;
          if (chats.isEmpty) {
            return const Center(child: Text('No chats yet'));
          }
          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, i) {
              final data = chats[i].data() as Map<String, dynamic>;
              final memberIds = List<String>.from(data['members']);
              final partnerId = memberIds.firstWhere((id) => id != uid);
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(partnerId).get(),
                builder: (context, userSnap) {
                  if (!userSnap.hasData) return const SizedBox();
                  final userData = userSnap.data!.data() as Map<String, dynamic>? ?? {};
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: userData['avatar'] != ''
                          ? NetworkImage(userData['avatar'])
                          : null,
                      child: userData['avatar'] == ''
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    title: Text(userData['name'] ?? 'Unknown'),
                    subtitle: Text(userData['email'] ?? ''),
                    onTap: () {
                      final chatId = getChatId(uid, partnerId);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatPage(
                            chatId: chatId,
                            currentUserId: uid,
                            receiverId: partnerId,
                            receiverEmail: userData['email'],
                            receiverName: userData['name'],
                            receiverAvatar: userData['avatar'], chatName: null, peerImage: null,
                          ),
                        ),
                      );
                    },
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
