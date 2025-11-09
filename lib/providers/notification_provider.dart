import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  int _unreadMessageCount = 0;
  Map<String, int> _unreadPerChat = {};

  int get unreadMessageCount => _unreadMessageCount;

  int getUnreadForChat(String chatId) => _unreadPerChat[chatId] ?? 0;

  // Listen to unread messages for a user
  void listenToUnreadMessages(String userId) {
    // Listen to all chats where user is a participant
    _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .snapshots()
        .listen((chatSnapshot) {
      _updateUnreadCounts(userId, chatSnapshot.docs);
    });
  }

  Future<void> _updateUnreadCounts(String userId, List<QueryDocumentSnapshot> chatDocs) async {
    int totalUnread = 0;
    Map<String, int> unreadPerChat = {};

    for (var chatDoc in chatDocs) {
      String chatId = chatDoc.id;
      Map<String, dynamic> chatData = chatDoc.data() as Map<String, dynamic>;

      // Get last read timestamp for this user in this chat
      Map<String, dynamic>? lastRead = chatData['lastRead'] as Map<String, dynamic>?;
      Timestamp? userLastRead = lastRead?[userId] as Timestamp?;

      // Count unread messages in this chat
      Query messagesQuery = _firestore
          .collection('messages')
          .where('chatId', isEqualTo: chatId)
          .where('senderId', isNotEqualTo: userId);

      if (userLastRead != null) {
        messagesQuery = messagesQuery.where('timestamp', isGreaterThan: userLastRead);
      }

      final unreadSnapshot = await messagesQuery.get();
      int unreadCount = unreadSnapshot.docs.length;

      unreadPerChat[chatId] = unreadCount;
      totalUnread += unreadCount;
    }

    _unreadMessageCount = totalUnread;
    _unreadPerChat = unreadPerChat;
    notifyListeners();
  }

  // Mark chat as read
  Future<void> markChatAsRead(String chatId, String userId) async {
    try {
      await _firestore.collection('chats').doc(chatId).update({
        'lastRead.$userId': FieldValue.serverTimestamp(),
      });

      // Update local state
      _unreadPerChat[chatId] = 0;
      _unreadMessageCount = _unreadPerChat.values.fold(0, (total, c) => total + c);
      notifyListeners();
    } catch (e) {
      debugPrint('Error marking chat as read: $e');
    }
  }
}

