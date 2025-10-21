import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_input.dart';

class FindFriendsPage extends StatefulWidget {
  const FindFriendsPage({super.key});

  @override
  State<FindFriendsPage> createState() => _FindFriendsPageState();
}

class _FindFriendsPageState extends State<FindFriendsPage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF00B4DB), Color(0xFF0083B0)], // Ocean gradient
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text(
              '🌊 Find Friends',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Column(
            children: [
              // 🔹 Search Bar
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Search by email...',
                    hintStyle: TextStyle(color: Colors.white70),
                    border: InputBorder.none,
                    icon: Icon(Icons.search, color: Colors.white),
                  ),
                  onChanged: (v) => setState(() => searchQuery = v.trim()),
                ),
              ),

              // 🔹 User List
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _searchUsers(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text(
                          'No users found 🌙',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      );
                    }

                    final users = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: users.length,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      itemBuilder: (context, index) {
                        final data = users[index].data() as Map<String, dynamic>;
                        final uid = users[index].id;

                        // নিজের প্রোফাইল skip করো
                        if (uid == currentUser.uid) return const SizedBox.shrink();

                        final name = data['name'] ?? 'Unknown';
                        final email = data['email'] ?? '';
                        final avatar = data['avatar'] ?? '';

                        return Card(
                          color: Colors.white.withOpacity(0.12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: avatar.isNotEmpty ? NetworkImage(avatar) : null,
                              backgroundColor: Colors.blueAccent.shade100,
                              child: avatar.isEmpty
                                  ? Text(
                                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                                      style: const TextStyle(color: Colors.white),
                                    )
                                  : null,
                            ),
                            title: Text(
                              name,
                              style: const TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              email,
                              style: const TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                            trailing: const Icon(Icons.chat_bubble_outline, color: Colors.white),
                            onTap: () async {
                              final chatId = await _getOrCreateChat(uid);
                              if (!mounted) return;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChatInput(
                                    chatId: chatId,
                                    currentUserId: currentUser.uid,
                                    receiverId: uid,
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 Firestore Search Function
  Stream<QuerySnapshot> _searchUsers() {
    final usersRef = FirebaseFirestore.instance.collection('users');
    if (searchQuery.isEmpty) {
      return usersRef.snapshots();
    } else {
      return usersRef
          .where('email', isGreaterThanOrEqualTo: searchQuery)
          .where('email', isLessThanOrEqualTo: '$searchQuery\uf8ff')
          .snapshots();
    }
  }

  // 🔹 Create or Get Existing Chat
  Future<String> _getOrCreateChat(String uid) async {
    final chatsRef = FirebaseFirestore.instance.collection('chats');
    final query = await chatsRef.where('participants', arrayContains: currentUser.uid).get();

    for (var doc in query.docs) {
      final participants = List<String>.from(doc['participants']);
      if (participants.contains(uid)) return doc.id;
    }

    final newChat = await chatsRef.add({
      'participants': [currentUser.uid, uid],
      'lastMessage': '',
      'lastMessageTime': FieldValue.serverTimestamp(),
    });
    return newChat.id;
  }
}