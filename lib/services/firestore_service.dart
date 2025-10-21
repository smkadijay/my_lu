// lib/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  FirestoreService._();
  static final instance = FirestoreService._();

  final _firestore = FirebaseFirestore.instance;

  /// ------------------------------
  /// MESSAGES
  /// ------------------------------

  /// Send message to Firestore
  Future<void> sendMessage({
    required String fromUserId,
    required String toUserId,
    required Map<String, dynamic> messageData,
  }) async {
    final convId = conversationIdFor(fromUserId, toUserId);

    final messageRef = _firestore
        .collection('conversations')
        .doc(convId)
        .collection('messages')
        .doc();

    await messageRef.set(messageData);
  }

  /// Update conversation meta data (last message, etc.)
  Future<void> updateConversationMeta({
    required String userA,
    required String userB,
    required String lastMessage,
    required dynamic lastMessageTime,
  }) async {
    final userChatsA = _firestore.collection('users').doc(userA).collection('chats').doc(userB);
    final userChatsB = _firestore.collection('users').doc(userB).collection('chats').doc(userA);

    await Future.wait([
      userChatsA.set({
        'receiverId': userB,
        'lastMessage': lastMessage,
        'lastMessageTime': lastMessageTime,
      }, SetOptions(merge: true)),
      userChatsB.set({
        'receiverId': userA,
        'lastMessage': lastMessage,
        'lastMessageTime': lastMessageTime,
      }, SetOptions(merge: true)),
    ]);
  }

  /// Mark all messages seen for this user
  Future<void> markConversationMessagesSeen({
    required String conversationId,
    required String userId,
  }) async {
    final snapshot = await _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .where('receiverId', isEqualTo: userId)
        .where('seen', isEqualTo: false)
        .get();

    for (final doc in snapshot.docs) {
      await doc.reference.update({'seen': true});
    }
  }

  /// ------------------------------
  /// PRESENCE & LAST SEEN
  /// ------------------------------

  Future<void> setUserPresence({
    required String uid,
    required bool isOnline,
    dynamic lastSeen,
  }) async {
    final userRef = _firestore.collection('users').doc(uid);
    final updateData = {
      'isOnline': isOnline,
    };
    if (lastSeen != null) {
      updateData['lastSeen'] = lastSeen;
    }
    await userRef.set(updateData, SetOptions(merge: true));
  }

  /// ------------------------------
  /// TYPING INDICATOR
  /// ------------------------------

  Future<void> setTypingStatus({
    required String fromUserId,
    required String toUserId,
    required bool isTyping,
  }) async {
    final convId = conversationIdFor(fromUserId, toUserId);
    final docRef = _firestore.collection('typing').doc(convId);
    await docRef.set({
      '$convId-$fromUserId-typing': isTyping,
    }, SetOptions(merge: true));
  }

  /// ------------------------------
  /// MESSAGE REQUESTS
  /// ------------------------------

  Future<void> sendMessageRequest({
    required String fromUserId,
    required String toUserId,
    required String message,
  }) async {
    final requestRef = _firestore.collection('message_requests').doc();
    await requestRef.set({
      'senderId': fromUserId,
      'receiverId': toUserId,
      'content': message,
      'type': 'text',
      'createdAt': FieldValue.serverTimestamp(),
      'seen': false,
      'request': true,
    });
  }

  Future<void> deleteMessageRequest(String requestId) async {
    await _firestore.collection('message_requests').doc(requestId).delete();
  }

  /// ------------------------------
  /// HELPER
  /// ------------------------------

  /// Make consistent conversationId for two users
  String conversationIdFor(String a, String b) {
    final sorted = [a, b]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }
}
