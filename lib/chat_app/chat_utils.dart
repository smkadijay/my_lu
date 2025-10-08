// lib/chat_app/chat_utils.dart

/// This file contains helper functions for the chat system.

/// Generates a unique chat ID for private chats between two users.
/// Always arranges the IDs alphabetically so both sides get the same ID.
String getChatId(String user1, String user2) {
  if (user1.compareTo(user2) < 0) {
    return "${user1}_$user2";
  } else {
    return "${user2}_$user1";
  }
}

