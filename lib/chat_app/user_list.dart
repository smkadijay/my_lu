// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'chat_page.dart';
// import 'message_request_page.dart';

// class UserList extends StatefulWidget {
//   const UserList({super.key});

//   @override
//   State<UserList> createState() => _UserListState();
// }

// class _UserListState extends State<UserList> {
//   final currentUser = FirebaseAuth.instance.currentUser!;
//   final TextEditingController _searchController = TextEditingController();
//   String searchQuery = '';

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.transparent,
//       body: Stack(
//         children: [
         
//           ClipPath(
//             clipper: TopWaveClipper(),
//             child: Container(
//               height: 220,
//               decoration: const BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [Color(0xFF7E57C2), Color(0xFF512DA8)],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//               ),
//             ),
//           ),
//           Align(
//             alignment: Alignment.bottomCenter,
//             child: Container(
//               height: MediaQuery.of(context).size.height * 0.75,
//               color: Colors.deepPurple.shade50,
//             ),
//           ),
//           SafeArea(
//             child: Column(
//               children: [
//                 const SizedBox(height: 20),
//                 const Text(
//                   "Find Friends",
//                   style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 10),
               
//                 Container(
//                   margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(30),
//                     boxShadow: [
//                       BoxShadow(
//                           color: Colors.black.withOpacity(0.1),
//                           blurRadius: 6,
//                           offset: const Offset(0, 3))
//                     ],
//                   ),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: TextField(
//                           controller: _searchController,
//                           decoration: const InputDecoration(
//                               hintText: "Search by email...", border: InputBorder.none),
//                           onSubmitted: (value) {
//                             setState(() => searchQuery = value.trim());
//                           },
//                         ),
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.search, color: Colors.deepPurple),
//                         onPressed: () {
//                           setState(() => searchQuery = _searchController.text.trim());
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
               
//                 Expanded(
//                   child: StreamBuilder<QuerySnapshot>(
//                     stream: _searchUsers(),
//                     builder: (context, snapshot) {
//                       if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
//                       final users = snapshot.data!.docs;
//                       if (users.isEmpty) return const Center(child: Text("No user found"));
//                       return ListView.builder(
//                         padding: const EdgeInsets.only(top: 10),
//                         itemCount: users.length,
//                         itemBuilder: (context, index) {
//                           final data = users[index].data()! as Map<String, dynamic>;
//                           final uid = users[index].id;
//                           final name = data['name'] ?? 'Unknown';
//                           final email = data['email'] ?? '';
//                           final avatar = data['avatar'] ?? '';

//                           return Card(
//                             color: Colors.white,
//                             elevation: 6,
//                             shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(16)),
//                             margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                             child: ListTile(
//                               leading: CircleAvatar(
//                                 backgroundImage:
//                                     avatar.isNotEmpty ? NetworkImage(avatar) : null,
//                                 backgroundColor: Colors.deepPurple.shade100,
//                                 child: avatar.isEmpty
//                                     ? Text(name[0].toUpperCase(),
//                                         style: const TextStyle(color: Colors.white))
//                                     : null,
//                               ),
//                               title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
//                               subtitle: Text(email, style: const TextStyle(color: Colors.black54)),
//                               onTap: () async {
                              
//                                 final chatId = await _getOrCreateChat(uid, name, email, avatar);
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (_) => ChatPage(
//                                       chatId: chatId,
//                                       currentUserId: currentUser.uid,
//                                       receiverId: uid,
//                                       receiverEmail: email,
//                                       receiverName: name,
//                                       receiverAvatar: avatar,
//                                       chatName: name,
//                                       peerImage: avatar,
//                                     ),
//                                   ),
//                                 );
//                               },
//                             ),
//                           );
//                         },
//                       );
//                     },
//                   ),
//                 ),
              
//                 Padding(
//                   padding: const EdgeInsets.all(12),
//                   child: StreamBuilder<QuerySnapshot>(
//                     stream: FirebaseFirestore.instance
//                         .collection('chats')
//                         .where('participants', arrayContains: currentUser.uid)
//                         .where('status', isEqualTo: 'pending')
//                         .snapshots(),
//                     builder: (context, snapshot) {
//                       if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const SizedBox();
//                       final count = snapshot.data!.docs.length;
//                       return ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.deepPurple,
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(20)),
//                           padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//                         ),
//                         onPressed: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (_) => MessageRequestPage(
//                                       currentUserId: currentUser.uid,
//                                     )),
//                           );
//                         },
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             const Icon(Icons.mail_outline, color: Colors.white),
//                             const SizedBox(width: 8),
//                             Text("Message Requests ($count)"),
//                           ],
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Stream<QuerySnapshot> _searchUsers() {
//     final usersRef = FirebaseFirestore.instance.collection('users');
//     if (searchQuery.isEmpty) {
   
//       return usersRef
//           .where('uid', isNotEqualTo: currentUser.uid)
//           .snapshots();
//     } else {
//       return usersRef
//           .where('email', isGreaterThanOrEqualTo: searchQuery)
//           .where('email', isLessThanOrEqualTo: searchQuery + '\uf8ff')
//           .snapshots();
//     }
//   }

//   Future<String> _getOrCreateChat(String uid, String name, String email, String avatar) async {
//     final chatsRef = FirebaseFirestore.instance.collection('chats');
//     final snapshot = await chatsRef
//         .where('participants', arrayContains: currentUser.uid)
//         .get();

//     for (var doc in snapshot.docs) {
//       final participants = List<String>.from(doc['participants']);
//       if (participants.contains(uid)) return doc.id; 
//     }


//     final newChat = await chatsRef.add({
//       'participants': [currentUser.uid, uid],
//       'status': 'pending',
//       'users': {
//         currentUser.uid: {
//           'name': currentUser.displayName ?? 'Me',
//           'email': currentUser.email,
//           'avatar': currentUser.photoURL ?? '',
//         },
//         uid: {'name': name, 'email': email, 'avatar': avatar},
//       },
//       'lastMessage': '',
//       'lastMessageTime': FieldValue.serverTimestamp(),
//     });

//     return newChat.id;
//   }
// }



// class TopWaveClipper extends CustomClipper<Path> {
//   @override
//   Path getClip(Size size) {
//     final path = Path();
//     path.lineTo(0, size.height - 80);
//     path.quadraticBezierTo(size.width / 2, size.height, size.width, size.height - 80);
//     path.lineTo(size.width, 0);
//     path.close();
//     return path;
//   }

//   @override
//   bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
// }
