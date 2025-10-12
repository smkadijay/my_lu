import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_page.dart';
import 'chat_utils.dart';

class FindUserPage extends StatefulWidget {
  const FindUserPage({super.key});

  @override
  State<FindUserPage> createState() => _FindUserPageState();
}

class _FindUserPageState extends State<FindUserPage> {
  final TextEditingController _emailController = TextEditingController();
  bool _loading = false;
  Map<String, dynamic>? _foundUser;

  Future<void> _searchUser() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;
    setState(() {
      _loading = true;
      _foundUser = null;
    });

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      setState(() {
        _foundUser = snapshot.docs.first.data();
      });
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('User not found')));
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final current = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Find User')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Enter email to find user',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _searchUser,
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_loading) const CircularProgressIndicator(),
            if (_foundUser != null)
              Card(
                margin: const EdgeInsets.only(top: 20),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: _foundUser!['avatar'] != ''
                        ? NetworkImage(_foundUser!['avatar'])
                        : null,
                    child: _foundUser!['avatar'] == ''
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  title: Text(_foundUser!['name'] ?? 'Unknown'),
                  subtitle: Text(_foundUser!['email']),
                  trailing: ElevatedButton(
                    onPressed: () async {
                      final receiverId = _foundUser!['uid'];
                      final currentId = current!.uid;
                      final chatId = getChatId(currentId, receiverId);

                      await FirebaseFirestore.instance
                          .collection('chats')
                          .doc(chatId)
                          .set({
                        'members': [currentId, receiverId],
                        'lastMessage': '',
                        'lastTime': FieldValue.serverTimestamp(),
                      }, SetOptions(merge: true));
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatPage(
                            chatId: chatId,
                            currentUserId: currentId,
                            receiverId: receiverId,
                            receiverEmail: _foundUser!['email'],
                            receiverName: _foundUser!['name'],
                            receiverAvatar: _foundUser!['avatar'], chatName: '', peerImage: '',
                          ),
                        ),
                      );
                    },
                    child: const Text('Chat'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
