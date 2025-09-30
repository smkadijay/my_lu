import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> saveUserToFirestore(User user, [String? name]) async {
  await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
    'uid': user.uid,
    'email': user.email,
    'name': name ?? user.displayName ?? "No Name",
    'lastLogin': FieldValue.serverTimestamp(),
  }, SetOptions(merge: true));
}

// Function to get list of other users
Stream<QuerySnapshot> getOtherUsers(String currentUserId) {
  return FirebaseFirestore.instance
      .collection('users')
      .where('uid', isNotEqualTo: currentUserId)
      .snapshots();
}
