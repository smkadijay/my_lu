import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import 'chat_page.dart' hide getChatId;
import 'chat_utils.dart';

class UsersListPage extends StatelessWidget {
  const UsersListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("All Users"),
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index].data() as Map<String, dynamic>;

              // Skip current user
              if (user['uid'] == currentUser!.uid) {
                return const SizedBox.shrink();
              }

              return ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.person, color: Colors.white),
                  backgroundColor: Colors.deepPurple,
                ),
                title: Text(user['name'] ?? "Unknown"),
                subtitle: Text(user['email'] ?? ""),
                onTap: () {
                  String chatId = getChatId(currentUser.uid, user['uid']);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatPage(
                        chatId: chatId,
                        currentUserId: currentUser.uid,
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
