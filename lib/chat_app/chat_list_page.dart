import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'find_friends_page.dart';
import 'chat_input.dart';

class ChatListPage extends StatelessWidget {
  const ChatListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser!.uid;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF00B4DB), Color(0xFF0083B0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('💬 Chats',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          actions: [
            IconButton(
              icon: const Icon(Icons.person_add, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FindFriendsPage()),
                );
              },
            ),
          ],
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('chats')
              .where('participants', arrayContains: currentUid)
              .orderBy('lastMessageTime', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(color: Colors.white));
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                  child: Text('No chats yet 🌙',
                      style: TextStyle(color: Colors.white70)));
            }

            final chats = snapshot.data!.docs;

            return ListView.builder(
              itemCount: chats.length,
              itemBuilder: (context, index) {
                final chat = chats[index];
                final participants =
                    List<String>.from(chat['participants'] ?? []);
                final otherId =
                    participants.firstWhere((id) => id != currentUid);

                final lastMsg = chat['lastMessage'] ?? '';
                final lastTime =
                    (chat['lastMessageTime'] as Timestamp?)?.toDate();

                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(otherId)
                      .get(),
                  builder: (context, userSnap) {
                    if (!userSnap.hasData || !userSnap.data!.exists) {
                      return const SizedBox.shrink();
                    }
                    final user = userSnap.data!;
                    final name = user['name'] ?? 'Unknown';
                    final email = user['email'] ?? '';
                    final avatar = user['avatar'] ?? '';

                    return Card(
                      color: Colors.white.withOpacity(0.15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18)),
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage:
                              avatar.isNotEmpty ? NetworkImage(avatar) : null,
                          backgroundColor: Colors.cyan.shade300,
                          child: avatar.isEmpty
                              ? Text(name[0].toUpperCase(),
                                  style: const TextStyle(color: Colors.white))
                              : null,
                        ),
                        title: Text(name,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          lastMsg.isNotEmpty ? lastMsg : email,
                          style:
                              const TextStyle(color: Colors.white70, fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: lastTime != null
                            ? Text(
                                DateFormat('hh:mm a').format(lastTime),
                                style: const TextStyle(
                                    color: Colors.white60, fontSize: 11),
                              )
                            : null,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatInput(
                                chatId: chat.id,
                                currentUserId: currentUid,
                                receiverId: otherId,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}