// lib/chat_app/chat_utils.dart

/// This file contains helper functions for the chat system.

/// Generates a unique chat ID for private chats between two users.
/// Always arranges the IDs alphabetically so both sides get the same ID.

String getChatId(String uid1, String uid2) {
  final sorted = [uid1, uid2]..sort();
  return '${sorted[0]}_${sorted[1]}';
}

